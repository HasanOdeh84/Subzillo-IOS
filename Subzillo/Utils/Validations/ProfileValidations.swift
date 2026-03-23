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
        if input.nickName.trimmed.isEmpty{
            return "Family nickname is required"
        }
//        if !Validations().isValidNickName(input.nickName){
//            return "Invalid characters not allowed"
//        }
        if input.nickName.trimmed.count <= 1{
            return "Family nickname must be at least 2 characters"
        }
        if input.nickName.trimmed.count > 20{
            return "Family nickname must be within 20 characters"
        }
        if input.phoneNumber.isEmpty{
            return "Phone number is required"
        }
        else if !Validations().isValidMobile(input.phoneNumber){
            return "Mobile number must be between 6 to 15 digits"
        }
        return nil // All validations passed
    }
    
    //MARK: - Add card
    func editfamilyMember(input: EditFamilyMemberRequest) -> String? {
        if input.nickName.trimmed.isEmpty{
            return "Family nickname is required"
        }
        if input.nickName.trimmed.count <= 1{
            return "Family nickname must be at least 2 characters"
        }
        if input.nickName.trimmed.count > 20{
            return "Family nickname must be within 20 characters"
        }
        if input.phoneNumber.isEmpty{
            return "Phone number is required"
        }
        else if !Validations().isValidMobile(input.phoneNumber){
            return "Mobile number must be between 6 to 15 digits"
        }
        return nil
    }
    
    //MARK: - Add card
    func editAccountDetails(input: UpdateProfileRequest) -> String? {
        if input.type == AccountType.name.rawValue{
            if input.fullName.trimmed.isEmpty{
                return "Please enter full name"
            }
            if input.fullName.trimmed.count > 25{
                return "Name must not exceed 25 characters"
            }
        }
        if input.type == AccountType.email.rawValue{
            if input.email.trimmed.isEmpty{
                return "Email is required"
            }
            if !input.email.trimmed.isEmpty && !Validations().isValidEmail(input.email.trimmed) {
                return "Please enter valid email"
            }
        }
        if input.type == AccountType.mobile.rawValue{
            if input.phoneNumber.trimmed.isEmpty{
                return "Phone number is required"
            }
        }
        return nil
    }
}
