//
//  SideBarView.swift
//  Genly
//
//  Created by Toni K. Turk on 02/05/2023.
//

import SwiftUI

struct SideBarView: View {
  @ObservedObject var viewModel: ViewModel
  var start: ((TemplateOptions) -> Void)?
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    self.start = nil
  }
  
  init(viewModel: ViewModel, start: @escaping (TemplateOptions) -> Void) {
    self.viewModel = viewModel
    self.start = start
  }
  
  var body: some View {
    HStack {
      VStack {
        HStack(spacing: 40) {
          PairView(text: "Language") { 
            DropDownSelectionView(
              selectedOption: $viewModel.languageOption, 
              placeholder: "Select langauge", 
              options: ["English", "Slovene"]
            )
          }
          PairView(text: "Tone") { 
            DropDownSelectionView(
              selectedOption: $viewModel.toneOption, 
              placeholder: "Select tone", 
              options: ["Convincing", "Academic", "Professional", "Friendly", "Formal", "Funny"]
            )
          }
        }
        HStack(spacing: 40) {
          PairView(text: "Creativity") { 
            DropDownSelectionView(
              selectedOption: $viewModel.creativityOption, 
              placeholder: "Select creativity level", 
              options: ["High", "Mid", "Low", "Optimal"]
            )
          }
          PairView(text: "Variants") { 
            DropDownSelectionView(
              selectedOption: $viewModel.variantsCount, 
              placeholder: "Select number of generated variants", 
              options: [1, 2, 3]
            )
          }
        }
        HStack(spacing: 40) {
          PairView(text: "Primary keyword") { 
            TextField("Keyword", text: $viewModel.keyword)
          }
          if !viewModel.useCases.useCases.isEmpty {
            PairView(text: "Use case") { 
              DropDownSelectionView(
                selectedOption: $viewModel.useCaseOption, 
                placeholder: "Select use case", 
                options: viewModel.useCases.useCases.map { $0.description }
              )
            }
          }
          if let start {
            Button("Start") { 
              guard !viewModel.languageOption.isEmpty,
                    !viewModel.toneOption.isEmpty,
                    !viewModel.creativityOption.isEmpty,
                    viewModel.variantsCount > 0,
                    !viewModel.keyword.isEmpty else { return }
              start(.init(
                languageOption: viewModel.languageOption, 
                toneOption: viewModel.toneOption, 
                creativityOption: viewModel.creativityOption, 
                useCaseOption: viewModel.useCaseOption,
                variantsCount: viewModel.variantsCount, 
                keyword: viewModel.keyword
              ))
            }
          }
        }
        .padding(20)
      }
      .cornerRadius(16)
      .background(Color(red: 0.2, green: 0.2, blue: 0.2))
    }
  }
}

extension SideBarView {
  class ViewModel: ObservableObject {
    @Published var languageOption: String = "English"
    @Published var toneOption: String = "Convincing"
    @Published var creativityOption: String = "Optimal"
    @Published var useCaseOption: String = ""
    @Published var variantsCount: Int = 1
    @Published var keyword: String = ""
    @Published var useCases: UseCases = .init(useCases: [])
  }
  
  struct TemplateOptions: Hashable, Codable {
    var languageOption: String
    var toneOption: String
    var creativityOption: String
    var useCaseOption: String
    var variantsCount: Int
    var keyword: String
  }
}

extension SideBarView {
  struct PairView<V: View>: View {
    let text: String
    let actionView: () -> V
    
    var body: some View {
      VStack(spacing: 10) {
        Text(text)
          .foregroundColor(.primary)
          .font(.system(size: 14))
          .frame(maxWidth: 100)
          .lineLimit(2)
        actionView()
      }
    }
  }
  
  struct DropDownSelectionView<T: CustomStringConvertible & Hashable>: View {
    @Binding var selectedOption: T
    
    let placeholder: String
    let options: [T]
    
    var body: some View {
      Picker(placeholder, selection: $selectedOption) {
        ForEach(options, id: \.self) {
          Text($0.description)
        }
      }
      .pickerStyle(.menu)
    }
  }
}
