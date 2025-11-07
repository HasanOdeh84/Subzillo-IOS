//
//  getCountriesModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 07/11/25.
//

import Foundation

public struct getCountriesResponse: Codable {
    let message : String?
    let data    : [Country]?
}

public struct Country: Codable, Hashable {
    var id                  : Int?
    var countryName         : String?
    var countryCode         : String?
    var dialCode            : String?
    var countryFlag         : String?
}
