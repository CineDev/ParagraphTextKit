//
//  ParagraphTextStorage.swift
//  ParagraphTextKit
//
//  Created by Vitalii Vashchenko on 16.04.2020.
//  Copyright © 2020 Vitalii Vashchenko. All rights reserved.
//

#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

//	ModernTextStorage is a subclass of NSTextStorage class.
//	It works with whole text paragraphs and notifies its
//	paragraph delegate of any changes in any paragraph.
//	Delegate receives the touched paragraph descriptors and their indexes.
open class ParagraphTextStorage: NSTextStorage {
	private let storage = NSMutableAttributedString()
	
	public override var length: Int {
		storage.length
	}

	/// Text storage string representation with read-only access
	public override var string : String {
		storage.mutableString as String
	}
	
	/// Array of the storage paragraphs
	public fileprivate(set) var paragraphRanges = [NSRange(location: 0, length: 0)]

	/// Delegate watches for any edits in the storage paragraphs
	public weak var paragraphDelegate: ParagraphTextStorageDelegate?
	
	/// Helper array to store paragraph data before editing to compare with actual changes after they've being made
	private var indexesBeforeEditing = [Int]()

	
	// MARK: - Initialization
	
	override public init() {
		super.init()
		startObserver()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		startObserver()
	}
	
	#if os(macOS)
	required public init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
		super.init(pasteboardPropertyList: propertyList, ofType: type)
		startObserver()
	}
	#endif
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	/// Method is crusial for correct calculations of paragraph ranges.
	///
	/// Its importans is due to the fact that any touches to the text storage during the processEditing private methods involved results in
	/// random failures when text is layouting. And we can't just override the processEditing method and fix paragraph ranges after calling super,
	/// because when the processEditing method is finished it calles some TextKit private APIs.
	///
	/// The NSTextStorage.willProcessEditingNotification notification ensures that we call fixParagraphRanges method at the right time,
	/// when all the private APIs have done their job.
	private func startObserver() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(textStorageWillProcessChanges(_:)),
											   name: NSTextStorage.willProcessEditingNotification,
											   object: nil)
	}
	
	@objc private func textStorageWillProcessChanges(_ sender: Notification) {
		guard sender.object as? ParagraphTextStorage == self else { return }
		fixParagraphRanges()
	}

	
	
	// MARK: - NSTextStorage Primitive Methods
	
	open override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
		storage.attributes(at: location, effectiveRange: range)
	}
	
	open override func replaceCharacters(in range: NSRange, with str: String) {
		let delta = str.length - range.length
		
		indexesBeforeEditing = paragraphIndexes(in: range)
		
		beginEditing()
		storage.replaceCharacters(in: range, with: str)
		edited(.editedCharacters, range: range, changeInLength: delta)
		endEditing()
	}
	
	open override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
		beginEditing()
		storage.setAttributes(attrs, range: range)
		edited(.editedAttributes, range: range, changeInLength: 0)
		endEditing()
	}
	
	
	// MARK: - Paragraph Management

	private func fixParagraphRanges() {
		let paragraphsBefore = indexesBeforeEditing.map{ paragraphRanges[$0] }
		let paragraphsAfter = substringParagraphRanges(from: editedRange)
		
		let difference = paragraphsAfter.difference(from: paragraphsBefore)
		let changes = ParagraphRangeChange.from(difference: difference,
												initialOffset: indexesBeforeEditing.first!)
		var lastEditedIndex = 0
		for change in changes {
			switch change {
			case .removedParagraph(index: let index):
				paragraphRanges.remove(at: index)
				lastEditedIndex = index - 1
			case .insertedParagraph(index: let index, range: let range):
				paragraphRanges.insert(range, at: index)
				lastEditedIndex = index
			case .editedParagraph(index: let index, range: let range):
				paragraphRanges[index] = range
				lastEditedIndex = index
			}
		}
		
		var lastEditedParagraph = paragraphRanges[lastEditedIndex]
		
		// update location of paragraph ranges following the edited ones
		for (i, _) in paragraphRanges.dropFirst(lastEditedIndex + 1).enumerated() {
			let normalizedIndex = i + lastEditedIndex + 1
			paragraphRanges[normalizedIndex].location = lastEditedParagraph.max
			lastEditedParagraph = paragraphRanges[normalizedIndex]
		}
		
		// notify the delegate of changes being made
		if let existingDelegate = paragraphDelegate {
			let descriptedChanges = ParagraphChange.from(rangeChanges: changes, textStorage: self)
			existingDelegate.textStorage(self, didChangeParagraphs: descriptedChanges)
		}
		indexesBeforeEditing.removeAll()
	}
	
	
	// MARK: - Paragraph Seeking
	
	private func paragraphRanges(from range: NSRange) -> [NSRange] {
		paragraphIndexes(in: range).map{ paragraphRanges[$0] }
	}
	
	private func substringParagraphRanges(from range: NSRange) -> [NSRange] {
		let paragraphs = attributedSubstring(from: range).string.paragraphs
		let startingParagraphRange = string.utfParagraphRange(at: range.location)
		
		var ranges = [startingParagraphRange]
		
		// for inserted (not appended) paragraphs we need this hack
		if paragraphs.count > 1 && range.max < length {
			var nextLocation = range.max

			for _ in 1 ..< paragraphs.count {
				let paragraph = string.utfParagraphRange(at: nextLocation)
				ranges.append(paragraph)
				nextLocation = paragraph.max
			}
		} else {
			for paragraph in paragraphs.dropFirst() {
				ranges.append( NSRange(location: ranges.last!.max, length: paragraph.length) )
			}
		}

		return ranges
	}
	
	
	public func paragraphIndex(at location: Int) -> Int {
		guard self.length > 0 else { return 0 }
		guard location < self.length else { return paragraphRanges.count - 1 }

		return 	paragraphRanges.firstIndex(where: { location >= $0.location && $0.max > location })!
	}
	
	
	public func paragraphIndexes(in range: NSRange) -> [Int] {
		guard length > 0 else { return [0] }
		
		// get paragraphs from the range
		let paragraphs = attributedSubstring(from: range).string.paragraphs

		// get start/end indexes for substring the existing paragraphs array..
		// .. it's better than iterating through all the paragraphs, especially if text is huge
		let firstTouchedIndex = paragraphIndex(at: range.location)
		let lastTouchedIndex = paragraphIndex(at: range.max)

		var paragraphIndexes = [Int]()
		
		// catch the paragraph indexes that are match with given range
		for i in firstTouchedIndex...lastTouchedIndex {

			// for recognizing deleted paragraphs, we need this hack
			if paragraphs.count > 1 && i > 0 && paragraphRanges.count - 1 >= i {
				paragraphIndexes.append(i)
				continue
			}

			let paragraph = paragraphRanges[i]
			
			if let _ = paragraph.intersection(range) {
				paragraphIndexes.append(i)
			} else if range.length == 0 && paragraph.location == range.location {
				paragraphIndexes.append(i)
			} else if range.length == 0 && paragraph.max == range.location {
				paragraphIndexes.append(i)
			}
		}
		
		return paragraphIndexes
	}
	
	
	// MARK: - Paragraph Descriptors
	
	public func paragraphDescriptor(atParagraphIndex index: Int) -> ParagraphDescriptor {
		let range = paragraphRanges[index]
		let string = attributedSubstring(from: range)
		return ParagraphDescriptor(attributedString: string, storageRange: range)
	}

	public func paragraphDescriptor(atCharacterIndex characterIndex: Int) -> ParagraphDescriptor {
		let index = paragraphIndex(at: characterIndex)
		return paragraphDescriptor(atParagraphIndex: index)
	}

	public func paragraphDescriptors(in range: NSRange) -> [ParagraphDescriptor] {
		let indexes = paragraphIndexes(in: range)
		return indexes.map{ paragraphDescriptor(atParagraphIndex: $0) }
	}
}
