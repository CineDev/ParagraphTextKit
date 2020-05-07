//
//  ParagraphDescriptor.swift
//  ParagraphTextKit
//
//  Created by Vitalii Vashchenko on 07.05.2020.
//  Copyright © 2020 Vitalii Vashchenko. All rights reserved.
//

import Foundation

public extension ParagraphTextStorage {
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
