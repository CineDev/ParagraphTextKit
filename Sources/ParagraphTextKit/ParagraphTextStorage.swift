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
import Combine

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
	public weak var paragraphDelegate: ParagraphTextStorageDelegate? {
		didSet {
			// make sure that the delegate becomes in sync with paragraphs, when initialized
			if self.length == 0 && paragraphDelegate?.paragraphCount() == 0 {
				paragraphDelegate?.textStorage(self, didChangeParagraphs: [ParagraphChange.insertedParagraph(index: 0, descriptor: paragraphDescriptor(atParagraphIndex: 0))])
			}
		}
	}
	
	/// Helper array to store paragraph data before editing to compare with actual changes after they've being made
	private var indexesBeforeEditing = [Int]()
	
	/// Helper var indicating that after the editing the resulting range of the next paragraph will be equal to the first edited paragraph
	/// and that might confuse the diff algorhythm.
	///
	/// That confusing results in the case when the diff algorhythm will not notify the delegate that the next paragraph was edited,
	/// because the algorhythm will consider that if the range is the same, then there was no change at all
	private var nextEditedParagraphWillHaveRangeEqualWithFirst = false
	
	/// Helper var for the case when a user pastes some text and that text length is equal to the selected text within the text view.
	///
	/// It is important, because if the edit with the same length of the selected text , the diff algrothythm
	/// won't recognize it as a change, since the result text storage will have the same paragraph lengths
	private var editHasSameLength = false

	/// Subscriber to the NSTextStorage.willProcessEditingNotification
	private var processingSubscriber: AnyCancellable?
	
	deinit {
		processingSubscriber?.cancel()
	}
	
	/// Method is crusial for correct calculations of paragraph ranges.
	///
	/// Its importans is due to the fact that any touches to the text storage during the processEditing private methods involved results in
	/// random failures when text is layouting. And we can't just override the processEditing method and fix paragraph ranges after calling super,
	/// because when the processEditing method is finished it calles some TextKit private APIs.
	///
	/// The NSTextStorage.willProcessEditingNotification notification ensures that we call fixParagraphRanges method at the right time,
	/// when all the private APIs have done their job.
	private func startProcessingSubscriber() {
		processingSubscriber = NotificationCenter.default.publisher(for: NSTextStorage.willProcessEditingNotification)
			.compactMap{ $0.object as? ParagraphTextStorage }
			.sink { sender in
				if sender == self {
					self.fixParagraphRanges()
				}
		}
	}
	
	
	// MARK: - NSTextStorage Primitive Methods
	
	open override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
		storage.attributes(at: location, effectiveRange: range)
	}
	
	open override func replaceCharacters(in range: NSRange, with str: String) {
		if processingSubscriber == nil {
			startProcessingSubscriber()
		}
		
		let delta = str.length - range.length
		
		indexesBeforeEditing = paragraphIndexes(in: range)
		
		if delta == 0 && str.length > 0 {
			editHasSameLength = true
		} else {
			editHasSameLength = false
		}
		
		if indexesBeforeEditing.count > 1 && delta < 0 {
			let firstRange = paragraphRanges[indexesBeforeEditing[0]]

			if firstRange.location == range.location && range.max > firstRange.max {
				let affectedRanges = indexesBeforeEditing.map{ paragraphRanges[$0] }
				let checkRanges =  Array(affectedRanges.dropLast())
				let sum = checkRanges.reduce(0, { $0 + $1.length })
				
				if affectedRanges.last!.length - abs(delta + sum) == firstRange.length {
					nextEditedParagraphWillHaveRangeEqualWithFirst = true
				}
			}
		}
		
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
		defer {
			nextEditedParagraphWillHaveRangeEqualWithFirst = false
			indexesBeforeEditing.removeAll()
		}
		
		// empty indexes before editing means that there was no editing happened;
		// it indicates that text storage is just updating text attributes, not changing the characters
		guard !indexesBeforeEditing.isEmpty else {
			
			// check if there was attribute changing in progress
			if editedMask.contains(.editedAttributes), let existingDelegate = paragraphDelegate  {
				var changes = [ParagraphChange]()
				
				// and if true, tell the delegate that some paragraphs were changed
				substringParagraphRanges(from: editedRange).forEach { paragraphRange in
					let idx = paragraphIndex(at: paragraphRange.location)
					let descriptor = paragraphDescriptor(atParagraphIndex: idx)
					changes.append(.editedParagraph(index: idx, descriptor: descriptor))
				}
				
				existingDelegate.textStorage(self, didChangeParagraphs: changes)
			}
			return
		}
		
		let paragraphsBefore = indexesBeforeEditing.map{ paragraphRanges[$0] }
		let paragraphsAfter = substringParagraphRanges(from: editedRange)
		
		let difference = paragraphsAfter.difference(from: paragraphsBefore)
		var changes = ParagraphRangeChange.from(difference: difference,
												baseOffset: indexesBeforeEditing.first!,
												baseParagraphRange: paragraphsBefore.first!,
												insertionLocation: editedRange.location)
		
		// if delta of edits is zero (user could just paste the same-length text over the same-length selected text)
		// make sure that the delegate will be notified of those changes, since the diff algorhythm won't recognize
		// any changes in that case
		guard changes.count != 0 && !editHasSameLength else {
			indexesBeforeEditing.forEach{
				changes.append(ParagraphRangeChange.editedParagraph(index: $0, range: paragraphRanges[$0]))
			}
			
			if let existingDelegate = paragraphDelegate {
				let descriptedChanges = ParagraphChange.from(rangeChanges: changes, textStorage: self)
				existingDelegate.textStorage(self, didChangeParagraphs: descriptedChanges)
			}
			
			return
		}
		
		var hasEditedChange = false
		changes.forEach{ change in
			if case ParagraphRangeChange.editedParagraph(index: _, range: _) = change { hasEditedChange = true }
		}
		
		// if there's 'next edited paragraph has same range as the first one' situation ...
		if nextEditedParagraphWillHaveRangeEqualWithFirst && !hasEditedChange {
			// we need to decrement removed indexes ...
			for (i, change) in changes.enumerated() {
				if case ParagraphRangeChange.removedParagraph(index: let index) = change {
					changes[i] = .removedParagraph(index: index - 1)
				}
			}
			// and to add the 'editedParagraph' change, so the delegate will be notified of edited paragraph
			changes.append(ParagraphRangeChange.editedParagraph(index: indexesBeforeEditing.first!, range: paragraphsAfter.first!))
		}
		
		var lastEditedIndex = 0
		for change in changes {
			switch change {
			case .removedParagraph(index: let index):
				paragraphRanges.remove(at: index)
				lastEditedIndex = lastEditedIndex == 0 ? 0 : lastEditedIndex - 1
			case .insertedParagraph(index: let index, range: let range):
				paragraphRanges.insert(range, at: index)
				lastEditedIndex = index
			case .editedParagraph(index: let index, range: let range):
				paragraphRanges[index] = range
				lastEditedIndex = index
			}
		}
		// ensure that first paragraph starts from 0 (in case if the first paragraph was deleted)
		paragraphRanges[0].location = 0
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
			var nextLocation = startingParagraphRange.max

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

		return paragraphRanges.firstIndex(where: { $0.contains(location) })!
	}
	
	
	public func paragraphIndexes(in range: NSRange) -> [Int] {
		guard length > 0 else { return [0] }
		
		// get paragraphs from the range
		var paragraphs = attributedSubstring(from: range).string.paragraphs
		if paragraphs.last?.isEmpty == true && editHasSameLength {
			paragraphs = paragraphs.dropLast()
		}

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
