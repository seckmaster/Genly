//
//  TextView.swift
//  Genly
//
//  Created by Toni K. Turk on 06/05/2023.
//

import SwiftUI
#if os(iOS)
import UIKit

typealias ViewRepresentable = UIViewRepresentable
typealias OldSchoolScrollView = UIScrollView
typealias OldSchoolTextView = UITextView
typealias OldSchoolTextViewDelegate = UITextViewDelegate
typealias OldSchoolColor = UIColor
#elseif os(macOS)
import AppKit

typealias ViewRepresentable = NSViewRepresentable
typealias OldSchoolScrollView = NSScrollView
typealias OldSchoolTextView = NSTextView
typealias OldSchoolTextViewDelegate = NSTextViewDelegate
typealias OldSchoolColor = NSColor
#endif

struct TextView: ViewRepresentable {
  @Binding var text: AttributedString
  weak var delegate: TextViewDelegate?
  
#if os(macOS)
  func makeNSView(context: Context) -> OldSchoolScrollView {
    let textView = OldSchoolTextView.scrollableTextView()
    textView.backgroundColor = .clear
    (textView.documentView as! NSTextView).backgroundColor = .clear
    delegate?.textView = (textView.documentView as! OldSchoolTextView)
    updateNSView(textView, context: context)
    return textView
  }
  
  func updateNSView(_ scrollView: OldSchoolScrollView, context: Context) {
    guard delegate?.text != text else { return }
    
    let textView = scrollView.documentView as! OldSchoolTextView
    let scroll = scrollView.documentVisibleRect.origin
    
    let attributedString = NSMutableAttributedString(text)
    attributedString.setRichTextAttributes(
      [.foregroundColor: NSColor.white], 
      at: .init(location: 0, length: attributedString.length)
    )
    let ranges = textView.selectedRanges
    
    textView.delegate = nil
    textView.textStorage?.setAttributedString(attributedString)
    textView.selectedRanges = ranges
    textView.scroll(scroll)
    textView.delegate = delegate
    delegate?.text = text
    delegate?.view.value.viewModel.updateDocument()
  }
#elseif os(iOS)
  func makeUIView(context: Context) -> OldSchoolTextView {
    let textView = OldSchoolTextView()
    delegate?.textView = textView
    updateUIView(textView, context: context)
    return textView
  } 
  
  func updateUIView(_ textView: OldSchoolTextView, context: Context) {
    guard delegate?.text != text else { return }
    
    let scroll = textView.contentOffset
    let attributedString = NSMutableAttributedString(text)
    attributedString.setForegroundColor(to: .white, at: .init(location: 0, length: attributedString.length))
    let range = textView.selectedRange
    
    textView.delegate = nil
    textView.attributedText = attributedString
    textView.selectedRange = range
    textView.setContentOffset(scroll, animated: false)
    textView.delegate = delegate
    delegate?.text = text
    delegate?.view.value.viewModel.updateDocument()
  }
#endif
}

class TextViewDelegate: NSObject, OldSchoolTextViewDelegate {
  let view: Box<DocumentView>
  var text: AttributedString?
  weak var textView: OldSchoolTextView?
  
  init(view: Box<DocumentView>) {
    self.view = view
  }
  
#if os(macOS)
  func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRanges oldSelectedCharRanges: [NSValue], toCharacterRanges newSelectedCharRanges: [NSValue]) -> [NSValue] {
    guard let range = newSelectedCharRanges.first as? NSRange else { return newSelectedCharRanges }
    guard textView.string.utf16.count >= range.upperBound else { return newSelectedCharRanges }
    
    let attrSubstr = textView.attributedString().fontAttributes(in: range)
    let isBold     = (attrSubstr[.font] as? MyFont)?.isBold ?? false
    let isItalic   = (attrSubstr[.font] as? MyFont)?.isItalic ?? false
    let isHeading1 = (attrSubstr[.font] as? MyFont)?.isHeading1 ?? false
    let isHeading2 = (attrSubstr[.font] as? MyFont)?.isHeading2 ?? false
    let isHeading3 = (attrSubstr[.font] as? MyFont)?.isHeading3 ?? false
    
    self.view.value.viewModel.isBoldHighlighted = isBold
    self.view.value.viewModel.isItalicHighlighted = isItalic
    self.view.value.viewModel.isHeading1 = isHeading1
    self.view.value.viewModel.isHeading2 = isHeading2
    self.view.value.viewModel.isHeading3 = isHeading3
    self.view.value.viewModel.selectedRanges = [range]
    return newSelectedCharRanges
  }
  
  func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange, toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
    print("func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange, toCharacterRange newSelectedCharRange: NSRange) -> NSRange {")
    return newSelectedCharRange
  }
  
  func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
    guard let replacementStrings else { return true }
    guard let range = affectedRanges.first as? NSRange else { return true }
    guard let replacement = replacementStrings.first else { return true }
    
    let convertedRange = Range(range, in: self.view.value.viewModel.text)!
    
    let fontAttributes: [NSAttributedString.Key : Any]
    if textView.string.isEmpty {
      fontAttributes = [
        .foregroundColor: OldSchoolColor.white,
        .font: MyFont.systemFont(ofSize: 14)
      ]
    } else if let char = textView.string.character(at: range.lowerBound) {
      let isNewLine = char.isNewline
      let isPrevNewLine = textView.string.character(at: range.lowerBound - 1).map { $0.isNewline } ?? true
      
      if isNewLine && range.lowerBound > 0 {
        fontAttributes = textView.attributedString()
          .fontAttributes(in: NSRange(location: range.location - 1, length: 0))
      } else if isPrevNewLine && range.lowerBound < textView.string.utf16.count {
        fontAttributes = textView.attributedString()
          .fontAttributes(in: NSRange(location: range.location + 1, length: 0))
      } else if range.lowerBound > 0 && range.lowerBound < textView.string.utf16.count {
        fontAttributes = textView.attributedString()
          .fontAttributes(in: range)
      } else {
        fontAttributes = [
          .foregroundColor: OldSchoolColor.white,
          .font: MyFont.systemFont(ofSize: 14)
        ]
      }
    } else {
      fontAttributes = [
        .foregroundColor: OldSchoolColor.white,
        .font: MyFont.systemFont(ofSize: 14)
      ]
    }
    
    let attr = NSMutableAttributedString(string: replacement)
    attr.setAttributes(fontAttributes, range: .init(location: 0, length: attr.length))
    
    self.view.value.viewModel.text.replaceSubrange(
      convertedRange, 
      with: AttributedString(attr)
    )
    textView.selectedRanges = [range as NSValue]
    return true
  }
#endif
}

extension String {
  func character(at index: Int) -> String.Element? {
    guard index >= 0 && index < utf16.count else { return nil }
    return self[self.index(startIndex, offsetBy: index)]
  }
}

extension NSMutableAttributedString {
  func setRichTextAttributes(
    _ attributes: [NSAttributedString.Key: Any],
    at range: NSRange
  ) {
    let range = safeRange(for: range)
    let string = self
    string.beginEditing()
    attributes.forEach { attribute, newValue in
      string.enumerateAttribute(attribute, in: range, options: .init()) { _, range, _ in
        string.removeAttribute(attribute, range: range)
        string.addAttribute(attribute, value: newValue, range: range)
        string.fixAttributes(in: range)
      }
    }
    string.endEditing()
  }
  
  func safeRange(for range: NSRange) -> NSRange {
    let length = self.length
    return NSRange(
      location: max(0, min(length-1, range.location)),
      length: min(range.length, max(0, length - range.location))
    )
  }
}
