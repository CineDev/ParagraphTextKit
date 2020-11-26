//
//  ParagraphTextStorageDelegate.swift
//  ParagraphTextKit
//
// 	Copyright (c) 2020 Vitalii Vashchenko
//
//	This software is released under the MIT License.
// 	https://opensource.org/licenses/MIT
//
//  Created by Vitalii Vashchenko on 2/11/19.
//

import Foundation

/// Protocol defines methods that are invoked if the storage has been edited
public protocol ParagraphTextStorageDelegate: class {
	var presentedParagraphs: [NSAttributedString] { get }
	func textStorage(_ textStorage: ParagraphTextStorage, didChangeParagraphs changes: [ParagraphTextStorage.ParagraphChange])
}
