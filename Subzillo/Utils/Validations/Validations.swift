//
//  Validations.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/09/25.
//

import Foundation

struct Validations{
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "\\d", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        return hasUppercase && hasNumber && hasSpecial
    }
    
    func isValidMobile(_ number: String) -> Bool {
        // Explanation:
        // ^(?!0+$)       → ensures the number is not all zeros
        // [0-9]{6,15}$   → only digits, length between 6 and 15
        let regex = "^(?!0+$)[0-9]{6,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: number)
    }
}
