//
//  ParagraphDescriptor.swift
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
	/// ParagraphDescriptor structure describes a text paragraph.
	///
	/// The paragraph could be either a standalone instance, or might exist in some external NSTextStroage object or any of its subclasses.
	///
	/// Origin of the paragraph is errelevant, since ParagraphDescriptor structure has all the neccessary data to describe a paragraph.
	struct ParagraphDescriptor: Equatable {
		
		/// Range of the paragraph descriptor in a text storage
		public internal(set) var storageRange: NSRange

		/// Text representation of the descriptor's range in the text storage
		public internal(set) var attributedString: NSAttributedString
		
		/// Text content of the paragraph
		public var text: String {
			attributedString.string
		}
		
		public init(attributedString: NSAttributedString, storageRange: NSRange) {
			self.attributedString = attributedString
			self.storageRange = storageRange
		}
		
		public static func ==(lhs: ParagraphDescriptor, rhs: ParagraphDescriptor) -> Bool {
			return lhs.attributedString == rhs.attributedString && lhs.storageRange == rhs.storageRange
		}
	}
}
