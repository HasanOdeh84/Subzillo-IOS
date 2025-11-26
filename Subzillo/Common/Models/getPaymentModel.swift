//
//  getPaymentModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 11/11/25.
//

import Foundation

public struct getPaymentMethodResponse: Codable {
    let message : String?
    let data    : [PaymentMethod]?
}

public struct PaymentMethod: Codable, Hashable {
    let id          : String?
    let name        : String?
    let status      : Bool?
}
