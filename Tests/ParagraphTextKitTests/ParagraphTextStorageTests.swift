import XCTest
@testable import ParagraphTextKit

class Delegate: ParagraphTextStorageDelegate {
	var paragraphs: [String] = []
	var attributes: [[NSAttributedString.Key: Any]] = []
	
	var insertions: [Int] = []
	var removals: [Int] = []
	var editions: [Int] = []
	
	private var firstInit = true
	
	var ranges: [NSRange] {
		var location = 0
		
		return paragraphs.map { string -> NSRange in
			let range = NSRange(location: location, length: string.length)
			location = range.max
			return range
		}
	}
	
	var presentedParagraphs: [NSAttributedString] {
		paragraphs.map{ $0.attributedPresentation }
	}

	func textStorage(_ textStorage: ParagraphTextStorage, didChangeParagraphs changes: [ParagraphTextStorage.ParagraphChange]) {
		for change in changes {
			switch change {
			case .insertedParagraph(index: let index, descriptor: let paragraphDescriptor):
				if firstInit {
					firstInit = false
				} else {
					insertions.append(index)
				}
				
				paragraphs.insert(paragraphDescriptor.text, at: index)
				attributes.insert(attributes(from: paragraphDescriptor), at: index)
				
			case .removedParagraph(index: let index):
				paragraphs.remove(at: index)
				attributes.remove(at: index)
				removals.append(index)
				
			case .editedParagraph(index: let index, descriptor: let paragraphDescriptor):
				paragraphs[index] = paragraphDescriptor.text
				attributes[index] = attributes(from: paragraphDescriptor)
				editions.append(index)
			}
		}
	}
	
	func attributes(from paragraphDescriptor: ParagraphTextStorage.ParagraphDescriptor) -> [NSAttributedString.Key: Any] {
		if !paragraphDescriptor.text.isEmpty {
			return paragraphDescriptor.attributedString.attributes(at: 0, effectiveRange: nil)
		}
		return [:]
	}
}


// MARK: - Delegate Syncing Tests

final class ParagraphDelegateHasThreeCorrectInitialParagraphTest: XCTestCase {
	let textStorage = ParagraphTextStorage()
	let delegate = Delegate()

	override func setUp() {
		super.setUp()
		
		delegate.paragraphs.append("1\n")
		delegate.paragraphs.append("2\n")
		delegate.paragraphs.append("3")
		delegate.attributes.append([:])
		delegate.attributes.append([:])
		delegate.attributes.append([:])

		textStorage.paragraphDelegate = delegate
	}

	override func tearDown() {
		super.tearDown()
	}
	
	func testParagraphTextStorageDelegate() {
		XCTAssertTrue(textStorage.paragraphRanges.isEmpty == false,
					  "ParagraphTextStorage should have one paragraph descriptor at init")
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorageDelegate should have three paragraphs after the syncing")
		XCTAssertTrue(delegate.paragraphs[0] == "1\n",
					  "ParagraphTextStorageDelegate first paragraph should contain '1\n' string after the syncing")
		XCTAssertTrue(delegate.paragraphs[1] == "2\n",
					  "ParagraphTextStorageDelegate second paragraph should contain '2\n' string after the syncing")
		XCTAssertTrue(delegate.paragraphs[2] == "3",
					  "ParagraphTextStorageDelegate third paragraph should contain '3' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string == "1\n",
					  "ParagraphTextStorage first paragraph should contain '1\n' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string == "2\n",
					  "ParagraphTextStorage second paragraph should contain '2\n' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[2]).string == "3",
					  "ParagraphTextStorage third paragraph should contain '3' string after the syncing")
	}
}

final class ParagraphDelegateHasThreeMixedInitialParagraphTest: XCTestCase {
	let textStorage = ParagraphTextStorage()
	let delegate = Delegate()

	override func setUp() {
		super.setUp()
		
		delegate.paragraphs.append("1")
		delegate.paragraphs.append("2\n")
		delegate.paragraphs.append("3")
		delegate.attributes.append([:])
		delegate.attributes.append([:])
		delegate.attributes.append([:])

		textStorage.paragraphDelegate = delegate
	}

	override func tearDown() {
		super.tearDown()
	}
	
	func testParagraphTextStorageDelegate() {
		XCTAssertTrue(textStorage.paragraphRanges.isEmpty == false,
					  "ParagraphTextStorage should have one paragraph descriptor at init")
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorageDelegate should have three paragraphs after the syncing")
		XCTAssertTrue(delegate.paragraphs[0] == "1\n",
					  "ParagraphTextStorageDelegate first paragraph should contain '1\n' string after the syncing")
		XCTAssertTrue(delegate.paragraphs[1] == "2\n",
					  "ParagraphTextStorageDelegate second paragraph should contain '2\n' string after the syncing")
		XCTAssertTrue(delegate.paragraphs[2] == "3",
					  "ParagraphTextStorageDelegate third paragraph should contain '3' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string == "1\n",
					  "ParagraphTextStorage first paragraph should contain '1\n' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string == "2\n",
					  "ParagraphTextStorage second paragraph should contain '2\n' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[2]).string == "3",
					  "ParagraphTextStorage third paragraph should contain '3' string after the syncing")
	}
}


final class ParagraphDelegateHasTwoInitialParagraphTest: XCTestCase {
	let textStorage = ParagraphTextStorage()
	let delegate = Delegate()

	override func setUp() {
		super.setUp()
		
		delegate.paragraphs.append("1")
		delegate.paragraphs.append("2")
		delegate.attributes.append([:])
		delegate.attributes.append([:])

		textStorage.paragraphDelegate = delegate
	}

	override func tearDown() {
		super.tearDown()
	}
	
	func testParagraphTextStorageDelegate() {
		XCTAssertTrue(textStorage.paragraphRanges.isEmpty == false,
					  "ParagraphTextStorage should have one paragraph descriptor at init")
		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should have two paragraphs after the syncing")
		XCTAssertTrue(delegate.paragraphs[0] == "1\n",
					  "ParagraphTextStorageDelegate first paragraph should contain '1\n' string after the syncing")
		XCTAssertTrue(delegate.paragraphs[1] == "2",
					  "ParagraphTextStorageDelegate second paragraph should contain '2' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string == "1\n",
					  "ParagraphTextStorage first paragraph should contain '1\n' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string == "2",
					  "ParagraphTextStorage second paragraph should contain '2' string after the syncing")
	}
}

final class ParagraphDelegateHasTwoInitialIncorrectParagraphsTest: XCTestCase {
	let textStorage = ParagraphTextStorage()
	let delegate = Delegate()

	override func setUp() {
		super.setUp()
		
		delegate.paragraphs.append("1")
		delegate.paragraphs.append("2\n")
		delegate.attributes.append([:])
		delegate.attributes.append([:])

		textStorage.paragraphDelegate = delegate
	}

	override func tearDown() {
		super.tearDown()
	}
	
	func testParagraphTextStorageDelegate() {
		XCTAssertTrue(textStorage.paragraphRanges.isEmpty == false,
					  "ParagraphTextStorage should have one paragraph descriptor at init")
		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should have two paragraphs after the syncing")
		XCTAssertTrue(delegate.paragraphs[0] == "1\n",
					  "ParagraphTextStorageDelegate first paragraph should contain '1\n' string after the syncing")
		XCTAssertTrue(delegate.paragraphs[1] == "2",
					  "ParagraphTextStorageDelegate second paragraph should contain '2' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string == "1\n",
					  "ParagraphTextStorage first paragraph should contain '1\n' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string == "2",
					  "ParagraphTextStorage second paragraph should contain '2' string after the syncing")
	}
}

final class ParagraphDelegateHasOneInitialParagraphTest: XCTestCase {
	let textStorage = ParagraphTextStorage()
	let delegate = Delegate()

	override func setUp() {
		super.setUp()
		
		delegate.paragraphs.append("1")
		delegate.attributes.append([:])

		textStorage.paragraphDelegate = delegate
	}

	override func tearDown() {
		super.tearDown()
	}
	
	func testParagraphTextStorageDelegate() {
		XCTAssertTrue(textStorage.paragraphRanges.isEmpty == false,
					  "ParagraphTextStorage should have one paragraph descriptor at init")
		XCTAssertTrue(textStorage.paragraphRanges.count == 1,
					  "ParagraphTextStorage should have one paragraph after the syncing")
		XCTAssertTrue(delegate.paragraphs[0] == "1",
					  "ParagraphTextStorageDelegate first paragraph should contain '1' string after the syncing")
		XCTAssertTrue(textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string == "1",
					  "ParagraphTextStorage first paragraph should contain '1' string after the syncing")
	}
}



// MARK: - ParagraphTextStorage Algorhythm Tests

final class ParagraphTextStorageTests: XCTestCase {
	let textStorage = ParagraphTextStorage()
	let delegate = Delegate()

    override func setUp() {
        super.setUp()
		
		textStorage.paragraphDelegate = delegate
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testParagraphTextStorage_Initialization() {
		let textStorage = ParagraphTextStorage()
		XCTAssertTrue(textStorage.paragraphRanges.isEmpty == false,
					  "ParagraphTextStorage should have one paragraph descriptor at init")
	}
	
	
	// MARK: - Attribute Changing Tests
	
	func testParagraphTextStorage_ChangeAttributes() {
		let string = "First paragraph\nSecond paragraph"
		XCTAssertTrue(delegate.insertions.count == 0 && delegate.editions.count == 0 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()

		XCTAssertTrue(delegate.insertions.count == 1 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: string.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: string.paragraphs[1].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
					  textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
		
		#if !os(macOS)
		textStorage.beginEditing()
		textStorage.setAttributes([.foregroundColor: UIColor.lightText], range: secondRange)
		textStorage.endEditing()

		XCTAssertTrue(delegate.insertions.count == 1 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.attributes[0].isEmpty &&
					  delegate.attributes[1][.foregroundColor] as? UIColor == UIColor.lightText,
					  "ParagraphTextStorage delegate attributes should match the ParagraphTextStorage")
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
					  textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")

		#else
		textStorage.beginEditing()
		textStorage.setAttributes([.foregroundColor: NSColor.textColor], range: secondRange)
		textStorage.endEditing()

		XCTAssertTrue(delegate.insertions.count == 1 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.attributes[0].isEmpty &&
					  delegate.attributes[1][.foregroundColor] as? NSColor == NSColor.textColor,
					  "ParagraphTextStorage delegate attributes should match the ParagraphTextStorage")
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
					  textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")

		#endif
	}

	
	// MARK: - Insertion Tests
	
	func testParagraphTextStorage_InsertNewLineInMiddleHeap() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph\nFourthParagraph\nFifthParagraph"
		let editString = "\n"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange.zero, with: string)
		textStorage.endEditing()

		XCTAssertTrue(delegate.insertions.count == 4 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")
		
		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3 && delegate.insertions[3] == 4)
		XCTAssertTrue(delegate.editions[0] == 0)
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 33, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 5 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3 && delegate.insertions[3] == 4 && delegate.insertions[4] == 2)
		XCTAssertTrue(delegate.editions[0] == 0)

		let endString = "First paragraph\nSecond paragraph\n\nThirdParagraph\nFourthParagraph\nFifthParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 6,
					  "ParagraphTextStorage should now have 6 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)
		let fifthRange = NSRange(location: NSMaxRange(fourthRange), length: endString.paragraphs[4].length)
		let sixthRange = NSRange(location: NSMaxRange(fifthRange), length: endString.paragraphs[5].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange &&
			textStorage.paragraphRanges[4] == fifthRange &&
			textStorage.paragraphRanges[5] == sixthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_InsertThreeNewLinesInMiddleHeap() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph\nFourthParagraph\nFifthParagraph"
		let editString = "\n\n\n"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange.zero, with: string)
		textStorage.endEditing()

		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 33, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 7 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3 && delegate.insertions[3] == 4 && delegate.insertions[4] == 2 && delegate.insertions[5] == 3 && delegate.insertions[6] == 4)
		XCTAssertTrue(delegate.editions[0] == 0)

		let endString = "First paragraph\nSecond paragraph\n\n\n\nThirdParagraph\nFourthParagraph\nFifthParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 8,
					  "ParagraphTextStorage should now have 8 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)
		let fifthRange = NSRange(location: NSMaxRange(fourthRange), length: endString.paragraphs[4].length)
		let sixthRange = NSRange(location: NSMaxRange(fifthRange), length: endString.paragraphs[5].length)
		let seventhRange = NSRange(location: NSMaxRange(sixthRange), length: endString.paragraphs[6].length)
		let eighthRange = NSRange(location: NSMaxRange(seventhRange), length: endString.paragraphs[7].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange &&
			textStorage.paragraphRanges[4] == fifthRange &&
			textStorage.paragraphRanges[5] == sixthRange &&
			textStorage.paragraphRanges[6] == seventhRange &&
			textStorage.paragraphRanges[7] == eighthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}


	func testParagraphTextStorage_InsertFirstParagraphs() {
		let string = "First paragraph\nSecond paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 1 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1)
		XCTAssertTrue(delegate.editions[0] == 0)

		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: string.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: string.paragraphs[1].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
					  textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_InsertEmptyAtBeginning() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph"
		let editString = "\n"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 0)
		XCTAssertTrue(delegate.editions[0] == 0)

		let endString = "\nFirst paragraph\nSecond paragraph\nThirdParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_InsertNonemptyAtBeginning() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph"
		let editString = "\naddition"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 0)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 1)

		let endString = "\nadditionFirst paragraph\nSecond paragraph\nThirdParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_InsertEmptyInMiddle() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph"
		let editString = "\n"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 3, length: 5), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 1)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)

		let endString = "Fir\nragraph\nSecond paragraph\nThirdParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_InsertNonemptyInMiddle() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph"
		let editString = "\naddition"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 3, length: 5), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 1)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)

		let endString = "Fir\nadditionragraph\nSecond paragraph\nThirdParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
					  textStorage.paragraphRanges[1] == secondRange &&
					  textStorage.paragraphRanges[2] == thirdRange &&
					  textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_InsertEmptyBetweenParagraphs() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph"
		let editString = "\n"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 16, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 1)
		XCTAssertTrue(delegate.editions[0] == 0)

		let endString = "First paragraph\n\nSecond paragraph\nThirdParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_InsertEmptyBetweenParagraphs2() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph"
		let editString = "\n"

		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()

		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 32, length: 0), with: editString)
		textStorage.endEditing()

		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 2)
		XCTAssertTrue(delegate.editions[0] == 0)

		let endString = "First paragraph\nSecond paragraph\n\nThirdParagraph"

		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")

		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")

		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_InsertNonemptyBetweenParagraphs() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph"
		let editString = "addition\n"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 16, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 1)
		XCTAssertTrue(delegate.editions[0] == 0)

		let endString = "First paragraph\naddition\nSecond paragraph\nThirdParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_InsertEmptyAtEnd() {
		let string = "First paragraph\nSecond paragraph\nThird"
		let editString = "\n"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: string.length, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")
		
		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 2)

		let endString = "First paragraph\nSecond paragraph\nThird\n"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_InsertNonemptyAtEnd() {
		let string = "First paragraph\nSecond paragraph\nThird"
		let editString = "\naddition"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: string.length, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 2)

		let endString = "First paragraph\nSecond paragraph\nThird\naddition"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	
	
	// MARK: - Editing Tests
	
	func testParagraphTextStorage_EditFirstParagraph() {
		let string = "First paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()

		XCTAssertTrue(delegate.insertions.count == 0 && delegate.editions.count == 1 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.editions[0] == 0)

		let endString = "First paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 1,
					  "ParagraphTextStorage should now have 1 paragraph")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_EditParagraphAtBeginning() {
		let string = "First paragraph\nSecond paragraph\nThirdParagraph"
		let editString = "addition"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 2 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)

		let endString = "additionFirst paragraph\nSecond paragraph\nThirdParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_EditParagraphInMiddle() {
		let string = "First paragraph\nSecond paragraph"
		let editString = "addition"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 3, length: 5), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 1 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)

		let endString = "Firadditionragraph\nSecond paragraph"

		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_EditParagraphWithSameLengthEdit() {
		let string = "First paragraph\nSecond paragraph"
		let editString = "additions"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 6, length: 9), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 1 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)

		let endString = "First additions\nSecond paragraph"

		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_EditMultipleParagraphWithSameLengthEdit() {
		let string = "First paragraph\nSecond paragraph\nThird paragraph"
		let editString = "First paragraph\nSecond paragraph\n"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 33), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 2 && delegate.editions.count == 4 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0 && delegate.editions[2] == 1 && delegate.editions[3] == 2)

		let endString = "First paragraph\nSecond paragraph\nThird paragraph"

		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
						textStorage.paragraphRanges[1] == secondRange &&
						textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	
	func testParagraphTextStorage_EditParagraphAtEnd() {
		let string = "First paragraph\nSecond paragraph"
		let editString = "addition"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: string.length, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 1 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 1)

		let endString = "First paragraph\nSecond paragraphaddition"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_EditEmptyParagraphAtEnd() {
		let string = "First paragraph\nSecond paragraph\n"
		let editString = "a"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: string.length, length: 0), with: editString)
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 2 && delegate.editions.count == 2 && delegate.removals.count == 0,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 2)

		let endString = "First paragraph\nSecond paragraph\na"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	
	// MARK: - Deletion Tests
	
	func testParagraphTextStorage_DeleteParagraphInMiddle() {
		let string = "First paragraph\nSecond paragraph\nThird paragraph\nFourth paragraph"

		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 15, length: 5), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 1,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)
		XCTAssertTrue(delegate.removals[0] == 1)

		let endString = "First paragraphnd paragraph\nThird paragraph\nFourth paragraph"

		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_DeleteParagraphAtEnd() {
		let string = "First paragraph\nSecond paragraph\nThird paragraph"

		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()

		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 32, length: 5), with: "")
		textStorage.endEditing()

		XCTAssertTrue(delegate.insertions.count == 2 && delegate.editions.count == 2 && delegate.removals.count == 1,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 1)
		XCTAssertTrue(delegate.removals[0] == 2)

		let endString = "First paragraph\nSecond paragraphd paragraph"

		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")

		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)

		

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")

		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2,
					  "ParagraphTextStorage strings should match the test trings")

		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_DeleteEmptyParagraphAtEnd() {
		let string = "First paragraph\nSecond paragraph\nThird paragraph\n"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: string.length - 1, length: 1), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 1,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 2)
		XCTAssertTrue(delegate.removals[0] == 3)

		let endString = "First paragraph\nSecond paragraph\nThird paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		let storageSubstring3 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[2]).string
		let testSubstring3 = String(endString[Range(thirdRange, in: endString)!])
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2 &&
			storageSubstring3 == testSubstring3,
					   "ParagraphTextStorage strings should match the test trings")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_DeleteWholeParagraphAtBeginning() {
		let string = "First paragraph\nSecond paragraph\nThird paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: string.paragraphs[0].length), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 2 && delegate.editions.count == 1 && delegate.removals.count == 1,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2)
		XCTAssertTrue(delegate.editions[0] == 0)
		XCTAssertTrue(delegate.removals[0] == 0)

		let endString = "Second paragraph\nThird paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2,
					   "ParagraphTextStorage strings should match the test trings")

		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_DeleteWholeParagraphInMiddle() {
		let string = "First paragraph\nSecond paragraph\nThird paragraph\nFourth paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 16, length: string.paragraphs[1].length), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 1 && delegate.removals.count == 1,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3)
		XCTAssertTrue(delegate.editions[0] == 0)
		XCTAssertTrue(delegate.removals[0] == 1)

		let endString = "First paragraph\nThird paragraph\nFourth paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_DeleteWholeParagraphAtEnd() {
		let string = "First paragraph\nSecond paragraph\nThird paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 32, length: string.paragraphs[2].length + 1), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 2 && delegate.editions.count == 2 && delegate.removals.count == 1,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 1)
		XCTAssertTrue(delegate.removals[0] == 2)

		let endString = "First paragraph\nSecond paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		print(endString.paragraphs[1])
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		
		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2,
					   "ParagraphTextStorage strings should match the test trings")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_DeleteAllParagraphs() {
		let string = "First paragraph\nSecond paragraph\nThird paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: string.length), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 2 && delegate.editions.count == 2 && delegate.removals.count == 2,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)
		XCTAssertTrue(delegate.removals[0] == 2)
		XCTAssertTrue(delegate.removals[1] == 1)
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 1,
					  "ParagraphTextStorage should now have 1 paragraphs")
		XCTAssertTrue(delegate.paragraphs[0].isEmpty)
	}

	
	// MARK: - Mixed Tests
	
	func testParagraphTextStorage_DeleteWholeParagraphAtBeginningAndEditNextOneWithSameFinalRanges() {
		let string = "First paragraph\nSecond💋 paragraph\nThird paragraph\nFourth paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: string.paragraphs[0].length + 3), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 1,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)
		XCTAssertTrue(delegate.removals[0] == 0)

		let endString = "ond💋 paragraph\nThird paragraph\nFourth paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		let storageSubstring3 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[2]).string
		let testSubstring3 = String(endString[Range(thirdRange, in: endString)!])
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2 &&
			storageSubstring3 == testSubstring3,
					   "ParagraphTextStorage strings should match the test trings")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_DeleteTwoParagraphAtBeginningAndEditNextOneWithSameFinalRanges() {
		let string = "First paragraph\nSecond💋 paragraph\nSecond💋 paragraph\nFourth paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: string.paragraphs[0].length + string.paragraphs[1].length + 3), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 2,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)
		XCTAssertTrue(delegate.removals[0] == 1 && delegate.removals[1] == 0)

		let endString = "ond💋 paragraph\nFourth paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)

		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2,
					   "ParagraphTextStorage strings should match the test trings")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_DeleteWholeParagraphAtBeginningAndEditNextOne() {
		let string = "First paragraph\nSecond💋 paragraph!\nThird paragraph\nFourth paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: string.paragraphs[0].length + 3), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 3 && delegate.editions.count == 2 && delegate.removals.count == 1,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 1)
		XCTAssertTrue(delegate.removals[0] == 0)

		let endString = "ond💋 paragraph!\nThird paragraph\nFourth paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		let storageSubstring3 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[2]).string
		let testSubstring3 = String(endString[Range(thirdRange, in: endString)!])
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2 &&
			storageSubstring3 == testSubstring3,
					   "ParagraphTextStorage strings should match the test trings")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}

	func testParagraphTextStorage_DeleteWholeTwoParagraphsAtBeginningAndEditNextOne() {
		let string = "First paragraph\nSeco💋nd paragraph\nThird paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 35 + 3), with: "")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 2 && delegate.editions.count == 2 && delegate.removals.count == 2,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 2)
		XCTAssertTrue(delegate.removals[0] == 1 && delegate.removals[1] == 0)

		let endString = "rd paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 1,
					  "ParagraphTextStorage should now have 1 paragraph")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_DeleteWholeTwoParagraphsAtBeginningEditingTheNextOneAndInsertNewParagraph() {
		let string = "First paragraph\nSecond pa💋ragraph\nThird paragraph\nFourth paragraph"

		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()

		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 35 + 3), with: "new paragraph\n")
		textStorage.endEditing()

		XCTAssertTrue(delegate.insertions.count == 4 && delegate.editions.count == 2 && delegate.removals.count == 2,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3 && delegate.insertions[3] == 1)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 2)
		XCTAssertTrue(delegate.removals[0] == 1 && delegate.removals[1] == 0)

		let endString = "new paragraph\nrd paragraph\nFourth paragraph"

		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")

		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		let storageSubstring3 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[2]).string
		let testSubstring3 = String(endString[Range(thirdRange, in: endString)!])
		
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2 &&
			storageSubstring3 == testSubstring3,
					   "ParagraphTextStorage strings should match the test trings")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")

		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_DeleteTwoParagraphsInMiddleEditingTheNextOneAndInsertNewParagraph() {
		let string = "First paragraph\nSecond parag💋raph\nThird paragraph\nFourth paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 15, length: 18 + 3), with: "new paragraph\n")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions.count == 4 && delegate.editions.count == 2 && delegate.removals.count == 2,
					  "ParagraphTextStorage paragraph delegate should be notified of exact changes")

		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3 && delegate.insertions[3] == 1)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 0)
		XCTAssertTrue(delegate.removals[0] == 2 && delegate.removals[1] == 1)

		let endString = "First paragraphnew paragraph\nhird paragraph\nFourth paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		let storageSubstring3 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[2]).string
		let testSubstring3 = String(endString[Range(thirdRange, in: endString)!])
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2 &&
			storageSubstring3 == testSubstring3,
					   "ParagraphTextStorage strings should match the test trings")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_DeleteOneParagraphInMiddleEditingTheNextOneAndInsertNewParagraph() {
		let string = "First paragraph\nSecond parag💋raph\nThird paragraph\nFourth paragraph"
		let location = (string.paragraphs[0].length + string.paragraphs[1].length) - 1
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: location, length: 3), with: "new paragraph\n")
		textStorage.endEditing()
		
		XCTAssertTrue(delegate.insertions[0] == 1 && delegate.insertions[1] == 2 && delegate.insertions[2] == 3 && delegate.insertions[3] == 2)
		XCTAssertTrue(delegate.editions[0] == 0 && delegate.editions[1] == 1)
		XCTAssertTrue(delegate.removals[0] == 2)

		let endString = "First paragraph\nSecond parag💋raphnew paragraph\nird paragraph\nFourth paragraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)

		let storageSubstring1 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[0]).string
		let testSubstring1 = String(endString[Range(firstRange, in: endString)!])
		let storageSubstring2 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[1]).string
		let testSubstring2 = String(endString[Range(secondRange, in: endString)!])
		let storageSubstring3 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[2]).string
		let testSubstring3 = String(endString[Range(thirdRange, in: endString)!])
		let storageSubstring4 = textStorage.attributedSubstring(from: textStorage.paragraphRanges[3]).string
		let testSubstring4 = String(endString[Range(fourthRange, in: endString)!])
		XCTAssertTrue( storageSubstring1 == testSubstring1 &&
			storageSubstring2 == testSubstring2 &&
			storageSubstring3 == testSubstring3 &&
			storageSubstring4 == testSubstring4,
					   "ParagraphTextStorage strings should match the test trings")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_IncrementallyAddAndEditParagraphAtEndAndPeriodicallyInsertNewParagraphInMiddle() {
		var lastRange = NSRange(location: 0, length: textStorage.length)
		var ranges = [lastRange]
		var endString = ""
		var additionallyAdded = 0
		
		for i in 0 ..< 50 {
			// every 10 iterations, remove and add the range
			if i % 10 == 0, i > 0 {
				let index = i - 5
				let range = textStorage.paragraphRanges[index]
				let addRange = NSRange(location: range.location, length: 0)
				textStorage.beginEditing()
				textStorage.replaceCharacters(in: addRange, with: "\n")
				textStorage.endEditing()
				endString.insert("\n", at: Range(addRange, in: endString)!.upperBound)
				
				let string = String(describing: i)
				let editRange = NSRange(location: addRange.max, length: 0)
				textStorage.beginEditing()
				textStorage.replaceCharacters(in: editRange, with: string)
				textStorage.endEditing()
				endString.insert(contentsOf: string, at: Range(editRange, in: endString)!.upperBound)
				let changedRange = NSRange(location: addRange.location, length: 1 + string.count)
				ranges.insert(changedRange, at: index)
				
				for idx in index + 1 ..< ranges.count {
					ranges[idx].location += 1 + string.count
				}
				lastRange = NSRange(location: textStorage.length, length: 0)
				additionallyAdded += 1
			}

			let string = String(describing: i)
			textStorage.beginEditing()
			textStorage.replaceCharacters(in: lastRange, with: string)
			textStorage.endEditing()
			endString += string
			lastRange.length += string.count
			
			textStorage.beginEditing()
			textStorage.replaceCharacters(in: NSRange(location: lastRange.max, length: 0), with: "\n")
			textStorage.endEditing()
			lastRange.length += 1
			
			endString += "\n"
			ranges[i + additionallyAdded] = lastRange
			
			lastRange = NSRange(location: textStorage.length, length: 0)
			ranges.append(lastRange)
		}
		
		XCTAssertTrue(textStorage.paragraphRanges.count == ranges.count,
					  "ParagraphTextStorage should now have \(ranges.count) paragraph descriptors")
		
		let storageRanges = textStorage.paragraphRanges
		
		XCTAssertTrue(storageRanges == ranges,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_IncrementallyAddAndEditParagraphAtEndAndThenDeleteBunchOfThem() {
		var lastRange = NSRange(location: 0, length: textStorage.length)

		for i in 0 ..< 50 {
			let string = String(describing: i)
			textStorage.beginEditing()
			textStorage.replaceCharacters(in: lastRange, with: string)
			textStorage.endEditing()
			lastRange.length += string.count
			
			textStorage.beginEditing()
			textStorage.replaceCharacters(in: NSRange(location: lastRange.max, length: 0), with: "\n")
			textStorage.endEditing()
			lastRange.length += 1
			
			lastRange = NSRange(location: textStorage.length, length: 0)
		}
		
		let range = NSRange(location: 5, length: textStorage.length - 10)
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: range, with: "")
		textStorage.endEditing()

		let endStrig = "0\n1\n28\n49\n"
		let endParagraphs = endStrig.paragraphs
		var paragraphs: [NSRange] = []
		var theRange = NSRange.zero
		for paragraph in endParagraphs {
			theRange = NSRange(location: theRange.max, length: paragraph.count)
			paragraphs.append(theRange)
		}

		XCTAssertTrue(textStorage.paragraphRanges.count == paragraphs.count,
					  "ParagraphTextStorage should now have \(paragraphs.count) paragraph descriptors")
		
		let storageRanges = textStorage.paragraphRanges
		
		XCTAssertTrue(storageRanges == paragraphs,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_ReplaceAllParagraphsWithTwoNewParagraphs() {
		let string = "First paragraph\nSecond 💋paragraph\nThird paragraph"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: string.length), with: "new paragraph\nanotherParagraph")
		textStorage.endEditing()
		
		let endString = "new paragraph\nanotherParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_InsertBlankParagraphInMiddleAndInsertAnotherOne() {
		let string = "First paragraph\nSecond paragraph\nThird paragraph\nFourthOne"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 16, length: 0), with: "\n")
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 34, length: 0), with: "\n")
		textStorage.endEditing()
		
		let endString = "First paragraph\n\nSecond paragraph\n\nThird paragraph\nFourthOne"
		let endParagraphs = endString.paragraphs
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 6,
					  "ParagraphTextStorage should now have 6 paragraph descriptors")
		
		var paragraphs: [NSRange] = []
		var lastRange = NSRange.zero
		for paragraph in endParagraphs {
			lastRange = NSRange(location: lastRange.max, length: paragraph.count)
			paragraphs.append(lastRange)
		}

		let storageRanges = textStorage.paragraphRanges
		XCTAssertTrue(storageRanges == paragraphs,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_DeleteParagraphInMiddleAndEditingTheNextOne() {
		let string = "First paragraph\nSecond paragraph💋\nThirdParagraph"
		let editString = "\naddition"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 15, length: 1), with: editString)
		textStorage.endEditing()
		
		let endString = "First paragraph\nadditionSecond paragraph💋\nThirdParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		
		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_InsertBetweenParagraphsBlankParagraphEditingTheNextOne() {
		let string = "First paragraph\nSe🤙cond paragraph\nThirdParagraph"
		let editString = "\naddition"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 16, length: 1), with: editString)
		textStorage.endEditing()
		
		let endString = "First paragraph\n\nadditione🤙cond paragraph\nThirdParagraph"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 4,
					  "ParagraphTextStorage should now have 4 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)
		let fourthRange = NSRange(location: NSMaxRange(thirdRange), length: endString.paragraphs[3].length)

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange &&
			textStorage.paragraphRanges[3] == fourthRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")
	}
	
	func testParagraphTextStorage_IncrementalEditingAndInsertingParagraph() {
		let string = "1"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 1, length: 0), with: "\n")
		textStorage.endEditing()
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 2, length: 0), with: "2")
		textStorage.endEditing()
		let endString = "1\n2"

		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
	}
	
	func testParagraphTextStorage_IncrementalEditingAndMakeFirstParagraphEmpty() {
		let string = "1\n2"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 1), with: "")
		textStorage.endEditing()
		let endString = "\n2"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
	}
	
	func testParagraphTextStorage_IncrementalEditingAndMakeMiddleParagraphEmpty() {
		let string = "1\n2\n3"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 2, length: 1), with: "")
		textStorage.endEditing()
		let endString = "1\n\n3"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 3,
					  "ParagraphTextStorage should now have 3 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		let thirdRange = NSRange(location: NSMaxRange(secondRange), length: endString.paragraphs[2].length)

		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange &&
			textStorage.paragraphRanges[2] == thirdRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
	}
	
	func testParagraphTextStorage_IncrementalEditingAndMakeLastParagraphEmpty() {
		let string = "1\n2"
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: string)
		textStorage.endEditing()
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSRange(location: 2, length: 1), with: "")
		textStorage.endEditing()
		let endString = "1\n"
		
		XCTAssertTrue(textStorage.paragraphRanges.count == 2,
					  "ParagraphTextStorage should now have 2 paragraphs")
		
		let firstRange = NSRange(location: 0, length: endString.paragraphs[0].length)
		let secondRange = NSRange(location: NSMaxRange(firstRange), length: endString.paragraphs[1].length)
		
		XCTAssertEqual(textStorage.paragraphRanges, delegate.ranges,
					   "ParagraphTextStorage paragraph ranges should match the delegate ranges")

		XCTAssertTrue(textStorage.paragraphRanges[0] == firstRange &&
			textStorage.paragraphRanges[1] == secondRange,
					  "ParagraphTextStorage paragraph ranges should be correct")
	}

	
    static var allTests = [
        ("test for initialization", testParagraphTextStorage_Initialization),
		
		// insertion tests
		("test for inserting a new line character into the middle of text heap", testParagraphTextStorage_InsertNewLineInMiddleHeap),
		("test for inserting three new line characters into the middle of text heap", testParagraphTextStorage_InsertThreeNewLinesInMiddleHeap),
		("test for inserting following paragraphs", testParagraphTextStorage_InsertFirstParagraphs),
		("test for inserting an empty paragraph at the beginning", testParagraphTextStorage_InsertEmptyAtBeginning),
		("test for inserting an non-empty paragraph at the beginning", testParagraphTextStorage_InsertNonemptyAtBeginning),
		("test for inserting an empty paragraph in the middle", testParagraphTextStorage_InsertEmptyInMiddle),
		("test for inserting an non-empty paragraph in the middle", testParagraphTextStorage_InsertNonemptyInMiddle),
		("test for inserting an empty paragraph between two paragraphs", testParagraphTextStorage_InsertEmptyBetweenParagraphs),
		("test for inserting an non-empty paragraph between two paragraphs", testParagraphTextStorage_InsertNonemptyBetweenParagraphs),
		("test for inserting an empty paragraph between two other paragraphs", testParagraphTextStorage_InsertEmptyBetweenParagraphs2),
		("test for inserting an empty paragraph at the end", testParagraphTextStorage_InsertEmptyAtEnd),
		("test for inserting an non-empty paragraph at the end", testParagraphTextStorage_InsertNonemptyAtEnd),
		
		// editing tests
		("test for editing the first paragraph when there's no other paragraphs", testParagraphTextStorage_EditFirstParagraph),
		("test for editing the first paragraph among other paragraphs", testParagraphTextStorage_EditParagraphAtBeginning),
		("test for editing the second paragraph among other paragraphs", testParagraphTextStorage_EditParagraphInMiddle),
		("test for editing the last paragraph among other paragraphs", testParagraphTextStorage_EditParagraphAtEnd),
		("test for editing the last empty paragraph", testParagraphTextStorage_EditEmptyParagraphAtEnd),
		
		// deletion tests
		("test for deleting the paragraph between other paragraphs", testParagraphTextStorage_DeleteParagraphInMiddle),
		("test for deleting the last paragraph", testParagraphTextStorage_DeleteParagraphAtEnd),
		("test for deleting the last empty paragraph", testParagraphTextStorage_DeleteEmptyParagraphAtEnd),
		("test for deleting the whole paragraph at the beginning", testParagraphTextStorage_DeleteWholeParagraphAtBeginning),
		("test for deleting the whole paragraph in the middle", testParagraphTextStorage_DeleteWholeParagraphInMiddle),
		("test for deleting the whole paragraph at the end", testParagraphTextStorage_DeleteWholeParagraphAtEnd),
		
		// mixed operations tests
		("test for deleting the paragraph at the beginning and editing the following one", testParagraphTextStorage_DeleteWholeParagraphAtBeginningAndEditNextOne),
		("test for deleting the paragraph at the beginning, editing the following one (when the resulting ranges are equal",
			testParagraphTextStorage_DeleteWholeParagraphAtBeginningAndEditNextOneWithSameFinalRanges),
		("test for deleting the two paragraphs at the beginning, editing the following one (when the resulting ranges are equal",
			testParagraphTextStorage_DeleteTwoParagraphAtBeginningAndEditNextOneWithSameFinalRanges),
		("test for deleting the two paragraphs at the beginning, editing the following one", testParagraphTextStorage_DeleteWholeTwoParagraphsAtBeginningAndEditNextOne),
		("test for deleting the two paragraphs at the beginning and editing the following paragraph and inserting a new one", testParagraphTextStorage_DeleteWholeTwoParagraphsAtBeginningEditingTheNextOneAndInsertNewParagraph),
		("test for deleting two paragraphs in the middle, editing the following paragraph and inserting a new one", testParagraphTextStorage_DeleteTwoParagraphsInMiddleEditingTheNextOneAndInsertNewParagraph),
		("test for deleting one paragraph in the middle, editing the following paragraph and inserting a new one", testParagraphTextStorage_DeleteOneParagraphInMiddleEditingTheNextOneAndInsertNewParagraph),
		("test for incrementally adding and editing paragraphs at the end and periodically insert a new paragraph in the middle", testParagraphTextStorage_IncrementallyAddAndEditParagraphAtEndAndPeriodicallyInsertNewParagraphInMiddle),
		("test for incrementally adding and editing paragraphs at the end and then deleting some of them", testParagraphTextStorage_IncrementallyAddAndEditParagraphAtEndAndThenDeleteBunchOfThem),
		("test for replacing all of the existing paragraphs with the two new paragraphs", testParagraphTextStorage_ReplaceAllParagraphsWithTwoNewParagraphs),
		("test for inserting an empty paragraph in the middle and then inserting another one", testParagraphTextStorage_InsertBlankParagraphInMiddleAndInsertAnotherOne),
		("test for deleting a paragraph in the middle and editing the next one", testParagraphTextStorage_DeleteParagraphInMiddleAndEditingTheNextOne),
		("test for inserting an empty paragraph in the middle and edinging the following one", testParagraphTextStorage_InsertBetweenParagraphsBlankParagraphEditingTheNextOne),
		("test for incrementally editing and inserting paragraphs", testParagraphTextStorage_IncrementalEditingAndInsertingParagraph),
		("test for incrementally editing paragraphs and make the first one empty", testParagraphTextStorage_IncrementalEditingAndMakeFirstParagraphEmpty),
		("test for incrementally editing paragraphs and make the middle one empty", testParagraphTextStorage_IncrementalEditingAndMakeMiddleParagraphEmpty),
		("test for incrementally editing paragraphs and make the last one empty", testParagraphTextStorage_IncrementalEditingAndMakeLastParagraphEmpty)
	]
}
