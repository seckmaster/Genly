//
//  DocumentView+ViewModel.swift
//  Genly
//
//  Created by Toni K. Turk on 06/05/2023.
//

import SwiftUI
import SwiftchainOpenAI

extension DocumentView {
  class ViewModel: ObservableObject {
    let source: DocumentView.DocumentSource
    var document: Document
    let llm: ChatOpenAILLM
    let storage: DocumentStorage = try! .init()
    let promptsStorage: PromptsStorage = .init()
    
    private var gptHistory: [ChatOpenAILLM.Message] = []
    
    let useCase: UseCases.UseCase
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
      useCase: UseCases.UseCase
    ) {
      self.source = source
      self.useCase = useCase
      self.llm = .init(apiKey: apiKey)
      switch source {
      case .existing(let document):
        self.text = document.text
        self.title = document.title ?? ""
        self.document = document
        self.chat = chatToAttributedString(document.chatHistory)
        self.gptHistory = document.chatHistory
      case .new(let template):
        print("Creating new document")
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
      }
    }
  }
}

extension DocumentView.ViewModel {
  func createNewDocument() {
    guard case let .new(templateOptions) = source else { return }
    
    gptHistory.append(.init(
      role: .system, 
      content: useCase.prompt.systemPrompt.applyArgs(
        ("TONE", templateOptions.toneOption),
        ("LANG", templateOptions.languageOption)
      )
    ))
    gptHistory.append(.init(
      role: .user, 
      content: """
      <keywords>
      \(templateOptions.keyword)
      </keywords>
      """
    ))
    chat = chatToAttributedString(gptHistory)
    document.chatHistory = gptHistory
    updateDocument(force: true)
    
    Task { @MainActor in
      do {
        isSpinning = true
        let responses = try await llm.invoke(
          messages: gptHistory,
          temperature: 0.0,
          numberOfVariants: 1,
          model: "gpt-4"
        )
        
        isSpinning = false
        guard !responses.isEmpty else { 
          return
        }
        
        self.gptHistory.append(.init(
          role: .assistant, 
          content: responses[0]
        ))
        
        print("OpenAI did respond:")
        print(responses[0])
      
        self.text.insert(parseMarkdown(responses[0]), at: self.text.startIndex)
        self.document.chatHistory = gptHistory
        self.updateDocument()
      } catch {
        print("Calling OpenAI failed")
        self.isSpinning = false
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14)
        container.foregroundColor = .red
        self.chat.append(AttributedString(error.localizedDescription).settingAttributes(container))
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
        role: .system, 
        content: systemPrompt.trimmingCharacters(in: .whitespaces)
      ))
    }
    gptHistory.append(.init(
      role: .user, 
      content: userPrompt.trimmingCharacters(in: .whitespaces)
    ))
    let history: [ChatOpenAILLM.Message]
    if createNewHistory {
      history = gptHistory.suffix(2)
    } else {
      history = gptHistory
    }
    chat = chatToAttributedString(gptHistory)
    document.chatHistory = gptHistory
    updateDocument(force: true)
    do {
      isSpinning = true
      let responses = try await llm.invoke(
        messages: history, 
        temperature: 0.0, 
        numberOfVariants: 1, 
        model: "gpt-4"
      )
      isSpinning = false
      guard !responses.isEmpty else { 
        return
      }
      
      self.gptHistory.append(.init(
        role: .assistant, 
        content: responses[0]
      ))
      self.chat = chatToAttributedString(self.gptHistory)
      
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
      self.isSpinning = false
      var container = AttributeContainer()
      container.font = .systemFont(ofSize: 14)
      container.foregroundColor = .red
      self.chat.append(AttributedString(error.localizedDescription).settingAttributes(container))
    }
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
  
  static func rgb(red: Int, green: Int, blue: Int, opacity: Double = 1) -> Color {
    .init(
      .sRGB,
      red: Double(red) / 255.0, 
      green: Double(green) / 255.0, 
      blue: Double(blue) / 255.0,
      opacity: opacity
    )
  }
  
  static func hex(_ hex: Int, opacity: Double = 1) -> Color {
    rgb(
      red: (hex & 0xFF0000) >> 16,
      green: (hex & 0x00FF00) >> 8,
      blue: hex & 0x0000FF,
      opacity: opacity
    )
  }
  
  enum palette {
    static var background = Color.hex(0x1C1C1C)
    static var background1 = Color.hex(0x2A2A2A)
    static var background2 = Color.hex(0x3A3A3A)
    static var primaryText = Color.hex(0xE0E0E0)
    static var secondaryText = Color.hex(0xB0B0B0)
    static var accentColor = Color.hex(0x3B8BFF)
    static var accentColor2 = Color.hex(0x42D77D)
    static var accentColor3 = Color.hex(0xFF647C)
    static var accentColor4 = Color.hex(0xFFC833)
    static var accentColor5 = Color.hex(0x31C1A8)
    static var selectionBackgroundColor = Color.hex(0x4A90E2)
    static var selectionTextColor = Color.hex(0xFFFFFF)
  }
}
