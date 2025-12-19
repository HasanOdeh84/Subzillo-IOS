//
//  ManualEntryValidations.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 11/11/25.
//
import Foundation

struct ManualEntryValidations {
    static let shared = ManualEntryValidations()
    
    //MARK: - Add card
    func addCard(input: AddCardRequest) -> String? {
        if input.nickName.isEmpty{
            return "Card Nickname is required"
        }
        if !Validations().isValidNickName(input.nickName){
            return "Invalid characters not allowed"
        }
        if input.cardNumber.isEmpty {
            return "Card Number is required"
        }
        if input.cardNumber.count != 4{
            return "Enter a valid card number"
        }
        if input.cardHolderName.isEmpty{
            return "Name on Card is required"
        }
        if !Validations().isValidName(input.cardHolderName){
            return "Invalid name format"
        }
        return nil // All validations passed
    }
    
    //MARK: - Manual entry
    func manualEntry(input: AddSubscriptionRequest) -> String? {
        if input.serviceName.isEmpty{
            return "Please enter service name"
        }
        if input.category.isEmpty{
            return "Please select category"
        }
        if input.amount == nil {
            return "Amount is required"
        }
        if input.currency == "" {
            return "Currency selection required"
        }
        if input.subscriptionType.isEmpty {
            return "Please enter plan type"
        }
        if input.billingCycle.isEmpty{
            return "Please select a billing cycle"
        }
        if input.nextPaymentDate.isEmpty{
            return "Please select next charge date"
        }
        return nil // All validations passed
    }
    
    //MARK: - Manual entry
    func updateManualEntry(input: SubscriptionData) -> String? {
        if (input.serviceName ?? "" == "") {
            return "Please enter service name"
        }
        if (input.categoryId ?? "" == ""){
            return "Please select category"
        }
        if input.amount == nil{
            return "Amount is required"
        }
        if input.currency == "" {
            return "Currency selection required"
        }
        if (input.subscriptionType ?? "" == "") {
            return "Please select plan type"
        }
        if (input.billingCycle ?? "" == ""){
            return "Please select a billing cycle"
        }
        if (input.nextPaymentDate ?? "" == ""){
            return "Please select next charge date"
        }
        return nil // All validations passed
    }
}
