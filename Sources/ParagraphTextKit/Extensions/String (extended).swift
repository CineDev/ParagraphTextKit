//
//  String (extended).swift
//  ParagraphTextKit
//
//  Created by Vitalii Vashchenko on 5/17/16.
//  Copyright © 2020 Vitalii Vashchenko. All rights reserved.
//

import Foundation

extension String {
	public var attributedPresentation: NSAttributedString {
		NSAttributedString(string: self)
	}
}

public extension String {
	var floatValue: Float {
		return (self as NSString).floatValue
	}
	
	var doubleValue: Double {
		return (self as NSString).doubleValue
	}
	
	var boolValue: Bool {
		return (self as NSString).boolValue
	}
	
	var integerValue: Int {
		return (self as NSString).integerValue
	}
	
	var unsignedValue: UInt {
		return UInt((self as NSString).integerValue)
	}
	
	var range: NSRange {
		NSRange(location: 0, length: length)
	}
	
	var endsWithNewline: Bool {
		!(last == nil || last?.isNewline == false)
	}
	
	func contains(_ set: CharacterSet) -> Bool {
		components(separatedBy: set).count > 1
	}
			
	subscript(range: NSRange) -> Substring {
		get {
			if range.location == NSNotFound {
				return ""
			} else {
				let swiftRange = Range(range, in: self)!
				return self[swiftRange]
			}
		}
	}
	
	/// Array of paragraphs of the string. Each paragraph except the last one ends with 'new line' character
	var paragraphs: [String] {
		var paragraphs = components(separatedBy: .newlines)
		for i in 0 ..< paragraphs.count {
			if i != paragraphs.count - 1 {
				paragraphs[i] += "\n"
			}
		}
		return paragraphs
	}
	
	/// Raw length of the string; unicode characters counts as sum of its scalars
	var length: Int {
		self.utf16.count
	}
	
	func utfParagraphRange(at location: Int) -> NSRange {
		(self as NSString).lineRange(for: NSRange(location: location, length: 0))
	}
}
