//
//  GetCategoriesModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 13/10/25.
//

import Foundation

public struct getCategoriesResponse: Codable {
    let message : String?
    let data    : [Category]?
}

public struct Category: Codable {
    let id          : String?
    let name        : String?
    let icon_name   : String?
    let color_theme : String?
    let description : String?
}
