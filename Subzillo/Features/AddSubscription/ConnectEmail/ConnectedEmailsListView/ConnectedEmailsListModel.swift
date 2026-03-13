//
//  ConnectedEmailsListModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 10/01/26.
//

import Foundation

enum EmailProvider: Int {
    case gmail = 1
    case microsoft = 2
    case yahoo = 3
    
    var iconName: String {
        switch self {
        case .gmail: return "google2"
        case .microsoft: return "micorsoft2"
        case .yahoo: return "yahoo"
        }
    }
}

struct EmailApproachStatus: Codable, Hashable {
    let viewStatus  : Bool?
    let syncStatus  : Int?  // 0 - Sync, 1 - Syncing, 2 - Completed (show View if viewStatus true)
}

//struct ConnectedEmail: Identifiable {
//    let id : String
//    let email: String
//    let date: String
//    let status: EmailSyncStatus
//    let provider: EmailProvider
//}

struct ListConnectedEmailsRequest: Codable{
    let userId  : String
}

struct ListConnectedEmailsResponse: Codable {
    let message : String?
    let data    : [ListConnectedEmailsData]?
}

//struct EmailApproaches: Codable, Hashable {
//    let advanced    : EmailApproachStatus?
//    let mvp         : EmailApproachStatus?
//    let hybrid      : EmailApproachStatus?
//}

struct ListConnectedEmailsData: Codable, Hashable, Identifiable {
    var id                  : String?
    let email               : String?
    let type                : Int?          // 1 - Gmail, 2 - Microsoft, 3 - Yahoo
    let lastSyncDate        : String?
    let viewStatus          : Bool?
    let syncStatus          : Int?
//    let approaches          : EmailApproaches?
}

struct DeleteEmailRequest: Codable{
    let userId          : String
    let integrationId   : String
}

struct SyncEmailRequest: Codable{
    let userId          : String
    let integrationId   : String
    let type            : Int
}

struct SyncEmailResponse: Codable {
    let message : String?
//    let data    : [SyncEmailData]?
}

struct SyncEmailData: Codable, Hashable, Identifiable {
    var id                  : String?
    var userId              : String?
    var integrationId       : String?
    let email               : String?
    let serviceName         : String?
    let amount              : Double?
    let subject             : String?
    let from                : String?
    let date                : String? 
}

struct EmailSubscriptionsListRequest: Codable{
    let userId          : String
    let integrationId   : String
}

struct ExportGmailSyncLogsRequest: Codable{
    let userId          : String
    let integrationId   : String
}

struct ExportGmailSyncLogsResponse: Codable {
    let message : String?
}
