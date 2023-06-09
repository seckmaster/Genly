//
//  GenlyApp.swift
//  Genly
//
//  Created by Toni K. Turk on 02/05/2023.
//

import SwiftUI

@main
struct GenlyApp: App {
  var body: some Scene {
    WindowGroup {
      MainView(router: .init(), viewModel: .init())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
