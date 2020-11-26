//
//  ParagraphChange.swift
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

public extension ParagraphTextStorage {
	/// Describes the changes been made to the text storage.
	///
	/// The difference from the ParagraphRangeChange enum is that this enum does a substring from the text storage
	/// to create a ParagraphDescriptor, which is a little more time consuming.
	/// Therefore ParagraphChange is using only for the delegate notifications, not for the internal calculations
	enum ParagraphChange {
		case insertedParagraph(index: Int, descriptor: ParagraphDescriptor)
		case removedParagraph(index: Int)
		case editedParagraph(index: Int, descriptor: ParagraphDescriptor)
		
		static func from(rangeChanges: [ParagraphRangeChange], textStorage: ParagraphTextStorage) -> [Self] {
			var changes = [Self]()
			guard !rangeChanges.isEmpty else { return changes }

			for rangeChange in rangeChanges {
				switch rangeChange {
				case .insertedParagraph(index: let index, range: let range):
					let attrString = textStorage.attributedSubstring(from: range)
					let paragraphDescriptor = ParagraphDescriptor(attributedString: attrString, storageRange: range)
					changes.append(insertedParagraph(index: index, descriptor: paragraphDescriptor))
				case .removedParagraph(index: let index):
					changes.append(removedParagraph(index: index))
				case .editedParagraph(index: let index, range: let range):
					let attrString = textStorage.attributedSubstring(from: range)
					let paragraphDescriptor = ParagraphDescriptor(attributedString: attrString, storageRange: range)
					changes.append(editedParagraph(index: index, descriptor: paragraphDescriptor))
				}
			}
			
			return changes
		}
	}
}
