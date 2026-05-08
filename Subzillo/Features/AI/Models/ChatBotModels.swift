//
//  ChatBotModels.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 01/05/26.
//

import Foundation

struct WelcomeResponse: Codable {
    let reply: String
    let state: WelcomeState?
}

struct WelcomeState: Codable {
    let session_id: String?
}

struct ConversationRequest: Codable {
    let session_id: String?
    let title: String
}

struct ConversationResponse: Codable {
    let conversation_db_id: String
    let conversation_id: String
}

struct ChatAutoRequest: Codable {
    let input_type: String
    let text: String
    let user_id: String
    let conversation_id: String
    let country_code: String
    let currency_code: String
    let ocr_text: String?
    let stream: Bool?
}

struct ChatImageRequest: Codable {
    let input_type: String
    let user_id: String
    let conversation_id: String
    let country_code: String
    let currency_code: String
}

struct ClearPendingRequest: Codable {
    let session_id: String
}

struct ClearPendingResponse: Codable {
    let ok: Bool
    let cleared: Bool
    let session_id: String
}

struct ChatAutoResponse: Codable {
    let node                : String?
    let reply               : String?
    let text                : String?
    let conversation_id     : String?
    let state               : ChatAutoState?
    let suggested_replies   : [String]?
}

struct ChatAutoState: Codable {
    let session_id      : String?
    let intent          : String?
    let confidence      : Double?
    let subscriptions   : [String]?
    let missing_fields  : String?
    let country_code    : String?
    let currency_code   : String?
    let ocr_text        : String?
}
