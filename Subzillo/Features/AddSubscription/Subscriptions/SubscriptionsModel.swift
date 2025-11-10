//
//  SubscriptionsModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 06/11/25.
//

import Foundation

struct SubscriptionInfo: Identifiable {
    var id                      : String
    var userId                  : String?
    var amount                  : Double?
    var currency                : String?
    var createdAt               : String?
    var updatedAt               : String?
    var plans                   : [PlanInfo]?
    var relations               : [RelationsInfo]?
    var cardsCount              : Int?
    var isOpen                  : Bool?
}
struct PlanInfo: Codable {
    var id                      : String
    var name                    : String?
    var image                   : String?
    var amount                  : Double?
    var currency                : String?
    var card                    : String?
}
struct RelationsInfo: Codable {
    var id                      : String
    var name                    : String?
    var color                   : String?
    var plans                   : [PlanInfo]?
}
