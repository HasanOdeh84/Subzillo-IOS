//
//  SubscriptionDBManager.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/12/25.
//

import UIKit

final class SubscriptionDBManager {
    static let shared = SubscriptionDBManager()
    func createSubscription(params: SubscriptionListData) {
        DBManager.shared.createSubscription(params: params)
    }
    func updateSubscription(params: SubscriptionListData) {
        let predicate:NSPredicate = NSPredicate(format: "id == %@", params.id ?? "")
        DBManager.shared.updateSubscription(query: predicate, params: params)
    }
    func getSubscriptions(value: String, type:String) -> [SubscriptionListData] {
        var predicate = NSPredicate(format: "id != nil AND id != ''")
        if type == "list"
        {
            predicate = NSPredicate(format: "id != nil AND id != ''")
        }
        else if type == "byID"
        {
            predicate = NSPredicate(format: "(id == '\(value)')")
        }
        return DBManager.shared.getSubscriptions(query: predicate)
    }
    func deleteSubscription(id: String) {
        let predicate:NSPredicate = NSPredicate(format: "id == %@", id)
        DBManager.shared.deleteSubscription(query: predicate)
    }
    func deleteAllSubscription() {
        DBManager.shared.deleteAllSubscriptions()
    }
}
