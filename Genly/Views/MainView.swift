//
//  MainView.swift
//  Genly
//
//  Created by Toni K. Turk on 02/05/2023.
//

import SwiftUI

private var documentViewModel: DocumentView.ViewModel?

struct MainView: View {
  @ObservedObject var router: Router
  @ObservedObject var viewModel: ViewModel
  @ObservedObject var sideBarViewModel: SideBarView.ViewModel = .init()
  @State var options: SideBarView.TemplateOptions?
  
  var body: some View {
    GeometryReader { reader in
      NavigationStack(path: $router.path) {
        HStack {
          VStack {
            SideBarView(viewModel: sideBarViewModel) {
              options = $0
              router.path.append($0)
            }
            .padding(40)
            if let apiKey = viewModel.apiKey {
              GPTConsole(viewModel: .init(apiKey: apiKey))
            }
          }
          GeometryReader { reader in 
            List {
              ForEach(viewModel.documents, id: \.self) { document in
                Button {
                  router.path.append(document)
                } label: {
                  ZStack {
                    RightClickableSwiftUIView {
                      viewModel.popoverDocument = .init(
                        point: .init(), 
                        document: document
                      )
                    }
                    Text(document.displayName)
                  }
                }
                .buttonStyle(.plain)
                .frame(width: reader.size.width, height: 40)
                .background(Color(nsColor: .darkGray))
              }
            }
          }
        }
        .navigationDestination(for: SideBarView.TemplateOptions.self) { options in
          { () -> DocumentView in
            documentViewModel = documentViewModel ?? .init(
              source: .new(options), 
              apiKey: viewModel.apiKey ?? "", 
              useCase: viewModel.useCases.useCases.first { $0.prompt.name == options.useCaseOption }!
            )
            return DocumentView(
              documentViewModel: documentViewModel!,
              apiKey: viewModel.apiKey ?? "",
              sideBarViewModel: sideBarViewModel,
              router: router
            )
          }()
        }
        .navigationDestination(for: Document.self) { document in
          DocumentView(
            documentViewModel: .init(
              source: .existing(document), 
              apiKey: viewModel.apiKey ?? "", 
              useCase: viewModel.useCases.useCases.first { $0.prompt.name == document.templateOptions.useCaseOption }!
            ), 
            apiKey: viewModel.apiKey ?? "",
            sideBarViewModel: sideBarViewModel,
            router: router
          )
        }
      }
      .popover(
        item: $viewModel.popoverDocument
      ) { document in
        DocumentView(
          documentViewModel: .init(
            source: .existing(document.document), 
            apiKey: viewModel.apiKey ?? "", 
            useCase: viewModel.useCases.useCases.first { $0.prompt.name == document.document.templateOptions.useCaseOption }!
          ),
          apiKey: viewModel.apiKey ?? "",
          sideBarViewModel: sideBarViewModel,
          router: router
        )
        .frame(minWidth: reader.size.width * 0.8, minHeight: reader.size.height * 0.8)
        .onDisappear {
          load(initial: false)
        }
      }
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
      documentViewModel = nil
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
    @Published var popoverDocument: ClickedDocument?
    
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
  
  struct ClickedDocument: Identifiable, Hashable {
    let point: UnitPoint
    let document: Document
    
    var id: UUID { document.id }
  }
}

struct RightClickableSwiftUIView: NSViewRepresentable {
  let rightAction: () -> Void
  
  func makeNSView(context: Context) -> RightClickableView {
    RightClickableView(rightAction: rightAction)
  }
  
  func updateNSView(_ nsView: RightClickableView, context: NSViewRepresentableContext<RightClickableSwiftUIView>) {
  }
}

class RightClickableView: NSView {
  let rightAction: () -> Void
  
  init(rightAction: @escaping () -> Void) {
    self.rightAction = rightAction
    super.init(frame: .zero)
  } 
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func mouseDown(with theEvent: NSEvent) {
  }
  
  override func rightMouseDown(with theEvent: NSEvent) {
    rightAction()
  }
}
