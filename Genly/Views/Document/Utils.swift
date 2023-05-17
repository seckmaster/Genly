//
//  Utils.swift
//  Genly
//
//  Created by Toni K. Turk on 06/05/2023.
//

import SwiftUI

func parseMarkdown(
  _ markdown: String,
  allowsExtendedAttributes: Bool = false,
  interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax = .inlineOnlyPreservingWhitespace,
  failurePolicy: AttributedString.MarkdownParsingOptions.FailurePolicy = .returnPartiallyParsedIfPossible,
  primaryForegroundColor: Color? = nil
) -> AttributedString {
  do {
    var attributedString = try AttributedString(
      markdown: markdown, 
      options: .init(
        allowsExtendedAttributes: allowsExtendedAttributes, 
        interpretedSyntax: interpretedSyntax, 
        failurePolicy: failurePolicy
      )
    )
    
    var globalContainer = AttributeContainer()
    globalContainer.font = .systemFont(ofSize: 14)
    if let color = primaryForegroundColor {
      globalContainer.foregroundColor = color
    }
    attributedString.mergeAttributes(globalContainer, mergePolicy: .keepNew)
    
    markdown.ranges(of: /###(.+?)\n/).forEach {
      let range1 = attributedString.range(of: markdown[$0])!
      let range2 = attributedString.range(of: markdown[$0].dropFirst(4))!
      var container = AttributeContainer()
      container.font = .heading3
      attributedString.replaceSubrange(
        range1, 
        with: attributedString[range2].settingAttributes(container)
      )
    }
    markdown.ranges(of: /##(.+?)\n/).forEach {
      guard let range1 = attributedString.range(of: markdown[$0]) else { return } 
      let range2 = attributedString.range(of: markdown[$0].dropFirst(3))!
      var container = AttributeContainer()
      container.font = .heading2
      attributedString.replaceSubrange(
        range1, 
        with: attributedString[range2].settingAttributes(container)
      )
    }
    markdown.ranges(of: /#(.+?)\n/).forEach {
      guard let range1 = attributedString.range(of: markdown[$0]) else { return } 
      let range2 = attributedString.range(of: markdown[$0].dropFirst(2))!
      var container = AttributeContainer()
      container.font = .heading1
      //      let paragraphStyle = NSMutableParagraphStyle()
      //      paragraphStyle.paragraphSpacing = 40
      //      paragraphStyle.lineSpacing = 40
      //      paragraphStyle.headIndent = 100
      //      container.paragraphStyle = paragraphStyle
      attributedString.replaceSubrange(
        range1, 
        with: attributedString[range2].settingAttributes(container)
      )
    }
    return attributedString
  } catch {
    return .init(markdown)
  }
}

extension MyFont {
  var isHeading1: Bool {
    self.pointSize == MyFont.heading1.pointSize
  }
  var isHeading2: Bool {
    self.pointSize == MyFont.heading2.pointSize
  }
  var isHeading3: Bool {
    self.pointSize == MyFont.heading3.pointSize
  }
}

#if os(macOS)
import AppKit
extension MyFont {
  var isBold: Bool {
    NSFontTraitMask(rawValue: UInt(fontDescriptor.symbolicTraits.rawValue)).contains(.boldFontMask)
  }
  var isItalic: Bool {
    NSFontTraitMask(rawValue: UInt(fontDescriptor.symbolicTraits.rawValue)).contains(.italicFontMask)
  }
  var isUnderlined: Bool {
    fatalError()
  }
  
  static var heading1: MyFont { .boldSystemFont(ofSize: 24) }
  static var heading2: MyFont { .boldSystemFont(ofSize: 20) }
  static var heading3: MyFont { .boldSystemFont(ofSize: 16) }
  
  func withTraits(_ traits: [NSFontDescriptor.SymbolicTraits?]) -> MyFont {
    let descriptor = fontDescriptor
      .withSymbolicTraits(NSFontDescriptor.SymbolicTraits(traits.compactMap { $0 }))
    return .init(descriptor: descriptor, size: descriptor.pointSize)!
  }
  
  func withTraits(_ traits: NSFontDescriptor.SymbolicTraits...) -> MyFont {
    let descriptor = fontDescriptor
      .withSymbolicTraits(NSFontDescriptor.SymbolicTraits(traits))
    return .init(descriptor: descriptor, size: descriptor.pointSize)!
  }
  
  func withSize(_ size: CGFloat) -> MyFont {
    let descriptor = fontDescriptor
    return .init(descriptor: descriptor, size: size)!
  }
  
  var traits: NSFontDescriptor.SymbolicTraits {
    fontDescriptor.symbolicTraits
  }
}
#elseif os(iOS)
import UIKit
extension MyFont {
  var isBold: Bool {
    fontDescriptor.symbolicTraits.contains(.traitBold)
  }
  var isItalic: Bool {
    fontDescriptor.symbolicTraits.contains(.traitItalic)
  }
  var isUnderlined: Bool {
    fatalError()
  }
  
  static var heading1: MyFont { .boldSystemFont(ofSize: 24) }
  static var heading2: MyFont { .boldSystemFont(ofSize: 20) }
  static var heading3: MyFont { .boldSystemFont(ofSize: 16) }
  
  func withTraits(_ traits: [UIFontDescriptor.SymbolicTraits?]) -> MyFont {
    let descriptor = fontDescriptor
      .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits.compactMap { $0 }))!
    return .init(descriptor: descriptor, size: descriptor.pointSize)
  }
  
  func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> MyFont {
    let descriptor = fontDescriptor
      .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))!
    return .init(descriptor: descriptor, size: descriptor.pointSize)
  }
  
  func withSize(_ size: CGFloat) -> MyFont {
    let descriptor = fontDescriptor
    return .init(descriptor: descriptor, size: size)
  }
  
  var traits: UIFontDescriptor.SymbolicTraits {
    fontDescriptor.symbolicTraits
  }
}

extension UIFontDescriptor.SymbolicTraits {
  static var italic: UIFontDescriptor.SymbolicTraits {
    .traitItalic
  }
  
  static var bold: UIFontDescriptor.SymbolicTraits {
    .traitBold
  }
}
#endif


func chatToAttributedString(
  _ chat: [OpenAIAPI.Message]
) -> AttributedString {
  var string = AttributedString()
  for message in chat {
    switch message.role {
    case "system":
      var container = AttributeContainer()
      container.foregroundColor = .red
      container.font = .boldSystemFont(ofSize: 14)
      var substr = AttributedString("⦿  System\n")
      substr.setAttributes(container)
      string.append(substr)
      
      container = AttributeContainer()
      container.foregroundColor = .white
      container.font = .systemFont(ofSize: 14)
      substr = AttributedString(message.content + "\n" + "\n")
      substr.setAttributes(container)
      string.append(substr)
    case "assistant":
      var container = AttributeContainer()
      container.foregroundColor = .orange
      container.font = .boldSystemFont(ofSize: 14)
      var substr = AttributedString("⦿  Assistant\n")
      substr.setAttributes(container)
      string.append(substr)
      
      container = AttributeContainer()
      container.foregroundColor = .white
      container.font = .systemFont(ofSize: 14)
      substr = AttributedString(message.content + "\n" + "\n")
      substr.setAttributes(container)
      string.append(substr)
    case "user":
      var container = AttributeContainer()
      container.foregroundColor = .magenta
      container.font = .boldSystemFont(ofSize: 14)
      var substr = AttributedString("⦿  User\n")
      substr.setAttributes(container)
      string.append(substr)
      
      container = AttributeContainer()
      container.foregroundColor = .white
      container.font = .systemFont(ofSize: 14)
      substr = AttributedString(message.content + "\n" + "\n")
      substr.setAttributes(container)
      string.append(substr)
    case "error":
      var container = AttributeContainer()
      container.foregroundColor = .orange
      container.font = .boldSystemFont(ofSize: 14)
      var substr = AttributedString("⦿  Error\n")
      substr.setAttributes(container)
      string.append(substr)
      
      container = AttributeContainer()
      container.foregroundColor = .red
      container.font = .systemFont(ofSize: 12)
      substr = AttributedString(message.content + "\n" + "\n")
      substr.setAttributes(container)
      string.append(substr)
    case _:
      fatalError()
    }
  }
  return string
}
