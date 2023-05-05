//
//  OpenAIAPI.swift
//  Genly
//
//  Created by Toni K. Turk on 02/05/2023.
//

import Foundation

class OpenAIAPI {
  let client = AlamofireNetworkClient()
  
  struct Message: Encodable, Decodable, Equatable, Hashable {
    let role: String
    let content: String
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
      let data = try await client
        .request(
          method: .post, 
          endpoint: "https://api.openai.com/v1/chat/completions",
          headers: [.authorization(bearerToken: apiKey)],
          encode: request,
          parameterEncoder: .json
        )
        .validate()
        .asDataAsync
      guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { 
        throw NSError()
      }
      return ((((json["choices"] as? [[String: Any]])?[0] as? [String: Any])?["message"] as? [String: Any])?["content"] as? String).map { [$0] } ?? []
  }
}
