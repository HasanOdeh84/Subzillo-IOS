//
//  ResponseContainer.swift
//  RajaKiRani
//
//  Created by KS-MACIMINI-016 on 20/03/25.
//


public struct ResponseContainer<T: Codable>: Codable {
  public let status: Int?
  public let message: String?
  public let data: T?
  public init(data: T?, message: String?, status: Int?) {
    self.data = data
    self.message = message
    self.status = status
  }
}

struct APIErrorResponse: Codable {
    let message: String
    let errors: [String: String]?
}
