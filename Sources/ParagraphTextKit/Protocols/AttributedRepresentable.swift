//
//  ParagraphTextStorageDelegate.swift
//  ParagraphTextKit
//
//  Created by Vitalii Vashchenko on 21/11/20.
//  Copyright © 2020 Vitalii Vashchenko. All rights reserved.
//

import Foundation

public protocol AttributedRepresentable {
	var attributedPresentation: NSAttributedString { get }
}
