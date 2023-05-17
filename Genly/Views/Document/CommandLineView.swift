//
//  CommandLineView.swift
//  Genly
//
//  Created by Toni K. Turk on 10/05/2023.
//

import SwiftUI

struct CommandLineView: View {
  @ObservedObject var viewModel: ViewModel
  @State var editingText: String = ""
  @State var isLoading: Bool = false
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    GeometryReader { metrics in
      VStack(alignment: .leading) {
        ScrollView(.vertical) {
          Text(viewModel.historyText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
                .background(Color.black)
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
    private let apiKey: String
    private let api = OpenAIAPI()
    private var history: [OpenAIAPI.Message] = [
      .init(role: "system", content: "You are a helpful assistant. Respond to user's queries in an informative, professional and honest manner.")
    ]
    
    init(apiKey: String) {
      self.apiKey = apiKey
      self.historyText = chatToAttributedString(history)
    }
    
    @MainActor
    func callGPT(text: String) async {
      history.append(.init(role: "user", content: text))
      historyText = chatToAttributedString(history)
      do {
        let response = try await api.completion(
          temperature: 0.2, 
          variants: 1, 
          messages: history.filter { $0.role != "error" }, 
          apiKey: apiKey
        )
        history.append(.init(role: "assistant", content: response[0]))
        historyText = chatToAttributedString(history)
      } catch {
        history.append(.init(role: "error", content: String(describing: error)))
        historyText = chatToAttributedString(history)
      }
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
