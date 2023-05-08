//
//  Font.swift
//  Genly
//
//  Created by Toni K. Turk on 08/05/2023.
//

import Foundation

#if os(macOS)
import AppKit
typealias MyFont = NSFont
#elseif os(iOS)
import UIKit
typealias MyFont = UIFont
#endif
