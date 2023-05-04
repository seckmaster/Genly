//
//  AppConfigStorage.swift
//  Genly
//
//  Created by Toni K. Turk on 02/05/2023.
//

import Foundation

struct AppConfigStorage {
  struct AppConfig: Codable {
    let apiKey: String
  }
  
  var config: AppConfig {
    get throws {
      let data = try Data(contentsOf: url)
      let config = try JSONDecoder().decode(AppConfig.self, from: data)
      return config
    } 
  }
  
  func store(config: AppConfig) throws {
    let data = try JSONEncoder().encode(config)
    try data.write(to: url)
  }
  
  func delete() throws {
    try FileManager.default.removeItem(at: url)
  }
  
  private var url: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("config")
  }
}
