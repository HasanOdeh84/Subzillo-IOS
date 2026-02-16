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

enum EmailSyncStatus: Int {
    case syncing = 1
    case view = 0
    case sync = 2
    
    var buttonText: String {
        switch self {
        case .syncing: return "Syncing..."
        case .view: return "View"
        case .sync: return "Sync"
        }
    }
}

struct ConnectedEmail: Identifiable {
    let id : String
    let email: String
    let date: String
    let status: EmailSyncStatus
    let provider: EmailProvider
}

struct ListConnectedEmailsRequest: Codable{
    let userId  : String
}

struct ListConnectedEmailsResponse: Codable {
    let message : String?
    let data    : [ListConnectedEmailsData]?
}

struct ListConnectedEmailsData: Codable, Hashable, Identifiable {
    var id                  : String?
    let email               : String?
    let type                : Int? // type -> 1- Gmail, 2- Microsoft
    let viewStatus          : Bool?
    let syncStatus          : Int? //syncStatus -> 0 - Not synced/ Sync completed, 1 - In Progres
    let lastSyncDate        : String? 
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
