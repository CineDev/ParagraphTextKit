////
//  NSAttributedString (extended).swift
//  ParagraphTextKit
//
// 	Copyright (c) 2020 Vitalii Vashchenko
//
//	This software is released under the MIT License.
// 	https://opensource.org/licenses/MIT
//
//  Created by Vitalii Vashchenko on 11/21/20.
//

import Foundation

public extension NSAttributedString {
	var range: NSRange {
		NSRange(location: 0, length: length)
	}
}
