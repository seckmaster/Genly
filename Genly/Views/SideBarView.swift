//
//  SideBarView.swift
//  Genly
//
//  Created by Toni K. Turk on 02/05/2023.
//

import SwiftUI

struct SideBarView: View {
  @ObservedObject var viewModel = ViewModel()
  
  var start: (TemplateOptions) -> Void
  
  var body: some View {
    HStack {
      VStack {
        HStack(spacing: 40) {
          PairView(text: "Language") { 
            DropDownSelectionView(
              selectedOption: $viewModel.languageOption, 
              placeholder: "Select langauge", 
              options: ["English", "Slovenian"]
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
          switch viewModel.useCaseOption {
          case .blogIdeaAndOutline:
            PairView(text: "Primary keyword") { 
              TextField("Keyword", text: $viewModel.keyword)
            }
          case .blogSection:
            PairView(text: "Keywords (separate with comma - ',')") { 
              TextField("Keywords", text: $viewModel.keyword)
            }
          case .businessPitch:
            PairView(text: "Business idea") { 
              TextField("Business idea", text: $viewModel.keyword)
            }
          case .email:
            PairView(text: "Key points") { 
              TextField("Key points", text: $viewModel.keyword)
            }
          }
          PairView(text: "Use case") { 
            DropDownSelectionView(
              selectedOption: $viewModel.useCaseOption, 
              placeholder: "Select use case", 
              options: UseCaseOption.allCases
            )
          }
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
      .padding(40)
    }
  }
}

extension SideBarView {
  enum UseCaseOption: String, Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case blogIdeaAndOutline = "Blog idea and outline"
    case blogSection = "Blog section writing"
    case businessPitch = "Business pitch"
    case email = "Email"
    
    var description: String { self.rawValue }
  }
  
  class ViewModel: ObservableObject {
    @Published var languageOption: String = "English"
    @Published var toneOption: String = "Convincing"
    @Published var creativityOption: String = "Optimal"
    @Published var useCaseOption: UseCaseOption = .blogIdeaAndOutline
    @Published var variantsCount: Int = 1
    @Published var keyword: String = "Training a dog"
  }
  
  struct TemplateOptions: Hashable {
    var languageOption: String
    var toneOption: String
    var creativityOption: String
    var useCaseOption: UseCaseOption
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