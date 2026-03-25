//
//  InviteFriendsModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 24/03/26.
//

import Foundation

struct RewardsRequest: Codable {
    var userId: String
}

public struct RewardsResponse: Codable {
    var message                 : String?
    var data                    : RewardsResponseData?
}

struct RewardsResponseData: Codable {
    let registeredCount     : Int?
    let subscribedCount     : Int?
    let availableCount      : Int?
    let usedCredits         : Int?
    let extraSlots          : Int?
    let rewards             : [RewardsData]?
}

struct RewardsData: Identifiable, Codable {
    var id                  : String { UUID().uuidString }
    var rewardConfigId      : String?
    let creditsRequired     : Int?
    let subscriptionReward  : Int?
    let eligible            : Bool?
    let redeemed            : Bool?
}

struct RedeemRewardRequest: Codable {
    var userId          : String
    var rewardConfigId  : String
}
