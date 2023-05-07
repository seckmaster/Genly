//
//  MainView.swift
//  Genly
//
//  Created by Toni K. Turk on 02/05/2023.
//

import SwiftUI
import RichTextKit

struct MainView: View {
  @ObservedObject var router: Router
  @ObservedObject var viewModel: ViewModel
  @ObservedObject var sideBarViewModel: SideBarView.ViewModel = .init()
  @State var options: SideBarView.TemplateOptions?
  
  var body: some View {
    NavigationStack(path: $router.path) {
      HStack {
        SideBarView(viewModel: sideBarViewModel) {
          options = $0
          router.path.append($0)
        }
        .padding(40)
        List {
          ForEach(viewModel.documents, id: \.self) { document in 
            Button(document.displayName) {
              router.path.append(document)
            }
          }
        }
      }
      .navigationDestination(for: SideBarView.TemplateOptions.self) { options in
        DocumentView(
          source: .new(options), 
          apiKey: try! AppConfigStorage().config.apiKey,
          sideBarViewModel: sideBarViewModel,
          router: router,
          commands: viewModel.useCases.useCases.first { $0.prompt.name ==  options.useCaseOption }!.commands
        )
      }
      .navigationDestination(for: Document.self) { document in
        DocumentView(
          source: .existing(document), 
          apiKey: try! AppConfigStorage().config.apiKey,
          sideBarViewModel: sideBarViewModel,
          router: router,
          commands: viewModel.useCases.useCases.first { $0.prompt.name == document.templateOptions.useCaseOption }!.commands
        )
      }
//      .navigationTitle("Genly")
    }
    .navigationTitle("Genly")
    .onAppear {
      load(initial: true)
    }
    .enterApiKey(
      isVisible: $viewModel.mustEnterApiKey, 
      save: { apiKey in
        do {
          try viewModel.saveConfig(.init(apiKey: apiKey))
          viewModel.loadConfig()
        } catch {}
      }
    )
    .onChange(of: router.path) { @MainActor newValue in
      load(initial: false)
    }
  }
  
  private func load(initial: Bool) {
    if initial {
      viewModel.loadConfig()
    }
    do {
      try viewModel.loadDocuments()
    } catch {
      print(error)
    }
    do {
      try viewModel.loadUseCases()
      sideBarViewModel.useCases = viewModel.useCases
    } catch {
      print(error)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(router: .init(), viewModel: .init())
  }
}

extension MainView {
  class Router: ObservableObject {
    @Published var path: NavigationPath = .init()
  }
  
  class ViewModel: ObservableObject {
    let storage: AppConfigStorage
    let documentsStorage: DocumentStorage = try! .init()
    let promptsStorage: PromptsStorage = .init()
    
    private(set) var apiKey: String?
    
    @Published var mustEnterApiKey: Bool = false
    @Published var documents: [Document] = []
    @Published var useCases: UseCases = .init(useCases: [])
    
    init(storage: AppConfigStorage = .init()) {
      self.storage = storage
    }
  
    func loadConfig() {
      do {
        let config = try storage.config
        mustEnterApiKey = false
        apiKey = config.apiKey
      } catch {
        mustEnterApiKey = true
        apiKey = nil
      }
    }
    
    func saveConfig(_ config: AppConfigStorage.AppConfig) throws {
      try storage.store(config: config)
    }
    
    @MainActor
    func loadDocuments() throws {
      documents = try documentsStorage
        .documents()
        .map { try documentsStorage.loadDocument(for: $0) }
        .sorted(by: { $0.createdAt < $1.createdAt })
    }
    
    @MainActor
    func loadUseCases() throws {
      useCases = try promptsStorage.load()
    }
  }
}
