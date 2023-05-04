//
//  DocumentView.swift
//  Genly
//
//  Created by Toni K. Turk on 02/05/2023.
//

import AppKit
import SwiftUI
import RichTextKit

struct DocumentView: View {
  enum DocumentSource {
    case new(SideBarView.TemplateOptions)
    case existing(Document)
  }
  
  private var delegate: TextViewDelegate!
  let source: DocumentSource
  @ObservedObject var viewModel: ViewModel
  
  init(source: DocumentSource, apiKey: String) {
    self.source = source
    self.viewModel = .init(source: source, apiKey: apiKey)
    delegate = .init(view: .init(value: self))
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      TextControlsPane(
        isBoldHighlighted: $viewModel.isBoldHighlighted, 
        isItalicHighlighted: $viewModel.isItalicHighlighted, 
        isUnderlineHighlighted: $viewModel.isUnderlineHighlighted,
        isHeading1: $viewModel.isHeading1,
        isHeading2: $viewModel.isHeading2,
        isHeading3: $viewModel.isHeading3,
        boldAction: {
          guard let nsRange = viewModel.selectedRanges.first else { return }
          let range = Range<AttributedString.Index>(nsRange, in: viewModel.text)!
          var string = AttributedString(viewModel.text[range])
          let nsfont = NSAttributedString(string).fontAttributes(in: .init(location: 0, length: nsRange.length))[.font]! as! NSFont
          var container = AttributeContainer()
          container.foregroundColor = string.foregroundColor
          container.font = .systemFont(ofSize: nsfont.pointSize).withTraits([
            nsfont.isItalic ? .italic : nil, 
            nsfont.isBold ? nil : .bold,
          ])
          string.setAttributes(container)
          viewModel.text.replaceSubrange(
            range,
            with: string
          )
        },
        italicAction: {
          guard let nsRange = viewModel.selectedRanges.first else { return }
          let range = Range<AttributedString.Index>(nsRange, in: viewModel.text)!
          var string = AttributedString(viewModel.text[range])
          let nsfont = NSAttributedString(string).fontAttributes(in: .init(location: 0, length: nsRange.length))[.font]! as! NSFont
          var container = AttributeContainer()
          container.foregroundColor = string.foregroundColor
          container.font = .systemFont(ofSize: nsfont.pointSize).withTraits([
            nsfont.isItalic ? nil : .italic, 
            nsfont.isBold ? .bold : nil,
          ])
          string.setAttributes(container)
          viewModel.text.replaceSubrange(
            range,
            with: string
          )
        },
        underlineAction: {
          
        },
        heading1Action: {
          guard var nsRange = viewModel.selectedRanges.first else { return }
          while nsRange.location > 0 && !viewModel.text.characters[viewModel.text.characters.index(viewModel.text.characters.startIndex, offsetBy: nsRange.location)].isNewline {
            nsRange.location -= 1
            nsRange.length += 1
          }
          if viewModel.text.characters[viewModel.text.characters.index(viewModel.text.characters.startIndex, offsetBy: nsRange.location)].isNewline {
            nsRange.location += 1
            nsRange.length -= 1
          }
          while nsRange.upperBound < viewModel.text.characters.count && !viewModel.text.characters[viewModel.text.characters.index(viewModel.text.characters.startIndex, offsetBy: nsRange.upperBound)].isNewline {
            nsRange.length += 1
          }
          let range = Range<AttributedString.Index>(nsRange, in: viewModel.text)!
          var string = AttributedString(viewModel.text[range])
          let nsfont = NSAttributedString(string).fontAttributes(in: .init(location: 0, length: nsRange.length))[.font]! as! NSFont
          var container = AttributeContainer()
          container.foregroundColor = string.foregroundColor
          if nsfont.isHeading1 {
            container.font = NSFont.systemFont(ofSize: 14).withTraits(nsfont.traits)
          } else {
            container.font = NSFont.heading1.withTraits(nsfont.traits)
          }
          string.setAttributes(container)
          viewModel.text.replaceSubrange(
            range,
            with: string
          )
        },
        heading2Action: {
          guard var nsRange = viewModel.selectedRanges.first else { return }
          while nsRange.location > 0 && !viewModel.text.characters[viewModel.text.characters.index(viewModel.text.characters.startIndex, offsetBy: nsRange.location)].isNewline {
            nsRange.location -= 1
            nsRange.length += 1
          }
          if viewModel.text.characters[viewModel.text.characters.index(viewModel.text.characters.startIndex, offsetBy: nsRange.location)].isNewline {
            nsRange.location += 1
            nsRange.length -= 1
          }
          while nsRange.upperBound < viewModel.text.characters.count && !viewModel.text.characters[viewModel.text.characters.index(viewModel.text.characters.startIndex, offsetBy: nsRange.upperBound)].isNewline {
            nsRange.length += 1
          }
          let range = Range<AttributedString.Index>(nsRange, in: viewModel.text)!
          var string = AttributedString(viewModel.text[range])
          let nsfont = NSAttributedString(string).fontAttributes(in: .init(location: 0, length: nsRange.length))[.font]! as! NSFont
          var container = AttributeContainer()
          container.foregroundColor = string.foregroundColor
          if nsfont.isHeading2 {
            container.font = NSFont.systemFont(ofSize: 14).withTraits(nsfont.traits)
          } else {
            container.font = NSFont.heading2.withTraits(nsfont.traits)
          }
          string.setAttributes(container)
          viewModel.text.replaceSubrange(
            range,
            with: string
          )
        },
        heading3Action: {
          guard var nsRange = viewModel.selectedRanges.first else { return }
          while nsRange.location > 0 && !viewModel.text.characters[viewModel.text.characters.index(viewModel.text.characters.startIndex, offsetBy: nsRange.location)].isNewline {
            nsRange.location -= 1
            nsRange.length += 1
          }
          if viewModel.text.characters[viewModel.text.characters.index(viewModel.text.characters.startIndex, offsetBy: nsRange.location)].isNewline {
            nsRange.location += 1
            nsRange.length -= 1
          }
          while nsRange.upperBound < viewModel.text.characters.count && !viewModel.text.characters[viewModel.text.characters.index(viewModel.text.characters.startIndex, offsetBy: nsRange.upperBound)].isNewline {
            nsRange.length += 1
          }
          
          let range = Range<AttributedString.Index>(nsRange, in: viewModel.text)!
          var string = AttributedString(viewModel.text[range])
          let nsfont = NSAttributedString(string).fontAttributes(in: .init(location: 0, length: nsRange.length))[.font]! as! NSFont
          var container = AttributeContainer()
          container.foregroundColor = string.foregroundColor
          if nsfont.isHeading3 {
            container.font = NSFont.systemFont(ofSize: 14).withTraits(nsfont.traits)
          } else {
            container.font = NSFont.heading3.withTraits(nsfont.traits)
          }
          string.setAttributes(container)
          viewModel.text.replaceSubrange(
            range,
            with: string
          )
        }
      )
      TextView(text: $viewModel.text, delegate: delegate)
        .focusable()
    }
    .padding()
    .onAppear { @MainActor in
      Task {
        await viewModel.prepareDocument()
      }
    }
  }
}

class TextViewDelegate: NSObject, NSTextViewDelegate {
  let view: Box<DocumentView>
  weak var textView: NSTextView?
  
  init(view: Box<DocumentView>) {
    self.view = view
  }
  
  func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRanges oldSelectedCharRanges: [NSValue], toCharacterRanges newSelectedCharRanges: [NSValue]) -> [NSValue] {
    guard let range = newSelectedCharRanges.first as? NSRange else { return newSelectedCharRanges }
    guard textView.string.utf16.count > range.upperBound else { return newSelectedCharRanges }
    let attrSubstr = textView.attributedString().fontAttributes(in: range)
    let isBold     = (attrSubstr[.font] as? NSFont)?.isBold ?? false
    let isItalic   = (attrSubstr[.font] as? NSFont)?.isItalic ?? false
    let isHeading1 = (attrSubstr[.font] as? NSFont)?.isHeading1 ?? false
    let isHeading2 = (attrSubstr[.font] as? NSFont)?.isHeading2 ?? false
    let isHeading3 = (attrSubstr[.font] as? NSFont)?.isHeading3 ?? false
    view.value.viewModel.isBoldHighlighted = isBold
    view.value.viewModel.isItalicHighlighted = isItalic
    view.value.viewModel.isHeading1 = isHeading1
    view.value.viewModel.isHeading2 = isHeading2
    view.value.viewModel.isHeading3 = isHeading3
    view.value.viewModel.selectedRanges = [range]
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
    
    let convertedRange = Range(range, in: view.value.viewModel.text)!
    
    let fontAttributes: [NSAttributedString.Key : Any]
    if textView.string.isEmpty {
      fontAttributes = [
        .foregroundColor: NSColor.white,
        .font: NSFont.systemFont(ofSize: 14)
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
          .foregroundColor: NSColor.white,
          .font: NSFont.systemFont(ofSize: 14)
        ]
      }
    } else {
      fontAttributes = [
        .foregroundColor: NSColor.white,
        .font: NSFont.systemFont(ofSize: 14)
      ]
    }
    
    let attr = NSMutableAttributedString(string: replacement)
    attr.setAttributes(fontAttributes, range: .init(location: 0, length: attr.length))
    
    view.value.viewModel.text.replaceSubrange(
      convertedRange, 
      with: AttributedString(attr)
    )
    textView.selectedRanges = [range as NSValue]
    return true
  }
}

class Box<T> {
  var value: T
  
  init(value: T) {
    self.value = value
  }
}

struct TextView: NSViewRepresentable {
  @Binding var text: AttributedString
  weak var delegate: TextViewDelegate?
  
  func makeNSView(context: Context) -> NSScrollView {
    let textView = NSTextView.scrollableTextView()
    delegate?.textView = (textView.documentView as! NSTextView)
    updateNSView(textView, context: context)
    return textView
  }
  
  func updateNSView(_ textView: NSScrollView, context: Context) {
    let attributedString = NSMutableAttributedString(text)
    attributedString.setForegroundColor(to: .white, at: .init(location: 0, length: attributedString.length))
    let ranges = (textView.documentView as! NSTextView).selectedRanges
    (textView.documentView as! NSTextView).delegate = nil
    (textView.documentView as! NSTextView).textStorage?.setAttributedString(attributedString)
    (textView.documentView as! NSTextView).selectedRanges = ranges
    (textView.documentView as! NSTextView).delegate = delegate
    delegate?.view.value.viewModel.updateDocument()
  }
}

extension DocumentView {
  class ViewModel: ObservableObject {
    let source: DocumentView.DocumentSource
    private(set) var document: Document
    let api: OpenAIAPI = .init()
    let apiKey: String
    let storage: DocumentStorage = try! .init()
    
    private var gptHistory: [OpenAIAPI.Message] = []
    
    @Published var isBoldHighlighted: Bool = false
    @Published var isItalicHighlighted: Bool = false
    @Published var isUnderlineHighlighted: Bool = false
    @Published var isHeading1: Bool = false
    @Published var isHeading2: Bool = false
    @Published var isHeading3: Bool = false
    @Published var selectedRanges: [NSRange] = []
    @Published var text: AttributedString
    
//    parseMarkdown("""
//        # Blog topic:
//        
//        ## The Ultimate Guide to Training Your Dog: Proven Techniques for a Well-Behaved and Happy Canine Companion
//        
//        ### Blog outline:
//        
//        ### Introduction: The Importance of Training Your Dog
//        
//        *keywords: dog training, importance of training, well-behaved dog, happy dog, responsible dog ownership*
//        
//        ### The Science Behind Dog Training: Understanding How Dogs Learn
//        
//        *keywords: dog learning, positive reinforcement, operant conditioning, classical conditioning, dog psychology*
//        
//        ### Essential Commands Every Dog Should Know
//        
//        *keywords: basic dog commands, sit, stay, come, leave it, heel, dog obedience*
//        
//        ### How to Choose the Right Training Method for Your Dog
//        
//        *keywords: dog training methods, positive reinforcement, clicker training, lure and reward, balanced training, choosing the right method*
//        
//        ### Addressing Common Behavior Problems
//        
//        *keywords: dog behavior problems, barking, jumping, chewing, digging, separation anxiety, aggression, solutions*
//        
//        ### Socialization: The Key to a Well-Adjusted Dog
//        
//        *keywords: dog socialization, puppy socialization, socializing adult dogs, dog parks, dog classes, socialization tips*
//        
//        ### Advanced Training: Taking Your Dog's Skills to the Next Level
//        
//        *keywords: advanced dog training, agility, obedience competitions, therapy dog training, service dog training, dog sports*
//        
//        ### Conclusion: The Lifelong Benefits of Training Your Dog
//        
//        *keywords: benefits of dog training, stronger bond, mental stimulation, safety, well-behaved dog, happy dog*
//        
//        [this is a link](http://www.google.com)
//        """)
    
    init(source: DocumentView.DocumentSource, apiKey: String) {
      self.source = source
      self.apiKey = apiKey
      switch source {
      case .existing(let document):
        self.text = document.text
        self.document = document
      case .new(let template):
        self.text = .init()
        self.document = .init(
          id: .init(), 
          title: "", 
          text: .init(), 
          createdAt: Date(), 
          lastModifiedAt: Date()
        )
      }
    }
    
    @MainActor
    func prepareDocument(
    ) async {
      guard case let .new(templateOptions) = source else { return }
      
      let prompt = templateOptions.useCaseOption.prepareAssistant(options: templateOptions)
      gptHistory.append(.init(
        role: "system", 
        content: prompt
      ))
      gptHistory.append(.init(
        role: "user", 
        content: """
      The language of your response is: \(templateOptions.languageOption)
      The tone of your response should be: \(templateOptions.toneOption)
      The input keyword is: \(templateOptions.keyword)
      """
      ))
      
      do {
        let responses = try await api.completion(
          temperature: 0.3, 
          variants: templateOptions.variantsCount, 
          messages: gptHistory, 
          apiKey: apiKey
        )
        guard !responses.isEmpty else { 
          return
        }
        print("OpenAI did respond:")
        print(responses[0])
        
        self.text = parseMarkdown(responses[0])
        self.updateDocument()
        
        self.gptHistory.append(.init(
          role: "assistant", 
          content: responses[0]
        ))
      } catch {
        print("Calling OpenAI failed")
      }
    }
    
    func updateDocument(
    ) {
      guard document.text != text else { return }
      print("saving document with id ", document.id)
      document.text = text
      document.lastModifiedAt = Date()
      do {
        try storage.store(document: document)
      } catch {
        print(error)
      }
    }
  }
}

func parseMarkdown(
  _ markdown: String,
  allowsExtendedAttributes: Bool = false,
  interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax = .inlineOnlyPreservingWhitespace,
  failurePolicy: AttributedString.MarkdownParsingOptions.FailurePolicy = .returnPartiallyParsedIfPossible
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

extension NSFont {
  var isHeading1: Bool {
    self.pointSize == NSFont.heading1.pointSize
  }
  var isHeading2: Bool {
    self.pointSize == NSFont.heading2.pointSize
  }
  var isHeading3: Bool {
    self.pointSize == NSFont.heading3.pointSize
  }
  var isBold: Bool {
    NSFontTraitMask(rawValue: UInt(fontDescriptor.symbolicTraits.rawValue)).contains(.boldFontMask)
  }
  var isItalic: Bool {
    NSFontTraitMask(rawValue: UInt(fontDescriptor.symbolicTraits.rawValue)).contains(.italicFontMask)
  }
  var isUnderlined: Bool {
    fatalError()
  }
  
  static var heading1: NSFont { .boldSystemFont(ofSize: 24) }
  static var heading2: NSFont { .boldSystemFont(ofSize: 20) }
  static var heading3: NSFont { .boldSystemFont(ofSize: 16) }
  
  func withTraits(_ traits: [NSFontDescriptor.SymbolicTraits?]) -> NSFont {
    let descriptor = fontDescriptor
      .withSymbolicTraits(NSFontDescriptor.SymbolicTraits(traits.compactMap { $0 }))
    return .init(descriptor: descriptor, size: descriptor.pointSize)!
  }
  
  func withTraits(_ traits: NSFontDescriptor.SymbolicTraits...) -> NSFont {
    let descriptor = fontDescriptor
      .withSymbolicTraits(NSFontDescriptor.SymbolicTraits(traits))
    return .init(descriptor: descriptor, size: descriptor.pointSize)!
  }
  
  func withSize(_ size: CGFloat) -> NSFont {
    let descriptor = fontDescriptor
    return .init(descriptor: descriptor, size: size)!
  }
  
  var traits: NSFontDescriptor.SymbolicTraits {
    fontDescriptor.symbolicTraits
  }
}

fileprivate extension SideBarView.UseCaseOption {
  func prepareAssistant(options: SideBarView.TemplateOptions) -> String {
    switch self {
    case .blogIdeaAndOutline:
      let attempt1 = """
You are a helpful assistant, helping the user with creating an outline for a blog post. 
Based on the provided keyword, your goal is to generate ideas for a blog post and prepare an outline.
The result must contain a title of the blogpost and a list of sections. 
Each item in the section contains a subtitle and a list of keywords.
Your response should be in markdown format.
The style of the response should match the tone provided by the user.
The language of the response should match the language provided by the user.

Here is an example:
###
The language of your response is: English
The tone of your response should be: Convincing
The input keyword is: AI writing assistant
response:
# Blog topic:

## The Potential of AI Writing Assistants: How They are Transforming the Way We Write and Create Content

### Blog outline:

### Introduction: What is an AI Writing Assistant and How Does it Work?

*keywords: ai writing assistant, content generation software, ai copywriting tool, ai writer, content generator)*

## Exploring the Unique Benefits of Using an AI Writing Assistant

**keywords: ai writing tool advantages, automated writing tools benefits, what can an ai writer do?, automated writing software advantages)**

## The Different Types of AI Writing Assistants & Where to Find Them

*keywords: digital writing assistant, writing assistant software free, best writing assistant software, writing assistant website)*

##An In-Depth Look at the Different Use Cases for AI Writers

*keywords: ai writer use cases, can ai write blog posts?, auto write emails, story generator online)*

How to Choose the Best AI
###   
"""
      let attempt2 = """
You are a helpful assistant, helping the user with writing a blog post.

Create an outline for a blog idea with the primary keyword "\(options.keyword)". 
Make the tone of the outline \(options.toneOption). 
Output language should be \(options.languageOption).
Output text should be in Markdown format.
For each outline subheading, give a short paragraph and append a list of relevant keywords in italic.
"""
      return attempt2
    case _:
      fatalError()
    }
  }
} 
