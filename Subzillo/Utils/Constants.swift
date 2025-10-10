//
//  Constants.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 02/09/25.
//

import SwiftUI

struct Constants{
    static let platform                             = 2
    static let deviceType                           = 2
    static let authKey                              = "authKey"
    static let refreshKey                           = "refreshKey"
    static let deviceToken                          = "deviceToken"
    static let isLoggedIn                           = "isLoggedIn"
    static let isFirstLoggedIn                      = "isFirstLoggedIn"
    static let userId                               = "userId"
    static let username                             = "username"
    static let latitude                             = "latitude"
    static let longitude                            = "longitude"
    static let loginData                            = "loginData"
    static let uuid                                 = UUID()
    static let deviceName                           = UIDevice.current.name
    static let deviceModel                          = UIDevice.current.model
    static let systemName                           = UIDevice.current.systemName
    static let systemVersion                        = UIDevice.current.systemVersion
    static let googleMapApiKey                      = "AIzaSyAjueXZzKodaxXdG2mZYG21_Jaf_ikFicQ"
    static let googleToken                          = "AIzaSyC8QkcmKT-p9tpMnamwLZ3xY4RSTxcvaKk"
    static let userDefaults                         = UserDefaults.standard
    
    static func saveDefaults(value: Any?, key: String) {
        if value != nil {
            UserDefaults.standard.set(value!, forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
    static func getUserDefaultsValue(for key: String) -> String {
        let value = UserDefaults.standard.string(forKey: key)
        if value == nil {
            return ""
        }
        return value!
    }
    
    static func getUserDefaultsIntValue(for key: String) -> Int {
        let value = UserDefaults.standard.integer(forKey: key)
        return value
    }
    
    static func getUserDefaultsBooleanValue(for key: String) -> Bool {
        let value = UserDefaults.standard.bool(forKey: key)
        return value
    }
    
    static func getLat() -> Double {
        if let savedData = UserDefaults.standard.string(forKey: Constants.latitude) {
            return Double(savedData) ?? 0.0
        }
        return 0.0
    }
    
    static func getLong() -> Double {
        if let savedData = UserDefaults.standard.string(forKey: Constants.longitude) {
            return Double(savedData) ?? 0.0
        }
        return 0.0
    }
    
    static func getUserId() -> String {
        let value = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
        return value
    }
    
    static func removeDefaults(key: String) {
        let defaults = UserDefaults.standard
        _ = defaults.dictionaryRepresentation()
        defaults.removeObject(forKey: key)
    }
}

//MARK: AppInfo
struct AppInfo {
    static var bundleId: String {
        Bundle.main.bundleIdentifier ?? "unknown"
    }
}

//MARK: Device Type
class DeviceType{
    static let shared = DeviceType()
    private init() {}
    func isIphone()->Bool{
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        }else{
            return true
        }
    }
    
    func isIpadLandscape()->Bool{
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height{
            return true
        }else{
            return false
        }
    }
}

//class LoginStatus {
//    static let shared = LoginStatus()
//    private init() {}
//
//    private let key = "loginstatus"
//
//    func loginUpdate(isLogin: Bool) {
//        UserDefaults.standard.setValue(isLogin, forKey: key)
//    }
//
//    func isLogin() -> Bool {
//        return UserDefaults.standard.bool(forKey: key)
//    }
//}

//class AppState: ObservableObject {
//    
//    static let shared = AppState()
//    private init() {}
//    @Published var isLoggedIn: Bool = LoginStatus.shared.isLogin()
//
//    func resetDefaults() {
//        let defaults = UserDefaults.standard
//        let dictionary = defaults.dictionaryRepresentation()
//        dictionary.keys.forEach { key in
//            if key == Constants.deviceToken || key ==  Bundle.main.bundleIdentifier ?? AppInfo.bundleId {
//            } else {
//                defaults.removeObject(forKey: key)
//            }
//        }
//        KeychainHelper().deleteAllKeychainItems()
//        isLoggedIn = false
//    }
//}

class AppState: ObservableObject {
    static let shared = AppState()
    init() {
        // Initialize from UserDefaults
        isLoggedIn = UserDefaults.standard.bool(forKey: key)
    }

    private let key = "loginstatus"
    
    @Published var isLoggedIn: Bool = false

    // MARK: - Login/Logout
    func login() {
        isLoggedIn = true
        UserDefaults.standard.setValue(true, forKey: key)
    }
    
    func logout() {
        isLoggedIn = false
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key == Constants.deviceToken || key ==  Bundle.main.bundleIdentifier ?? AppInfo.bundleId {
            } else {
                defaults.removeObject(forKey: key)
            }
        }
        KeychainHelper().deleteAllKeychainItems()
    }
}
