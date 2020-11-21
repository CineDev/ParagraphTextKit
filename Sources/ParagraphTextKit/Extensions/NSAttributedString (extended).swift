////
//  NSAttributedString (extended).swift
//  ParagraphTextKit
//
//  Created by Vitalii Vashchenko on 11/21/20.
//  Copyright © 2020 Vitalii Vashchenko. All rights reserved.
//

import Foundation

public extension NSAttributedString {
	var range: NSRange {
		NSRange(location: 0, length: length)
	}
}
