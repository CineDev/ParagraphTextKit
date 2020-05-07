//
//  ParagraphChange.swift
//  ParagraphTextKit
//
//  Created by Vitalii Vashchenko on 07.05.2020.
//  Copyright © 2020 Vitalii Vashchenko. All rights reserved.
//

import Foundation

public extension ParagraphTextStorage {
	enum ParagraphChange {
		case insertedParagraph(index: Int, descriptor: ParagraphDescriptor)
		case removedParagraph(index: Int)
		case editedParagraph(index: Int, descriptor: ParagraphDescriptor)
		
		static func from(difference: CollectionDifference<NSRange>, initialOffset: Int, textStorage: ParagraphTextStorage) -> [Self] {
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
							let substring = textStorage.attributedSubstring(from: range)
							let editedDescriptor = ParagraphTextStorage.ParagraphDescriptor(attributedString: substring, storageRange: range)
							changes.append(.editedParagraph(index: paragraphIndex, descriptor: editedDescriptor))
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
					let substring = textStorage.attributedSubstring(from: range)
					let addedDescriptor = ParagraphTextStorage.ParagraphDescriptor(attributedString: substring, storageRange: range)
					changes.append(.insertedParagraph(index: paragraphIndex, descriptor: addedDescriptor))
					
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
