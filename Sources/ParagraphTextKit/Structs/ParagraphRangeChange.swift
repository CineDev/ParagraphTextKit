//
//  ParagraphRangeChange.swift
//  ParagraphTextKit
//
//  Created by Vitalii Vashchenko on 07.05.2020.
//  Copyright © 2020 Vitalii Vashchenko. All rights reserved.
//

import Foundation

internal extension ParagraphTextStorage {
	/// Describes the changes been made to the text storage.
	///
	/// The difference from the ParagraphChange enum is that this operates with NSRanges only, not with
	/// a substring from the text storage, which is a little more time consuming.
	/// Therefore ParagraphRangeChange is using only for the internal calculations
	enum ParagraphRangeChange {
		case insertedParagraph(index: Int, range: NSRange)
		case removedParagraph(index: Int)
		case editedParagraph(index: Int, range: NSRange)
		
		static func from(difference: CollectionDifference<NSRange>, initialOffset: Int) -> [Self] {
			var changes = [Self]()
			guard !difference.isEmpty else { return changes }
			
			// edited index will always be the first one, no matter if paragraphs was added or removes,
			// because that's how Apple's TextKit works
			var editedIndex: Int?
			
			// make sure that some paragraph was edited
			if let insertion = difference.insertions.first {
				
				switch insertion {
				case .insert(offset: let insertOffset, element: let range, associatedWith: _):
					guard let deletion = difference.removals.first else { break }
					
					switch deletion {
					case .remove(offset: let removeOffset, element: _, associatedWith: _):
						
						// edited paragraph means that the removing and inserting changes are the same)
						if insertOffset == removeOffset {
							// edited paragraph is alway corresponds to inserted change
							let paragraphIndex = insertOffset + initialOffset
							changes.append(.editedParagraph(index: paragraphIndex, range: range))
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
				case .insert(offset: let offset, element: let range, associatedWith: _):
					guard offset != editedIndex else { continue }
					let paragraphIndex = offset + initialOffset
					changes.append(.insertedParagraph(index: paragraphIndex, range: range))
					
				case .remove(offset: let offset, element: _, associatedWith: _):
					guard offset != editedIndex else { continue }
					let paragraphIndex = offset + initialOffset
					changes.append(.removedParagraph(index: paragraphIndex))
				}
			}
			
			return changes
		}
	}
}
