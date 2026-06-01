//
//  NotificationsModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/01/26.
//

import Foundation

public struct NotificationsListRequest: Codable {
    let userId              : String
    let page                : Int
    let tabId                 : Int
}

public struct NotificationsListResponse: Codable {
    var message : String?
    var data    : NotificationsListResponseData?
}

public struct NotificationsListResponseData: Codable {
    var unreadCount         : Int?
    var notifications       : [NotificationData]?
    var totalCount          : Int?
    var totalPages          : Int?
}

struct NotificationData: Identifiable, Equatable, Codable {
    var id                    : String = UUID().uuidString
    var title                 : String?
    var message               : String?
    var readStatus            : Bool?
    var isSelected            : Bool? = false
    var createdAt             : String?
    var type                  : Int?
    var subscriptionId        : String?
    var redirectLink          : String?
    var notificationData      : NotificationDataObj?
    
    enum CodingKeys: String, CodingKey {
        case id, title, message, readStatus, createdAt, type, subscriptionId, notificationData
    }
}

struct NotificationDataObj: Equatable, Codable {
    var type                    : String?
    var image                   : String?
    var title                   : String?
    var message                 : String?
    var redirectLink            : String?
    var marketingNotificationId : String?
    var email                   : String?
    var integrationId           : String?
}

public struct MarkNotificationReadRequest: Codable {
    let userId              : String
    let notificationId      : String
    let type                : Int //type -> 1 - mark all notifications as read, 2 - mark single notification as read
    let tabId                 : Int
}

public struct DeleteNotificationRequest: Codable {
    let userId              : String
    let notificationIds     : [String]
    let tab                 : Int
}
