//
//  DBManager.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/12/25.
//

import CoreData

final class DBManager {

    static let shared = DBManager()
    private let stack = CoreDataStack.shared
    private let context = PersistenceController.shared.context

    private init() {}

    // MARK: - Subscriptions
    
    // MARK: - create
    func createSubscription(params: SubscriptionListData) {
        let subscription                    = SubscriptionEntity(context: context)
        subscription.id                     = params.id
        subscription.serviceName            = params.serviceName
        subscription.serviceLogo            = params.serviceLogo
        subscription.amount                 = params.amount ?? 0.0
        subscription.currency               = params.currency
        subscription.currencySymbol         = params.currencySymbol
        subscription.billingCycle           = params.billingCycle
        subscription.subscriptionType       = params.subscriptionType
        subscription.subscriptionFor        = params.subscriptionFor
        subscription.category               = params.category
        subscription.paymentMethod          = params.paymentMethod
        subscription.paymentMethodName      = params.paymentMethodName
        subscription.paymentMethodDataId    = params.paymentMethodDataId
        subscription.nextPaymentDate        = params.nextPaymentDate
        subscription.renewalReminder        = params.renewalReminder
        subscription.nickName               = params.nickName
        subscription.color                  = params.color
        subscription.cardName               = params.cardName
        subscription.notes                  = params.notes
        subscription.status                 = params.status
        subscription.isSelected             = params.isSelected ?? false
        subscription.cardNumber             = params.cardNumber
        subscription.categoryName           = params.categoryName
        subscription.paymentMethodDataName  = params.paymentMethodDataName
        subscription.viewStatus             = params.viewStatus ?? false
        subscription.renewBtnStatus         = params.renewBtnStatus ?? false
        stack.create(object: subscription)
    }
    
    // MARK: - update
    func updateSubscription(query:NSPredicate, params: SubscriptionListData) {
        let request: NSFetchRequest<SubscriptionEntity> = SubscriptionEntity.fetchRequest()
        request.predicate = query
        
        let results = stack.fetch(request)
        let object: SubscriptionEntity
        if let existing = results.first {
            print("Updating existing subscription")
            object = existing
        } else {
            print("Creating new subscription")
            object = SubscriptionEntity(context: context)
        }
        object.id                           = params.id
        object.serviceName                  = params.serviceName
        object.serviceLogo                  = params.serviceLogo
        object.amount                       = params.amount ?? 0.0
        object.currency                     = params.currency
        object.currencySymbol               = params.currencySymbol
        object.billingCycle                 = params.billingCycle
        object.subscriptionType             = params.subscriptionType
        object.subscriptionFor              = params.subscriptionFor
        object.category                     = params.category
        object.paymentMethod                = params.paymentMethod
        object.paymentMethodName            = params.paymentMethodName
        object.paymentMethodDataId          = params.paymentMethodDataId
        object.nextPaymentDate              = params.nextPaymentDate
        object.renewalReminder              = params.renewalReminder
        object.nickName                     = params.nickName
        object.color                        = params.color
        object.cardName                     = params.cardName
        object.notes                        = params.notes
        object.status                       = params.status
        object.isSelected                   = params.isSelected ?? false
        object.cardNumber                   = params.cardNumber
        object.categoryName                 = params.categoryName
        object.paymentMethodDataName        = params.paymentMethodDataName
        object.viewStatus                   = params.viewStatus ?? false
        object.renewBtnStatus               = params.renewBtnStatus ?? false
        stack.update(object: object)
    }
    
    // MARK: - get
    func getSubscriptions(query:NSPredicate) -> [SubscriptionListData] {
        let request: NSFetchRequest<SubscriptionEntity> = SubscriptionEntity.fetchRequest()
        request.predicate = query
        let entities = stack.fetch(request)
        return entities.map { entity in
            SubscriptionListData(
                id                          : entity.id,
                serviceName                 : entity.serviceName,
                serviceLogo                 : entity.serviceLogo,
                amount                      : entity.amount,
                currency                    : entity.currency,
                currencySymbol              : entity.currencySymbol,
                billingCycle                : entity.billingCycle,
                subscriptionType            : entity.subscriptionType,
                subscriptionFor             : entity.subscriptionFor,
                category                    : entity.category,
                paymentMethod               : entity.paymentMethod,
                paymentMethodName           : entity.paymentMethodName,
                paymentMethodDataId         : entity.paymentMethodDataId,
                nextPaymentDate             : entity.nextPaymentDate,
                renewalReminder             : entity.renewalReminder,
                nickName                    : entity.nickName,
                color                       : entity.color,
                cardName                    : entity.cardName,
                notes                       : entity.notes,
                status                      : entity.status,
                isSelected                  : entity.isSelected,
                cardNumber                  : entity.cardNumber,
                categoryName                : entity.categoryName,
                paymentMethodDataName       : entity.paymentMethodDataName,
                viewStatus                  : entity.viewStatus,
                renewBtnStatus              : entity.renewBtnStatus
            )
        }
    }
    
    // MARK: - delete
    func deleteSubscription(query:NSPredicate) {
        let request: NSFetchRequest<SubscriptionEntity> = SubscriptionEntity.fetchRequest()
        request.predicate = query
        stack.delete(request)
    }
    func deleteAllSubscriptions() {
        stack.deleteAll(of: SubscriptionEntity.self)
    }
}
