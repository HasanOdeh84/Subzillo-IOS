//
//  ManualEntryModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/11/25.
//

import Foundation

struct ManualDataInfo: Identifiable, Hashable {
    var id                      : String
    var title                   : String?
    var subtitle                : String?
    var isSelected              : Bool?
    var value                   : String?
}

public struct AddSubscriptionRequest: Codable {
    let userId                  : String
    let serviceName             : String
    let amount                  : Double
    let currency                : String
    let billingCycle            : String
    let nextPaymentDate         : String
    let subscriptionType        : String
    let paymentMethod           : String
    let paymentMethodDataId     : String
    let category                : String
    let subscriptionFor         : String
    let renewalReminder         : [String]
    let notes                   : String
    let currencySymbol          : String
}

public struct EditSubscriptionRequest: Codable {
    let userId                  : String
    var subscriptionId          : String = ""
    let serviceName             : String
    let amount                  : Double
    let currency                : String
    let billingCycle            : String
    let nextPaymentDate         : String
    let subscriptionType        : String
    let paymentMethod           : String
    let paymentMethodDataId     : String
    let category                : String
    let subscriptionFor         : String
    let renewalReminder         : [String]
    let notes                   : String
    let currencySymbol          : String
}

public struct AddSubscriptionResponse: Codable {
    var message                 : String?
    var data                    : AddSubscriptionResponseData?
}

public struct AddSubscriptionResponseData: Codable {
    var duplicates              : [DuplicatesData]?
}

public struct DuplicatesData: Codable {
    var oldSubscription          : [SubscriptionInfo]?
    var newSubscription          : [SubscriptionInfo]?
}

public struct ListUserCardsRequest: Codable {
    var userId          : String
}

public struct ListUserCardsResponse: Codable {
    var message                 : String?
    var data                    : [ListUserCardsResponseData]?
}

public struct ListUserCardsResponseData: Codable, Hashable {
    var id                  : String? = nil
    var cardNumber          : String? = nil
    var nickName            : String? = nil
    var cardHolderName      : String? = nil
}

public struct ListFamilyMembersRequest: Codable {
    var userId          : String
}

public struct ListFamilyMembersResponse: Codable {
    var message                 : String?
    var data                    : [ListFamilyMembersResponseData]?
}

public struct ListFamilyMembersResponseData: Codable, Hashable {
    var id                  : String? = nil
    var nickName            : String? = nil
    var phoneNumber         : String? = nil
    var countryCode         : String? = nil
    var color               : String? = nil
    var subscriptions       : [SubscriptionListData]? = nil
}

public struct AddCardRequest: Codable {
    let userId                  : String
    let cardNumber              : String
    let nickName                : String
    let cardHolderName          : String
}

public struct AddFamilyMemberRequest: Codable, Hashable  {
    var userId              : String
    var nickName            : String
    var phoneNumber         : String
    var countryCode         : String
    var color               : String
}

public struct GetServiceProvidersListResponse: Codable {
    var message                 : String?
    var data                    : [GetServiceProvidersListData]?
}

public struct GetServiceProvidersListData: Codable, Hashable, Identifiable {
    public var id           : String? = nil
    var name                : String? = nil
    var logo                : String? = nil
}

public struct FetchProviderDataRequest: Codable {
    let userId               : String
    let serviceName          : String
    let currencyCode         : String
}

public struct FetchProviderDataResponse: Codable {
    var message                 : String?
    var data                    : FetchProviderData?
}

struct FetchProviderData: Codable, Hashable, Identifiable {
    var id                              : String? = nil
    var categoryId                      : String? = nil
    var categoryName                    : String? = nil
    var providerSubscriptionPlansList   : [ProviderSubscriptionPlan]? = []
}

struct ProviderSubscriptionPlan: Codable, Identifiable, Hashable {
    let id              = UUID()
    var planName        : String? = nil
    var price           : Double? = nil
    var billingCycle    : String? = nil
    var currencyCode    : String? = nil
    var currencySymbol  : String? = nil
    var source          : String? = nil
}
