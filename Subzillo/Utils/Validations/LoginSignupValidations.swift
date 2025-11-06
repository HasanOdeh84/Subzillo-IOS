//
//  SignUpValidations.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/09/25.
//

import Foundation

struct LoginSignupValidations {
    
    //MARK: - SignUp
    func validateSignup(username: String, fullName:String, email: String, mobile: String, password: String, confirmPassword: String,termsPrivacy: Bool) -> String? {
        if username.trimmed.isEmpty{
            return "Please enter username"
        }
        if username.trimmed.count < 3 {
            return "Username must be at least 3 characters"
        }
        if fullName.trimmed.isEmpty{
            return "Please enter full name"
        }
        if email.trimmed.isEmpty{
            return "Please enter email"
        }
        if !Validations().isValidEmail(email.trimmed) {
            return "Please enter valid email"
        }
        if !mobile.trimmed.isEmpty && !Validations().isValidMobile(mobile.trimmed){
            return "Please enter valid mobile number"
        }
        if password.trimmed.isEmpty{
            return "Please enter password"
        }
        if !Validations().isValidPassword(password.trimmed) {
            return "Please enter valid password"
        }
        if confirmPassword.trimmed.isEmpty{
            return "Please enter confirm password"
        }
        if password.trimmed != confirmPassword.trimmed {
            return "Password and confirm password should be same"
        }
        if !termsPrivacy{
            return "Please accept terms and conditions"
        }
        return nil // All validations passed
    }
    
    //MARK: - Verify OTP
    func validateVerifyOtp(otp: String) -> String? {
        if otp.isEmpty || otp.count != 6{
            return "Please enter OTP"
        }
        return nil // All validations passed
    }
    
    //MARK: - Login
    func validateLogin(input: checkLoginRequest) -> String? {
        if input.loginType == 1{
            if input.phoneNumber.trimmed.isEmpty || !Validations().isValidMobile(input.phoneNumber.trimmed){
                return "Enter a valid phone number"
            }
        }else{
            if input.email.trimmed.isEmpty {
                return "Email is required"
            }else if !Validations().isValidEmail(input.email.trimmed){
                return "Enter valid email"
            }
        }
        return nil // All validations passed
    }
    
    //MARK: - Forgot Password
    func validateForgotPassword(username: String) -> String? {
        if username.trimmed.isEmpty{
            return "Please enter username"
        }
        if username.trimmed.count < 3 {
            return "Username must be at least 3 characters"
        }
        return nil // All validations passed
    }
    
    //MARK: - Reset Password
    func validateResetPassword(password: String, confirmPassword: String) -> String? {
        if password.trimmed.isEmpty{
            return "Please enter password"
        }
        if !Validations().isValidPassword(password.trimmed) {
            return "Please enter valid password"
        }
        if confirmPassword.trimmed.isEmpty{
            return "Please enter confirm password"
        }
        if password.trimmed != confirmPassword.trimmed {
            return "Password and confirm password should be same"
        }
        return nil // All validations passed
    }
}
