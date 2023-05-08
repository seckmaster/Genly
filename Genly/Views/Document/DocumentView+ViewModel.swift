//
//  DocumentView+ViewModel.swift
//  Genly
//
//  Created by Toni K. Turk on 06/05/2023.
//

import SwiftUI

extension DocumentView {
  class ViewModel: ObservableObject {
    let source: DocumentView.DocumentSource
    var document: Document
    let api: OpenAIAPI = .init()
    let apiKey: String
    let storage: DocumentStorage = try! .init()
    let promptsStorage: PromptsStorage = .init()
    
    private var gptHistory: [OpenAIAPI.Message] = []
    
    @Published var commands: [UseCases.Prompt]
    @Published var isBoldHighlighted: Bool = false
    @Published var isItalicHighlighted: Bool = false
    @Published var isUnderlineHighlighted: Bool = false
    @Published var isHeading1: Bool = false
    @Published var isHeading2: Bool = false
    @Published var isHeading3: Bool = false
    @Published var selectedRanges: [NSRange] = []
    @Published var isSpinning: Bool = false
    @Published var title: String
    @Published var chat: AttributedString
    @Published var text: AttributedString
    
    init(
      source: DocumentView.DocumentSource, 
      apiKey: String, 
      commands: [UseCases.Prompt]
    ) {
      self.source = source
      self.apiKey = apiKey
      self.commands = commands
      switch source {
      case .existing(let document):
        self.text = document.text
        self.title = document.title ?? ""
        self.document = document
        self.chat = Self.chatToAttributedString(document.chatHistory)
        self.gptHistory = document.chatHistory
      case .new(let template):
        self.text = .init()
        self.document = .init(
          id: .init(), 
          title: nil,
          text: .init(), 
          chatHistory: [],
          createdAt: Date(), 
          lastModifiedAt: Date(),
          templateOptions: template
        )
        self.title = ""
        self.chat = .init()
        createNewDocument()
      }
    }
  }
}

extension DocumentView.ViewModel {
  func createNewDocument() {
    guard case let .new(templateOptions) = source else { return }
    
    gptHistory.append(.init(
      role: "system", 
      content: """
        You are an expert in writing blog posts.
        
        Write a blog post outline given relevant keywords inside <keywords></keywords> badge. 
        The tone of the blog post must be \(document.templateOptions.toneOption). 
        Output language of the blog post must be \(document.templateOptions.languageOption).
        The output text must be in Markdown format.
        """
    ))
    gptHistory.append(.init(
      role: "user", 
      content: """
      <keywords>
      \(templateOptions.keyword)
      </keywords>
      """
    ))
    chat = Self.chatToAttributedString(gptHistory)
    document.chatHistory = gptHistory
    updateDocument(force: true)
    
    Task { @MainActor in
      do {
        isSpinning = true
        let responses = try await api.completion(
          temperature: 0.3,
          variants: templateOptions.variantsCount, 
          messages: gptHistory, 
          apiKey: apiKey
        )
        isSpinning = false
        guard !responses.isEmpty else { 
          return
        }
        
        self.gptHistory.append(.init(
          role: "assistant", 
          content: responses[0]
        ))
        
        print("OpenAI did respond:")
        print(responses[0])
        
//        self.text = parseMarkdown(responses[0])
        self.text.insert(parseMarkdown(responses[0]), at: self.text.startIndex)
        self.document.chatHistory = gptHistory
        self.updateDocument()
      } catch {
        print("Calling OpenAI failed")
        isSpinning = false
      }
    }
  }
  
  func updateDocument(
    force: Bool = false
  ) {
    guard force || document.text != text else { return }
    print("Saving document with id:", document.id)
    document.text = text
    document.lastModifiedAt = Date()
    do {
      try storage.store(document: document)
    } catch {
      print(error)
    }
  }
  
  func deleteDocument() throws {
    try storage.delete(document: document)
  }
  
  @MainActor
  func performCommand(
    range: Range<AttributedString.Index>,
    systemPrompt: String,
    userPrompt: String,
    createNewHistory: Bool = true,
    primaryForegroundColor: Color? = .init(color: .magenta)
  ) async {
    if createNewHistory {
      gptHistory.append(.init(
        role: "system", 
        content: systemPrompt.trimmingCharacters(in: .whitespaces)
      ))
    }
    gptHistory.append(.init(
      role: "user", 
      content: userPrompt.trimmingCharacters(in: .whitespaces)
    ))
    let history: [OpenAIAPI.Message]
    if createNewHistory {
      history = gptHistory.suffix(2)
    } else {
      history = gptHistory
    }
    chat = Self.chatToAttributedString(gptHistory)
    document.chatHistory = gptHistory
    updateDocument(force: true)
    do {
      isSpinning = true
      let responses = try await api.completion(
        temperature: 0.3,
        variants: 1, 
        messages: history, 
        apiKey: apiKey
      )
      isSpinning = false
      guard !responses.isEmpty else { 
        return
      }
      
      self.gptHistory.append(.init(
        role: "assistant", 
        content: responses[0]
      ))
      self.chat = Self.chatToAttributedString(self.gptHistory)
      
      print("OpenAI did respond:")
      print(responses[0])
      
      var attributedResponse = parseMarkdown(
        responses[0], 
        primaryForegroundColor: primaryForegroundColor
      )
      attributedResponse.insert(AttributedString("\n\n"), at: attributedResponse.startIndex)
      //        var container = AttributeContainer()
      //        container.foregroundColor = .magenta
      //        attributedResponse.setAttributes(container)
      
      self.text.insert(
        attributedResponse, 
        at: range.upperBound
      )
      self.document.chatHistory = gptHistory
      self.updateDocument()
    } catch {
      print("Calling OpenAI failed")
      isSpinning = false
    }
  }
  
  private static func chatToAttributedString(
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
      case _:
        fatalError()
      }
    }
    return string
  }
} 

extension Color {
#if os(iOS)
  init(color: UIColor) {
    self.init(uiColor: color)
  }
#elseif os(macOS)
  init(color: NSColor) {
    self.init(nsColor: color)
  }
#endif
}
