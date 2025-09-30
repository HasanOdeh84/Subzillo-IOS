//
//  KeychainHelper.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/09/25.
//

import Security
import Foundation

struct KeychainHelper {
    static func save(_ value: String?, service: String? = AppInfo.bundleId, account: String) {
        if let data = value?.data(using: .utf8) {
            let query: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrService as String: service ?? AppInfo.bundleId,
                kSecAttrAccount as String: account,
                kSecClass as String: kSecClassGenericPassword
            ]
            SecItemDelete(query as CFDictionary) // remove old
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    static func read(service: String? = AppInfo.bundleId, account: String) -> String? {
        let query: [String: Any] = [
            kSecAttrService as String: service ?? AppInfo.bundleId,
            kSecAttrAccount as String: account,
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    static func delete(service: String? = AppInfo.bundleId, account: String) {
        let query: [String: Any] = [
            kSecAttrService as String: service ?? AppInfo.bundleId,
            kSecAttrAccount as String: account,
            kSecClass as String: kSecClassGenericPassword
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    func deleteAllKeychainItems() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("✅ All Keychain items deleted")
        } else {
            print("⚠️ Could not delete all Keychain items, status: \(status)")
        }
    }
}
