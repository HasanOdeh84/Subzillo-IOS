//
//  ConnectedEmailsListModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 10/01/26.
//

import Foundation

enum EmailProvider {
    case gmail
    case outlook
    case yahoo
    
    var iconName: String {
        switch self {
        case .gmail: return "google"
        case .outlook: return "microsoft"
        case .yahoo: return "yahoo"
        }
    }
}

enum EmailSyncStatus {
    case syncing
    case view
    case sync
    
    var buttonText: String {
        switch self {
        case .syncing: return "Syncing..."
        case .view: return "View"
        case .sync: return "Sync"
        }
    }
}

struct ConnectedEmail: Identifiable {
    let id = UUID()
    let email: String
    let date: String
    let status: EmailSyncStatus
    let provider: EmailProvider
}
