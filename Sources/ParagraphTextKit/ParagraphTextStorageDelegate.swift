//
//  ParagraphTextStorageDelegate.swift
//  ParagraphTextKit
//
//  Created by Vitalii Vashchenko on 2/11/19.
//  Copyright © 2020 Vitalii Vashchenko. All rights reserved.
//

import Foundation

/// Protocol defines methods that are invoked if the storage has been edited
public protocol ParagraphTextStorageDelegate: class {
	func paragraphCount() -> Int
	func textStorage(_ textStorage: ParagraphTextStorage, didChangeParagraphs changes: [ParagraphTextStorage.ParagraphChange])
}
