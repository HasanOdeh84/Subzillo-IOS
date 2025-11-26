//
//  FilterModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 18/11/25.
//

import Foundation

struct FilterModel: Codable {
    var includeFamilySubscriptions      : Bool = false
    var includeExpiredSubscriptions     : Bool = false
    var costOrder                       : OrderType = .none
    var renewalDateOrder                : OrderType = .none
}
