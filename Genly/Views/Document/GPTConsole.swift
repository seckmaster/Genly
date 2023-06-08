//
//  GPTConsole.swift
//  Genly
//
//  Created by Toni K. Turk on 10/05/2023.
//

import SwiftUI
import SwiftchainOpenAI

struct GPTConsole: View {
  @ObservedObject var viewModel: ViewModel
  @State var editingText: String = ""
  @State var isLoading: Bool = false
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    GeometryReader { metrics in
      VStack(alignment: .leading) {
        TextView(text: $viewModel.historyText)
          .frame(height: metrics.size.height * 0.70)
          .frame(maxWidth: .infinity)
          .background(Color.palette.background1)
          .cornerRadius(12)
        ZStack {
          GeometryReader { zstackMetrics in
            HStack {
              TextEditor(text: $editingText)
                .font(Font.system(size: 14))
                .scrollContentBackground(.hidden)
            }
            .padding()
            Button {
              viewModel.reset()
            } label: {
              Image(systemName: "trash.slash.fill")
                .frame(width: 40, height: 40)
            }
            .frame(minWidth: 80, minHeight: 80)
            .buttonStyle(.plain)
            .position(.init(x: zstackMetrics.size.width - 20, y: 20))
            LoadingButton(isLoading: $isLoading) { 
              Task {
                guard !editingText.isEmpty else { return }
                isLoading = true
                let text = editingText
                editingText = ""
                await viewModel.callGPT(text: text)
                isLoading = false
              }
            } label: { 
              Image(systemName: "paperplane.fill")
                .frame(width: 40, height: 40)
            }
            .frame(minWidth: 80, minHeight: 80)
            .buttonStyle(.plain)
            .position(.init(x: zstackMetrics.size.width - 20, y: zstackMetrics.size.height - 15))
          }
        }
        .frame(height: max(0, metrics.size.height * 0.30 - 40))
        .background(Color.palette.background2)
        .cornerRadius(12)
      }
      .padding(.all, 20)
      .background(Color.palette.background)
      .cornerRadius(12)
    }
  }
  
  class ViewModel: ObservableObject {
    @Published var historyText: AttributedString
    private let llm: ChatOpenAILLM
    private var history: [ChatOpenAILLM.Message] = [
      .init(
        role: .system, 
        content: "You are a helpful assistant. Respond to user's queries in an informative, professional and honest manner."
      )
    ]
    
    init(apiKey: String) {
      self.llm = .init(apiKey: apiKey)
      self.historyText = chatToAttributedString(history)
    }
    
    @MainActor
    func callGPT(text: String) async {
      history.append(.init(role: .user, content: text))
      historyText = chatToAttributedString(history)
      do {
        let response = try await llm.invoke(
          history.filter { $0.role.rawValue != "error" }, 
          temperature: 0.0, 
          numberOfVariants: 1, 
          model: "gpt-4"
        )
        guard !response.messages.isEmpty else { return }
        history.append(.init(role: .assistant, content: response.messages[0].content))
        historyText = chatToAttributedString(history)
      } catch {
        history.append(.init(role: .custom("error"), content: String(describing: error)))
        historyText = chatToAttributedString(history)
      }
    }
    
    func reset() {
      history.removeLast(history.count - 1)
      historyText = chatToAttributedString(history)
    }
  }
}

struct LoadingButton<T: View>: View {
  @Binding var isLoading: Bool
  let action: () -> Void
  let label: () -> T
  
  var body: some View {
    Button {
      action()
    } label: {
      if isLoading {
        ProgressView()
          .tint(.white)
      } else {
        label()
      }
    }
    .disabled(isLoading)
  }
}
