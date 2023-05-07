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
  let router: MainView.Router
  @ObservedObject var viewModel: ViewModel
  @ObservedObject var sideBarViewModel: SideBarView.ViewModel
  
  init(
    source: DocumentSource, 
    apiKey: String,
    sideBarViewModel: SideBarView.ViewModel,
    router: MainView.Router,
    commands: [UseCases.Prompt]
  ) {
    self.source = source
    self.viewModel = .init(source: source, apiKey: apiKey, commands: commands)
    self.sideBarViewModel = sideBarViewModel
    self.router = router
    delegate = .init(view: .init(value: self))
  }
  
  var body: some View {
    GeometryReader { metrics in
      HStack {
//        SideBarView(viewModel: sideBarViewModel)
//          .frame(maxWidth: metrics.size.width * 0.23)
        HStack {
          VStack(alignment: .leading) {
            HStack(spacing: 40) {
              TextControlsPane(
                isBoldHighlighted: $viewModel.isBoldHighlighted, 
                isItalicHighlighted: $viewModel.isItalicHighlighted, 
                isUnderlineHighlighted: $viewModel.isUnderlineHighlighted,
                isHeading1: $viewModel.isHeading1,
                isHeading2: $viewModel.isHeading2,
                isHeading3: $viewModel.isHeading3,
                boldAction: {
                  handleTextEditingAction(
                    predicate: {
                      $0.isBold
                    }, 
                    ifPredicate: {
                      if $0.isItalic { 
                        return .systemFont(ofSize: $0.pointSize).withTraits([
                          .italic
                        ])
                      } else {
                        return .systemFont(ofSize: $0.pointSize)
                      }
                    }, 
                    ifNotPredicate: {
                      if $0.isItalic { 
                        return .systemFont(ofSize: $0.pointSize).withTraits([
                          .italic, .bold
                        ])
                      } else {
                        return .systemFont(ofSize: $0.pointSize).withTraits([
                          .bold
                        ])
                      }
                    },
                    applyToWholeParagraph: false,
                    targetVariable: &viewModel.isBoldHighlighted
                  )
                },
                italicAction: {
                  handleTextEditingAction(
                    predicate: {
                      $0.isItalic
                    }, 
                    ifPredicate: {
                      if $0.isBold { 
                        return .systemFont(ofSize: $0.pointSize).withTraits([
                          .bold
                        ])
                      } else {
                        return .systemFont(ofSize: $0.pointSize)
                      }
                    }, 
                    ifNotPredicate: {
                      if $0.isBold { 
                        return .systemFont(ofSize: $0.pointSize).withTraits([
                          .bold, .italic
                        ])
                      } else {
                        return .systemFont(ofSize: $0.pointSize).withTraits([
                          .italic
                        ])
                      }
                    },
                    applyToWholeParagraph: false,
                    targetVariable: &viewModel.isItalicHighlighted
                  )
                },
                underlineAction: {
                },
                heading1Action: {
                  handleTextEditingAction(
                    predicate: { 
                      $0.isHeading1
                    }, 
                    ifPredicate: { 
                      .systemFont(ofSize: 14).withTraits($0.traits)
                    }, 
                    ifNotPredicate: {
                      .heading1.withTraits($0.traits)
                    },
                    targetVariable: &viewModel.isHeading1
                  )
                },
                heading2Action: {
                  handleTextEditingAction(
                    predicate: { 
                      $0.isHeading2
                    }, 
                    ifPredicate: { 
                      .systemFont(ofSize: 14).withTraits($0.traits)
                    }, 
                    ifNotPredicate: {
                      .heading2.withTraits($0.traits)
                    },
                    targetVariable: &viewModel.isHeading2
                  )
                },
                heading3Action: {
                  handleTextEditingAction(
                    predicate: { 
                      $0.isHeading3
                    }, 
                    ifPredicate: { 
                      .systemFont(ofSize: 14).withTraits($0.traits)
                    }, 
                    ifNotPredicate: {
                      .heading3.withTraits($0.traits)
                    },
                    targetVariable: &viewModel.isHeading3
                  )
                }
              )
              if viewModel.isSpinning {
                ProgressView()
                  .frame(width: 40, height: 40)
              }
              TextField("Title", text: $viewModel.title)
                .onChange(of: viewModel.title) { newValue in
                  viewModel.document.title = newValue
                  viewModel.updateDocument(force: true)
                }
              Button("Delete") {
                do {
                  try viewModel.deleteDocument()
                  router.path.removeLast()
                } catch {}
              }
            }
            ScrollView(.horizontal) {
              HStack {
                ForEach(viewModel.commands, id: \.self) { prompt in
                  Button(prompt.name) {
                    guard let nsRange = viewModel.selectedRanges.first else { return }
                    
                    let range = Range<AttributedString.Index>(nsRange, in: viewModel.text)!
                    let subtring = viewModel.text[range]
                    let string = NSAttributedString(AttributedString(subtring)).string
                    
                    let systemPrompt = prompt.systemPrompt.applyArgs(
                      ("TONE", viewModel.document.templateOptions.toneOption),
                      ("LANG", viewModel.document.templateOptions.languageOption)
                    )
                    let userPrompt = prompt.userPrompt.applyArgs(
                      ("", string)
                    )
                    
                    Task {
                      await viewModel.performCommand(
                        range: range, 
                        systemPrompt: systemPrompt,
                        userPrompt: userPrompt
                      )
                    }
                  }
                  .allowsHitTesting(!viewModel.selectedRanges.isEmpty && viewModel.selectedRanges[0].length > 0)
                  .background((!viewModel.selectedRanges.isEmpty && viewModel.selectedRanges[0].length > 0) ? .clear : .blue)
                }
              }
            }
            TextView(text: $viewModel.text, delegate: delegate)
              .focusable()
          }
          ScrollView(.vertical) {
            ScrollViewReader { reader in
              Text(viewModel.chat)
            }
          }.frame(maxWidth: metrics.size.width * 0.27)
        }
      }
    }
    .padding()
    .onAppear {
      viewModel.createNewDocument()
//      viewModel.loadGUI()
    }
  }
}

private extension DocumentView {
  func handleTextEditingAction(
    predicate: (NSFont) -> Bool,
    ifPredicate: (NSFont) -> NSFont,
    ifNotPredicate: (NSFont) -> NSFont,
    applyToWholeParagraph: Bool = true,
    targetVariable: inout Bool
  ) {
    guard var nsRange = viewModel.selectedRanges.first else { return }
    
    if applyToWholeParagraph {
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
    }
    
    let range = Range<AttributedString.Index>(nsRange, in: viewModel.text)!
    var string = AttributedString(viewModel.text[range])
    let nsfont = (NSAttributedString(string).fontAttributes(
      in: .init(
        location: 0, 
        length: nsRange.length
      ))[.font] as? NSFont
    ) ?? .systemFont(ofSize: 14)
    
    var container = AttributeContainer()
    container.foregroundColor = string.foregroundColor
    if predicate(nsfont) {
      container.font = ifPredicate(nsfont)
    } else {
      container.font = ifNotPredicate(nsfont)
    }
    string.setAttributes(container)
    viewModel.text.replaceSubrange(
      range,
      with: string
    )
    targetVariable = !predicate(nsfont)
  }
}

class Box<T> {
  var value: T
  
  init(value: T) {
    self.value = value
  }
}
