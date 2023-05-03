//
//  TextControlsPane.swift
//  Genly
//
//  Created by Toni K. Turk on 03/05/2023.
//

import SwiftUI

struct TextControlsPane: View {
  @Binding var isBoldHighlighted: Bool
  @Binding var isItalicHighlighted: Bool
  @Binding var isUnderlineHighlighted: Bool
  @Binding var isHeading1: Bool
  @Binding var isHeading2: Bool
  @Binding var isHeading3: Bool
  let boldAction: () -> Void
  let italicAction: () -> Void
  let underlineAction: () -> Void
  let heading1Action: () -> Void
  let heading2Action: () -> Void
  let heading3Action: () -> Void
  
  var body: some View {
    HStack(spacing: 10) { 
      ControlPaneButton(title: "B", isHighlighted: $isBoldHighlighted, action: boldAction)
      ControlPaneButton(title: "i", isHighlighted: $isItalicHighlighted, action: italicAction)
      ControlPaneButton(title: "U", isHighlighted: $isUnderlineHighlighted, action: underlineAction)
      ControlPaneButton(title: "H1", isHighlighted: $isHeading1, action: heading1Action)
      ControlPaneButton(title: "H2", isHighlighted: $isHeading2, action: heading2Action)
      ControlPaneButton(title: "H3", isHighlighted: $isHeading3, action: heading3Action)
    }
  }
}

struct ControlPaneButton: View {
  let title: String
  @Binding var isHighlighted: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 14))
        .foregroundColor(.black)
        .frame(width: 20, height: 30)
    }
    .background(isHighlighted ? .yellow : .clear)
  }
}
