//
//  NSRange (extended).swift
//  ParagraphTextKit
//
//  Created by Vitalii Vashchenko on 07.05.2020.
//  Copyright © 2020 Vitalii Vashchenko. All rights reserved.
//

import Foundation

public extension NSRange {
	var startIndex:Int { get { return location } }
	var endIndex:Int { get { return location + length } }
	
	var asRange:CountableRange<Int> { get { return location..<location + length } }
	
	var isEmpty:Bool { get { return length == 0 } }

	static var zero: NSRange {
		return NSRange(location: 0, length: 0)
	}

	var max: Int {
		return NSMaxRange(self)
	}
	
	func contains(index: Int) -> Bool {
		return index >= location && index < endIndex
	}
}
