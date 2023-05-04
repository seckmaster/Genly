//
//  DocumentStorage.swift
//  Genly
//
//  Created by Toni K. Turk on 03/05/2023.
//

import Foundation

struct Document: Identifiable, Codable, Hashable {
  var id: UUID
  var title: String?
  var text: AttributedString
  var createdAt: Date
  var lastModifiedAt: Date
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct DocumentStorage {
  init() throws {
    if !FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: nil) {
      try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
    }
  }
  
  func documents() throws -> [Document.ID] {
    let items = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    return items.map { .init(uuidString: $0.lastPathComponent)! }
  }
  
  func loadDocument(for id: Document.ID) throws -> Document {
    let document = try JSONDecoder().decode(
      Document.self, 
      from: Data(contentsOf: url.appending(path: id))
    )
    return document
  }
  
  func store(document: Document) throws {
    let data = try JSONEncoder().encode(document)
    try data.write(to: url.appending(path: document.id))
  }
  
  func delete(document: Document) throws {
    try FileManager.default.removeItem(at: url.appending(path: document.id))
  }
  
  private var url: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "documents")
  }
}

extension URL {
  func appending(path: UUID) -> URL {
    appending(path: path.uuidString)
  }
}
