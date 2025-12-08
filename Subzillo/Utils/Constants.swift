//
//  Constants.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 02/09/25.
//

import SwiftUI

struct Constants{
    static let shared = Constants()
    private init() {}
    
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
    static let googleSigninId                       = "955282043815-5tm4dfjcs5uv5qkvne9uv6jkf64div4a.apps.googleusercontent.com"
    static let userDefaults                         = UserDefaults.standard
    
    let regionCode      = Locale.current.region?.identifier ?? "US"
    let currencyCode    = Locale.current.currency?.identifier ?? "USD"
    let currencySymbol  = Locale.current.currencySymbol ?? "$"
    
    var pushMode:Int{
#if DEBUG
        print("Running in development environment")
        return 0
#else
        print("Running in production environment")
        return 1
#endif
    }
    
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
    
    static func confidenceInfo(isAssumed:Bool,confidence:Double) -> (String, Color) {
        if isAssumed {
            return ("Assumed", Color.warning)
        } else if confidence <= 0.0 {
            return ("------------", Color.empty)
        } else if confidence < 0.4 {
            return ("Low confidence", Color.error)
        } else if confidence < 0.7 {
            return ("Medium confidence", Color.info)
        } else if confidence < 1 {
            return ("High confidence", Color.high)
        } else {
            return ("Perfect match", Color.success)
        }
    }
    
    func dateConversion(_ apiDate: String) -> String {
        // 1. Convert "yyyy-MM-dd" string to Date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        
        guard let date = formatter.date(from: apiDate) else {
            return apiDate  // fallback if date parsing fails
        }
        
        let calendar = Calendar.current
        
        // 2. Check for today
        if calendar.isDateInToday(date) {
            return "Today"
        }
        
        // 3. Check for tomorrow
        if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        }
        
        // 4. Otherwise return dd/MM/yyyy
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        
        return outputFormatter.string(from: date)
    }
    
    func OpenSubscriptionsInAppStore(){
        
    }
}

//MARK: - Currency and country codes and flags
extension Constants{
    
    func flag(from countryCode: String) -> String {
        countryCode
            .uppercased()
            .unicodeScalars
            .map { 127397 + $0.value }
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    func getCurrencyCode(from input: String) -> String? {
        let key = input.lowercased().trimmingCharacters(in: .whitespaces)
        let currencyNameToCode: [String: String] = [
            
            // USD
            "dollar": "USD",
            "dollars": "USD",
            "us dollar": "USD",
            "american dollar": "USD",
            "usd": "USD",
            
            // EUR
            "euro": "EUR",
            "euros": "EUR",
            "eur": "EUR",
            
            // GBP
            "pound": "GBP",
            "pounds": "GBP",
            "british pound": "GBP",
            "gbp": "GBP",
            
            // CAD
            "canadian dollar": "CAD",
            "cad": "CAD",
            
            // AUD
            "australian dollar": "AUD",
            "aud": "AUD",
            
            // JPY
            "yen": "JPY",
            "japanese yen": "JPY",
            "jpy": "JPY",
            
            // CNY
            "yuan": "CNY",
            "chinese yuan": "CNY",
            "renminbi": "CNY",
            "cny": "CNY",
            
            // INR
            "rupee": "INR",
            "rupees": "INR",
            "india": "INR",
            "indian rupee": "INR",
            "inr": "INR",
            
            // BRL
            "real": "BRL",
            "reals": "BRL",
            "brazilian real": "BRL",
            "brl": "BRL",
            
            // MXN
            "peso": "MXN",
            "pesos": "MXN",
            "mexican peso": "MXN",
            "mxn": "MXN",
            
            // SGD
            "singapore dollar": "SGD",
            "sgd": "SGD",
            
            // CHF
            "swiss franc": "CHF",
            "franc": "CHF",
            "chf": "CHF",
            
            // NZD
            "new zealand dollar": "NZD",
            "nzd": "NZD",
            
            // SEK
            "swedish krona": "SEK",
            "krona": "SEK",
            "sek": "SEK",
            
            // NOK
            "norwegian krone": "NOK",
            "krone": "NOK",
            "nok": "NOK",
            
            // DKK
            "danish krone": "DKK",
            "dkk": "DKK",
            
            // HKD
            "hong kong dollar": "HKD",
            "hkd": "HKD",
            
            // KRW
            "won": "KRW",
            "korean won": "KRW",
            "krw": "KRW",
            
            // ZAR
            "rand": "ZAR",
            "south african rand": "ZAR",
            "zar": "ZAR",
            
            // AED
            "dirham": "AED",
            "uae dirham": "AED",
            "aed": "AED",
            
            // SAR
            "riyal": "SAR",
            "saudi riyal": "SAR",
            "sar": "SAR",
            
            // KWD
            "dinar": "KWD",
            "kuwaiti dinar": "KWD",
            "kwd": "KWD"
        ]
        return currencyNameToCode[key]
    }
    
    func detectCurrencyCode(from text: String) -> String? {
        let words = text.lowercased().split(separator: " ")
        
        for word in words {
            if let code = getCurrencyCode(from: String(word)) {
                return code
            }
        }
        return nil
    }
    
    func symbolForCurrencyCode(_ code: String) -> String {
        let locale = Locale.availableIdentifiers
            .map { Locale(identifier: $0) }
            .first { $0.currency?.identifier == code }
        
        return locale?.currencySymbol ?? ""
    }
    
    func getCurrencyDetails(from userInput: String) -> (code: String, symbol: String)? {
        guard let code = detectCurrencyCode(from: userInput) else {
            return nil
        }
        
        let symbol = symbolForCurrencyCode(code)
        return (code, symbol)
    }
}

extension Notification.Name {
    static let closeAllBottomSheets = Notification.Name("closeAllBottomSheets")
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

extension UIDevice {
    static var isFullScreeniPhone: Bool {
        let window = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first

        let topInset = window?.safeAreaInsets.top ?? 0
        return topInset > 20   // Full-screen iPhones have large notch inset
    }
}

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
