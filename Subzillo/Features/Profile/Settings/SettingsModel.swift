//
//  SettingsModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/01/26.
//

import Foundation

public struct PrivacyDataResponse: Codable {
    var message : String?
    var data    : PrivacyDataResponseData?
}

public struct PrivacyDataResponseData: Codable {
    var content : String?
    var email   : String?
    var phone   : String?
}

public struct DeleteAccountRequest: Codable {
    var userId  : String?
}

public struct ToggleRemindersRequest: Codable {
    let userId              : String
    let type                : Int //type -> 1 - renewal reminders, 2- price change reminders, 3 - both (same status will be applied)
    let status              : Bool //status -> true - enable, false - disable
}

public struct EmailAutoSyncRequest: Codable {
    let userId              : String
    let type                : Int
}

struct ExportSubscriptionDataRequest: Codable{
    let userId          : String
}

struct ListSyncPeriodRequest: Codable{
    let userId          : String
}

public struct ListSyncPeriodResponse: Codable {
    var message : String?
    var data    : [ListSyncPeriodResponseData]?
}

public struct ListSyncPeriodResponseData: Codable,Equatable {
    var id              : String?
    var label           : String?
    var durationValue   : Int?
    var durationType    : String?
    var isSelected      : Bool?
}

public struct UpdateSyncPeriodRequest: Codable {
    let userId              : String
    let syncPeriodId        : String
}
