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
      SideBarView {
        options = $0
        router.path.append($0)
      }
      .navigationDestination(for: SideBarView.TemplateOptions.self) {
        DocumentView(templateOptions: $0, apiKey: try! AppConfigStorage().config.apiKey)
      }
    }
    .onAppear {
      viewModel.loadConfig()
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
    private let storage: AppConfigStorage
    
    @Published var mustEnterApiKey: Bool = false
    private(set) var apiKey: String?
    
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
  }
}
