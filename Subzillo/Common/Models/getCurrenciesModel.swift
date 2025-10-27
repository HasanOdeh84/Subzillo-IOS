//
//  getCurrenciesModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 13/10/25.
//

import Foundation

public struct getCurrenciesResponse: Codable {
    let message : String?
    let data    : [Currency]?
}

public struct Currency: Codable, Hashable {
    let id          : String?
    let name        : String?
    let symbol      : String?
    let code        : String?
}
