//
//  FamilyMembersModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 29/12/25.
//

import Foundation
public struct EditFamilyMemberRequest: Codable, Hashable  {
    var familyMemberId      : String
    var nickName            : String
    var phoneNumber         : String
    var countryCode         : String
    var color               : String
}

public struct DeleteFamilyMemberRequest: Codable {
    let familyMemberId         : String
}
