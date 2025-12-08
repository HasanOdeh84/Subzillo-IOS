//
//  SubscriptionModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/12/25.
//

import CoreData

@objc(SubscriptionEntity)
public class SubscriptionEntity: NSManagedObject {}

extension SubscriptionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscriptionEntity> {
        return NSFetchRequest<SubscriptionEntity>(entityName: "SubscriptionEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var serviceName: String?
    @NSManaged public var serviceLogo: String?
    @NSManaged public var amount: Double
    @NSManaged public var currency: String?
    @NSManaged public var currencySymbol: String?
    @NSManaged public var billingCycle: String?
    @NSManaged public var subscriptionType: String?
    @NSManaged public var subscriptionFor: String?
    @NSManaged public var category: String?
    @NSManaged public var paymentMethod: String?
    @NSManaged public var paymentMethodName: String?
    @NSManaged public var paymentMethodDataId: String?
    @NSManaged public var nextPaymentDate: String?
    @NSManaged public var renewalReminder: [String]?
    @NSManaged public var nickName: String?
    @NSManaged public var color: String?
    @NSManaged public var cardName: String?
    @NSManaged public var notes: String?
    @NSManaged public var status: String?
    @NSManaged public var isSelected: Bool
    @NSManaged public var cardNumber: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var paymentMethodDataName: String?
}
