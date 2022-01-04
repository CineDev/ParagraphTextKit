//
//  ParagraphRangeChange.swift
//  ParagraphTextKit
//
// 	Copyright (c) 2020 Vitalii Vashchenko
//
//	This software is released under the MIT License.
// 	https://opensource.org/licenses/MIT
//
//  Created by Vitalii Vashchenko on 5/7/2020.
//

import Foundation

internal extension ParagraphTextStorage {
	/// ParagraphRangeChange structure describes the changes been made to the text storage.
	///
	/// The difference from the ParagraphChange enum is that this operates with NSRanges only, not with
	/// substrings from the text storage, because it is slightly more time consuming operation.
	///
	/// Therefore ParagraphRangeChange structur is used only for the internal calculations
	enum ParagraphRangeChange {
		case insertedParagraph(index: Int, range: NSRange)
		case removedParagraph(index: Int)
		case editedParagraph(index: Int, range: NSRange)
		
		static func from(difference: CollectionDifference<NSRange>,
						 baseOffset: Int, baseParagraphRange: NSRange,
						 insertionLocation: Int) -> [Self] {
			guard !difference.isEmpty else { return [] }
			var changes = [Self]()
			
			// edited index will always be the first one, no matter if paragraphs was added or removes,
			// because that's how Apple's TextKit works
			var editedIndex: Int?
			var lastIndexEdited: Bool = false
			
			// make sure that some paragraph was edited
			if let insertion = difference.insertions.first {
				
				switch insertion {
				case .insert(offset: let insertOffset, element: let insertionRange, associatedWith: _):
					guard let deletion = difference.removals.first else { break }
					
					switch deletion {
					case .remove(offset: let removeOffset, element: let removedRange, associatedWith: _):
						
						// edited paragraph means that the removing and inserting changes are the same
						if insertOffset == removeOffset {
							// but if the first change happens outside of the first paragraph range,
							// then this is actually an exception from the rule that 'edited index will always be the first one'
							// and in this case the LAST index should be notified as 'edited index'
							if insertionLocation == baseParagraphRange.location && removedRange == baseParagraphRange && baseParagraphRange.max > 0 {
								if insertionRange.location == baseParagraphRange.location && difference.insertions.count > 1 ||
									removedRange.location == baseParagraphRange.location && difference.removals.count > 1 {
									// except the case when the whole text storage content has been deleted...
									// ... like when the user selects all the text and hits 'Delete'
									if removedRange.max > 0 && insertionRange.max == 0 { } else {
										lastIndexEdited = true
										break
									}
								}
							}
							
							// edited paragraph is alway corresponds to inserted change
							let paragraphIndex = insertOffset + baseOffset
							changes.append(.editedParagraph(index: paragraphIndex, range: insertionRange))
							editedIndex = insertOffset
						}
					default:
						break
					}
				default:
					break
				}
			}
			
			for change in difference {
				switch change {
				case .insert(offset: let offset, element: let insertionRange, associatedWith: _):
					let paragraphIndex = offset + baseOffset

					if lastIndexEdited && difference.insertions.last == change && difference.insertions.count > difference.removals.count ||
						lastIndexEdited && difference.insertions.first == change && difference.removals.count > difference.insertions.count {
						// append edited paragraph only if it has really changed
						if insertionRange.length != baseParagraphRange.length && difference.insertions.count > difference.removals.count {
							changes.append(.editedParagraph(index: paragraphIndex, range: insertionRange))
						}
						continue
					}
					
					guard offset != editedIndex else { continue }
					changes.append(.insertedParagraph(index: paragraphIndex, range: insertionRange))
					
				case .remove(offset: let offset, element: _, associatedWith: _):
					let paragraphIndex = offset + baseOffset

					if lastIndexEdited && difference.removals.first == change && difference.insertions.count > difference.removals.count ||
						lastIndexEdited && difference.removals.last == change && difference.removals.count > difference.insertions.count {
						if difference.removals.count > difference.insertions.count,
						   let firstInsertion = difference.insertions.first,
						   let lastTouched = difference.removals.last,
						   case CollectionDifference<NSRange>.Change.insert(offset: _, element: let range, associatedWith: _) = firstInsertion,
						   case CollectionDifference<NSRange>.Change.remove(offset: _, element: let touchedRange, associatedWith: _) = lastTouched {
							if touchedRange.length != range.length {
								changes.append(.editedParagraph(index: paragraphIndex, range: range))
							}
						}
						continue
					}

					guard offset != editedIndex else { continue }
					changes.append(.removedParagraph(index: paragraphIndex))
				}
			}
			
			return changes
		}
	}
}
