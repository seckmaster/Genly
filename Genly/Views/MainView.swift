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
  @State var options: SideBarView.TemplateOptions?
  
  var body: some View {
    NavigationStack(path: $router.path) {
      HStack {
        SideBarView {
          options = $0
          router.path.append($0)
        }
        .padding(40)
        List {
          ForEach(viewModel.documents, id: \.self) { id in 
            Button(id.uuidString) {
              do {
                let document = try viewModel.documentsStorage.loadDocument(for: id)
                router.path.append(document)
              } catch {
                print(error)
              }
            }
          }
        }
      }
      .navigationDestination(for: SideBarView.TemplateOptions.self) {
        DocumentView(source: .new($0), apiKey: try! AppConfigStorage().config.apiKey)
      }
      .navigationDestination(for: Document.self) {
        DocumentView(
          source: .existing($0), 
          apiKey: try! AppConfigStorage().config.apiKey
        )
      }
//      .navigationTitle("Genly")
    }
    .navigationTitle("Genly")
    .onAppear {
      viewModel.loadConfig()
      try! viewModel.loadDocuments()
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
    .onChange(of: router.path) { newValue in
      try! viewModel.loadDocuments()
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
    
    private(set) var apiKey: String?
    
    @Published var mustEnterApiKey: Bool = false
    @Published var documents: [Document.ID] = []
    
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
    
    func loadDocuments() throws {
      documents = try documentsStorage.documents()
    }
  }
}
