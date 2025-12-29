//
//  ProfileValidations.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 29/12/25.
//

import Foundation

struct ProfileValidations {
    static let shared = ProfileValidations()
    
    //MARK: - Add card
    func addfamilyMember(input: AddFamilyMemberRequest) -> String? {
//        if input.nickName.isEmpty{
//            return "Card Nickname is required"
//        }
//        if !Validations().isValidNickName(input.nickName){
//            return "Invalid characters not allowed"
//        }
//        if input.phoneNumber.isEmpty{
//            return "Phone number is required"
//        }else if !Validations().isValidMobile(input.phoneNumber){
//            return "Mobile number must be between 6 to 15 digits"
//        }
//        if input.cardHolderName.isEmpty{
//            return "Name on Card is required"
//        }
//        if !Validations().isValidName(input.cardHolderName){
//            return "Invalid name format"
//        }
        return nil // All validations passed
    }
    
    //MARK: - Add card
    func editfamilyMember(input: EditFamilyMemberRequest) -> String? {
//        if input.nickName.isEmpty{
//            return "Card Nickname is required"
//        }
//        if !Validations().isValidNickName(input.nickName){
//            return "Invalid characters not allowed"
//        }
//        if input.phoneNumber.isEmpty{
//            return "Phone number is required"
//        }else if !Validations().isValidMobile(input.phoneNumber){
//            return "Mobile number must be between 6 to 15 digits"
//        }
//        if input.cardHolderName.isEmpty{
//            return "Name on Card is required"
//        }
//        if !Validations().isValidName(input.cardHolderName){
//            return "Invalid name format"
//        }
        return nil // All validations passed
    }
}
