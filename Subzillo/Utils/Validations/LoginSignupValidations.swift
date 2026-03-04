//
//  SignUpValidations.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/09/25.
//

import Foundation

struct LoginSignupValidations {
    
    //MARK: - SignUp
    func validateSignup(input: RegisterRequest,isSocialLogin:Bool = false) -> String? {
        if input.fullName.trimmed.isEmpty{
            return "Please enter your full name".localized
        }
        if isSocialLogin{
            if input.email.trimmed.isEmpty{
                return "Please enter email address".localized
            }
        }
        if !input.email.trimmed.isEmpty && !Validations().isValidEmail(input.email.trimmed) {
            return "Enter a valid email address".localized
        }
        return nil
    }
    
    //MARK: - Verify OTP
    func validateVerifyOtp(otp: String) -> String? {
        if otp.isEmpty{
            return "Please enter the OTP".localized
        }else if otp.count != 6{
            return "Please enter a 6-digit code".localized
        }
        return nil
    }
    
    //MARK: - Login
    func validateLogin(input: checkLoginRequest) -> String? {
        if input.loginType == 1{
            if input.phoneNumber.isEmpty{
                print("number is here\(input.phoneNumber)")
                return "Phone number is required".localized
            }
        }else{
            if input.email.trimmed.isEmpty {
                return "Email is required".localized
            }else if !Validations().isValidEmail(input.email.trimmed){
                return "Enter valid email".localized
            }
        }
        return nil
    }
    
    //MARK: - Onboarding
    func validateOnboarding(input: UpdateOnboardingRequest) -> String? {
        if input.noofSubscriptions == 0 || input.averageMonthlySpend == 0{
            return "Please answer all questions".localized
        }
        return nil
    }
    
    //MARK: - Forgot Password
    func validateForgotPassword(username: String) -> String? {
        if username.trimmed.isEmpty{
            return "Please enter username".localized
        }
        if username.trimmed.count < 3 {
            return "Username must be at least 3 characters".localized
        }
        return nil // All validations passed
    }
    
    //MARK: - Reset Password
    func validateResetPassword(password: String, confirmPassword: String) -> String? {
        if password.trimmed.isEmpty{
            return "Please enter password".localized
        }
        if !Validations().isValidPassword(password.trimmed) {
            return "Please enter valid password".localized
        }
        if confirmPassword.trimmed.isEmpty{
            return "Please enter confirm password".localized
        }
        if password.trimmed != confirmPassword.trimmed {
            return "Password and confirm password should be same".localized
        }
        return nil // All validations passed
    }
}
