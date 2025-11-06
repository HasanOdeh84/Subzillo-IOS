//
//  SwiftUIView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 06/11/25.
//

import Foundation
import Combine

final class SessionManager: ObservableObject {
    @Published var loginData: LoginSignupVerifyData?

    private let key = "LoginSignupVerifyData"

    init() {
        // Restore from UserDefaults
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(LoginSignupVerifyData.self, from: data) {
            self.loginData = decoded
        }
    }

    func saveLoginData(_ data: LoginSignupVerifyData) {
        loginData = data
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func clearSession() {
        loginData = nil
        UserDefaults.standard.removeObject(forKey: key)
    }
}

