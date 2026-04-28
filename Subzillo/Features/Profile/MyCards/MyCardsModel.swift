//
//  MyCardsModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 26/12/25.
//

import Foundation

public struct EditCardRequest: Codable {
    let userId         : String
    let cardId         : String
    let cardNumber     : String
    let nickName       : String
    let cardHolderName : String
}

public struct DeleteCardRequest: Codable {
    let userId         : String
    let cardId         : String
}
