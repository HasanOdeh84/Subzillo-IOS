//
//  SubscriptionsModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 06/11/25.
//

import Foundation

struct ListSubscriptionsRequest: Codable{
    let userId : String
    let page   : Int
    let filter : SubscriptionFilter
    let sortBy : Int
}

public struct SubscriptionFilter: Codable {
    var includeFamilyMembers        : Bool = true
    var includeExpiredSubscriptions : Bool = true
    var amountOrder                 : String = "asc"
    var nextPaymentDateOrder        : String = "asc"
    var categoryId                  : String?
    var familyMemberIds             : [String]?
    var month                       : Int?
    var year                        : Int?
}

public struct ListSubscriptionsResponse: Codable {
    let message : String?
    let data    : ListSubscriptionsResponseData?
}

public struct ListSubscriptionsResponseData: Codable, Hashable{
    let totalPages          : Int?
    let totalCount          : Int?
    let subscriptions       : [SubscriptionListData]?
}

struct GetSubscriptionsByMonthRequest: Codable{
    let userId  : String
    let year    : Int
    let month   : Int
}

struct MonthlySubscriptionsResponse: Codable {
    let message : String?
    let data    : MonthlySubscriptionsData?
}

struct MonthlySubscriptionsData: Codable, Hashable, Identifiable {
    var id                  : String?
    let month               : String?
    let currencySymbol      : String?
    let totalMonthlyAmount  : Double?
    let days                : [SubscriptionDay]?
}

struct SubscriptionDay: Codable, Identifiable, Hashable {
    var id              : String?
    let date            : String?
    let currencySymbol  : String?
    let status          : String?
    let totalAmount     : Double?
    let subscriptions   : [SubscriptionListData]?
    var isOpen          : Bool?
}

struct DeleteSubscriptionRequest: Codable{
    var userId          : String
    var subscriptionIds : [String]
}

struct SubscriptionInfoo: Identifiable {
    var id                      : String
    var amount                  : Double?
    var currency                : String?
    var createdAt               : String?
    var plans                   : [PlanInfo]?
    var relations               : [RelationsInfo]?
    var isOpen                  : Bool?
    var status                  : String?
}
struct PlanInfo: Codable {
    var id                      : String
    var name                    : String?
    var image                   : String?
    var amount                  : Double?
    var currency                : String?
    var card                    : String?
}
struct RelationsInfo: Codable {
    var id                      : String
    var name                    : String?
    var color                   : String?
    var plans                   : [PlanInfo]?
}

struct AnalyticsRequest: Codable{
    var userId        : String
    var monthYear     : String
    var year          : Int
    var familyMembers : [String]
}

struct AnalyticsResponse: Codable {
    let message     : String?
    let data        : AnalyticsData?
}

struct AnalyticsData: Codable, Hashable {
    let currency      : String?
    let currencySymbol: String?
    let pie           : PieData?
    let bar           : BarData?
}

struct PieData: Codable, Hashable {
    let month       : Int?
    let year        : Int?
    let monthYear   : String?
    let totals      : TotalsData?
    let totalAmount : Double?
    let currency      : String?
    let currencySymbol: String?
    let categories  : [AnalyticsCategoryData]?
}

struct TotalsData: Codable, Hashable {
    let totalSubscriptions      : Int?
    let activeSubscriptions     : Int?
    let inactiveSubscriptions   : Int?
}

struct AnalyticsCategoryData: Codable, Hashable, Identifiable {
    public var id       : String { categoryId ?? UUID().uuidString }
    let categoryId      : String?
    let categoryName    : String?
    let categoryColor   : String?
    let totalAmount     : Double?
    let count           : Int?
    
    enum CodingKeys: String, CodingKey {
        case categoryId, categoryName, categoryColor, totalAmount, count
    }
}

struct BarData: Codable, Hashable {
    let year   : Int?
    let months : [AnalyticsMonthData]?
}

struct AnalyticsMonthData: Codable, Hashable, Identifiable {
    public var id   : Int { month ?? 0 }
    let month       : Int?
    let totalAmount : Double?
    
    enum CodingKeys: String, CodingKey {
        case month, totalAmount
    }
}
