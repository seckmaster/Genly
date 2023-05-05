//
//  CommandsView.swift
//  Genly
//
//  Created by Toni K. Turk on 04/05/2023.
//

import SwiftUI

struct CommandsView: View {
  let paragraphAction: () -> Void
  let shortenAction: () -> Void
  let expandAction: () -> Void
  let rephraseAction: () -> Void
  let improveAction: () -> Void
  
  var body: some View { 
    HStack(spacing: 10) { 
      Button("Paragraph", action: paragraphAction)
      Button("Shorten", action: shortenAction)
      Button("Expand", action: expandAction)
      Button("Rephrase", action: rephraseAction)
      Button("Improve", action: improveAction)
    }
  }
}
