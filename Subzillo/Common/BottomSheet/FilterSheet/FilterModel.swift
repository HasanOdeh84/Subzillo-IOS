//
//  FilterModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 18/11/25.
//
import Foundation

//List subscriptions with filter & sorting sortBy -> 1-amount desc,2-amount asc,3-nextPaymentDate desc,4-nextPaymentDate asc if includeFamilyMembers is true, then familyMembers array must be passed otherwise [] fetchAll -> true -> returns all subscriptions without pagination, false -> returns paginated response (default)
                                                                                                                                
struct FilterModel: Codable {
    var categoryId                      : String? = nil
    var categoryName                    : String? = nil
    var includeFamilySubscriptions      : Bool = true
    var includeExpiredSubscriptions     : Bool = true
    var costOrder                       : Int = 0
    var renewalDateOrder                : OrderType = .none
    var familyMemberIds                 : [String]? = nil
    var monthYear                       : String?
}
