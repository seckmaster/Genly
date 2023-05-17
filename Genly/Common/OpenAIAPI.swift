//
//  OpenAIAPI.swift
//  Genly
//
//  Created by Toni K. Turk on 02/05/2023.
//

import Foundation

class OpenAIAPI {
  struct Message: Encodable, Decodable, Equatable, Hashable {
    let role: String
    let content: String
  }
  
  private let session: URLSession
  
  init() {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 600
    config.timeoutIntervalForResource = 600
    self.session = .init(configuration: config)
  }
  
  func completion(
    model: String = "gpt-4",
    temperature: Double,
    variants: Int,
    messages: [Message],
    apiKey: String
  ) async throws -> [String] {
    struct Request: Encodable {
      let model: String
      let messages: [Message]
      let temperature: Double
      let n: Int
    }
    let request = Request(
      model: model, 
      messages: messages, 
      temperature: temperature,
      n: variants
    )
    
    var urlRequest = URLRequest(url: "https://api.openai.com/v1/chat/completions")
    urlRequest.httpBody = try JSONEncoder().encode(request)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    let data = try await session.data(for: urlRequest).0
    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { 
      throw NSError()
    }
    return ((((json["choices"] as? [[String: Any]])?[0] as? [String: Any])?["message"] as? [String: Any])?["content"] as? String).map { [$0] } ?? []
  }
}

extension URL: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self = .init(string: value)!
  }
}
