//
//  PromptsStorage.swift
//  Genly
//
//  Created by Toni K. Turk on 07/05/2023.
//

import Foundation

class PromptsStorage {
  init() {
    if !FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: nil) {
      FileManager.default.createFile(atPath: url.absoluteString, contents: .init())
    }
  } 
  
  func load() throws -> UseCases {
    let data = try Data(contentsOf: url)
    let prompts = try JSONDecoder().decode(UseCases.self, from: data)
    return prompts
  } 
  
  var url: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "prompts.json")
  } 
}

struct UseCases: Codable, Hashable {
  struct UseCase: Codable, Hashable, CustomStringConvertible {
    let prompt: Prompt
    let commands: [Prompt]
    
    var description: String { prompt.name }
  }
  
  let useCases: [UseCase]
}

extension UseCases {
  struct Prompt: Codable, Hashable {
    var name: String
    var systemPrompt: String
    var userPrompt: String
  }
}

extension String {
  func applyArgs(_ args: (key: String, value: String)...) -> String {
    var str = self
    while true {
      guard let range = str.ranges(of: />>@(.+?)?@<</).first else { break }
      let key = str[range].dropFirst(3).dropLast(3)
      switch key {
      case "":
        str.replaceSubrange(range, with: args.first!.value)
      case "LANG":
        str.replaceSubrange(range, with: args.first(where: { $0.key == "LANG" })!.value)
      case "TONE":
        str.replaceSubrange(range, with: args.first(where: { $0.key == "TONE" })!.value)
      case _:
        fatalError()
      }
    }
    return str
  }
}
