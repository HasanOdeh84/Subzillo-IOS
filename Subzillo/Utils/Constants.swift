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
    
    // MARK: - Feature Phases
    enum AppPhase {
        case s3
        case s4
        case s5
    }
    
    enum FeaturePhase {
        case all
        case remaining
    }
    
    struct FeatureConfig {
        static let currentPhase: AppPhase = .s5
        static let featurePhase: FeaturePhase = .all
        
        static var isS4Enabled: Bool {
            return currentPhase == .s4 || currentPhase == .s5
        }
        
        static var isS5Enabled: Bool {
            return currentPhase == .s5
        }
        
        //Performs an action if S4 is enabled, otherwise shows a "Coming soon" toast.
        static func performS4Action(action: @escaping () -> Void) {
            if isS4Enabled {
                action()
            } else {
                ToastManager.shared.showToast(message: "Coming soon in S4", style: .info)
            }
        }
        
        // Performs an action if S5 is enabled, otherwise shows a "Coming soon" toast.
        static func performS5Action(action: @escaping () -> Void) {
            if isS5Enabled {
                action()
            } else {
                ToastManager.shared.showToast(message: "Coming soon in S5", style: .info)
            }
        }
    }
    
    static let platform                             = 2
    static let deviceType                           = 2
    static let authKey                              = "authKey"
    static let refreshKey                           = "refreshKey"
    static let deviceToken                          = "deviceToken"
    static let isLoggedIn                           = "isLoggedIn"
    static let isFirstLoggedIn                      = "isFirstLoggedIn"
    static let userId                               = "userId"
    static let referrerId                           = "referrerId"
    static let providerBaseUrl                      = "providerBaseUrl"
    static let username                             = "username"
    static let subscribeApiFail                     = "subscribeApiFail"
    static let pendingSubscribePlan                 = "pendingSubscribePlan"
    static let latitude                             = "latitude"
    static let longitude                            = "longitude"
    static let loginData                            = "loginData"
    static let uuid                                 = UUID()
    static let userDefaults                         = UserDefaults.standard
    static let deviceName                           = UIDevice.current.name
    static let deviceModel                          = UIDevice.current.model
    static let systemName                           = UIDevice.current.systemName
    static let systemVersion                        = UIDevice.current.systemVersion
    static let googleMapApiKey                      = "AIzaSyAjueXZzKodaxXdG2mZYG21_Jaf_ikFicQ"
    static let googleToken                          = "AIzaSyC8QkcmKT-p9tpMnamwLZ3xY4RSTxcvaKk"
    static let googleClientId                       = "955282043815-5tm4dfjcs5uv5qkvne9uv6jkf64div4a.apps.googleusercontent.com"
    
    //    static let miscrosoftClientId                   = "b6d1a52b-8d3a-4c74-b75f-b8a63be5a684"//ajay's
    
    static let miscrosoftClientId                   = "d81f4f2f-5591-4cae-bcfb-bd219a7d4016"//soniya's
    
    //    static let webClientId                          = "955282043815-shgvrph5q1jiogm6es7lc143jad27vk0.apps.googleusercontent.com"
    
//        static let webClientId                          = "955282043815-uither25lbuv22smj2tdhje513ilg5je.apps.googleusercontent.com" //soniya for dev
    
    static let webClientId                          = "955282043815-2bdqjsqk1ailb6dbvron7td1os6hipg6.apps.googleusercontent.com" //new soniya for QA
    
//        static let webClientId                          = "955282043815-4rckggvbc5m8dtsrtdhecrjl25e0lbg6.apps.googleusercontent.com" //new soniya for staging
    
    //    static let appGroupID                           = "group.com.krify.Subzillo" //krify
    static let appGroupID                           = "group.com.subzillo.app" //client
//    static let chatbotUrl                           = "https://carmelia-terminatory-palely.ngrok-free.dev"
//    static let chatbotUrl                           = "http://10.1.10.77:5173/public-chat"
    static let chatbotUrl                           = "https://stage.subzillo.com/public-chat"
    static let domain                               = "https://api.subzillo.com"

    static let webhookUrl_dev = "https://devsubzillo.krify.com/api/appleSubscribeWebhook" //dev
    static let webhookUrl_QA = "https://qasubzillo.krify.com/api/appleSubscribeWebhook" //QA
    static let webhookUrl_staging = "https://stagingsubzillo.krify.com/api/appleSubscribeWebhook" //staging
    
    static let ulink_staging = "applinks:stagingsubzillo.shared.ly" //staging
    static let ulink_qa      = "applinks:qasubzillo.shared.ly" //qa
    
//    android:host="devsubzillo.shared.ly"
//    android:host="qasubzillo.shared.ly"
//    android:host="stagingsubzillo.shared.ly"

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
    
    //    static func confidenceInfo(isAssumed:Bool,confidence:Double) -> (String, Color) {
    //        if isAssumed {
    //            return ("Assumed", Color.warning)
    //        } else if confidence <= 0.0 {
    //            return ("------------", Color.empty)
    //        } else if confidence < 0.4 {
    //            return ("Low confidence", Color.error)
    //        } else if confidence < 0.7 {
    //            return ("Medium confidence", Color.info)
    //        } else if confidence < 1 {
    //            return ("High confidence", Color.high)
    //        } else {
    //            return ("Perfect match", Color.success)
    //        }
    //    }
    
    static func confidenceInfo(
        isAssumed: Bool,
        confidence: Double
    ) -> (String, Color, CGFloat) {
        let base = Color.confidenceBlue
        if isAssumed {
            return ("Assumed", base.opacity(0.4), 0.0)
        } else if confidence <= 0 {
            return ("------------", base.opacity(0.0), 0.0)
        } else if confidence < 0.4 {
            return ("Low confidence", base.opacity(0.2), 0.2)
        } else if confidence < 0.7 {
            return ("Medium confidence", base.opacity(0.6), 0.6)
        } else if confidence < 1 {
            return ("High confidence", base.opacity(0.8), 0.8)
        } else {
            return ("Perfect match", base.opacity(1.0), 1.0)
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
        let url = URL(string: "https://apps.apple.com/account/subscriptions")
        UIApplication.shared.open(url!, options: [:])
    }
    
    func getNextDateByFrequency(
        frequency   : String,
        baseDate    : Date = Date()
    ) -> String {
        
        let calendar = Calendar.current
        let nextDate: Date
        
        switch frequency {
        case "Daily":
            nextDate = calendar.date(byAdding: .day, value: 1, to: baseDate) ?? baseDate
            
        case "Weekly":
            nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: baseDate) ?? baseDate
            
        case "Monthly":
            nextDate = calendar.date(byAdding: .month, value: 1, to: baseDate) ?? baseDate
            
        case "Quarterly":
            nextDate = calendar.date(byAdding: .month, value: 3, to: baseDate) ?? baseDate
            
        case "Biannually":
            nextDate = calendar.date(byAdding: .month, value: 6, to: baseDate) ?? baseDate
            
        case "Yearly":
            nextDate = calendar.date(byAdding: .year, value: 1, to: baseDate) ?? baseDate
            
        default:
            nextDate = baseDate
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: nextDate)
    }
    
    func isSubscriptionExpired(nextPaymentDate: String) -> Bool {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let expiryDate = formatter.date(from: nextPaymentDate) else {
            return true
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let expiry = Calendar.current.startOfDay(for: expiryDate)
        
        return today > expiry
    }
    
    func formatDate(_ input: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: input) else {
            return input // fallback if parsing fails
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM dd, yyyy"

        return outputFormatter.string(from: date)
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
    static let refreshExtractedSubs = Notification.Name("refreshExtractedSubs")
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
        KeychainHelperApp().deleteAllKeychainItems()
    }
}
