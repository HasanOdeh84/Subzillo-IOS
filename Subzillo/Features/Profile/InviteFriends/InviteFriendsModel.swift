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
    var data                    : [RewardsData]?
}

struct RewardsData: Identifiable, Codable {
    var id                  : String { rewardId ?? UUID().uuidString }
    let rewardId            : String?
    let requiredReferrals   : Int?
    let subscriptionCount   : Int?
    let status              : Bool?
    let redeemStatus        : Bool?
}

struct RedeemRewardRequest: Codable {
    var rewardId: String
}
