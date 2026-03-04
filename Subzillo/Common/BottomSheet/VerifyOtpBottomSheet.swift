//
//  VerifyOtpBottomSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 06/01/26.
//

import SwiftUI
import Combine

struct VerifyOtpBottomSheet: View {
    
    //MARK: - Properties
    @StateObject private var otpVerifyVM    = OtpVerifyViewModel()
    @State private var otpFields            : [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField    : Int?
    @State private var timer                = 60
    @State private var isTimerRunning       = true
    @State private var timerCancellable     : AnyCancellable?
    @FocusState private var pinFocusState   : FocusPin?
    @Environment(\.dismiss) private var dismiss
    @State private var isPasting            = false
    @State private var phoneNumber          : String = ""
    @State private var selectedCurrency     : Currency?
    @State var verifyData                   : LoginSignupVerifyData?
    @EnvironmentObject var sessionManager   : SessionManager
    @State var verifyText                   : String = "Verify Phone Number"
    @State var sendCodeText                 : String = "phone number"
    @State var changeNumberEmail            : String = "number"
    @State var buttonText                   : String = "Phone Number"
    @State var verifyMergeType              : Int = 1
    var onDelegate                          : (() -> Void)?
    @StateObject private var toastManager   = ToastManager()
    
    //MARK: - Body
    var body: some View {
        //        ZStack{
        //            Group {
        //                Color(.neutralBg100)
        //            }
        //            .ignoresSafeArea()
        //
        //            //            ScrollView{
        //
        //            //            }
        //        }
        VStack{
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.vertical, 20)
            ScrollView{
                VStack() {
                    VStack(spacing: 4) {
                        Text(LocalizedStringKey(verifyText))
                            .font(.appRegular(24))
                            .foregroundColor(Color.grayClr)
                            .multilineTextAlignment(.center)
                        Text(LocalizedStringKey("We send a code to your \(sendCodeText)"))
                            .font(.appRegular(16))
                            .foregroundColor(Color.grayClr)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text("Enter validation code")
                        .font(.appRegular(14))
                        .foregroundColor(Color.neutralMain700)
                        .multilineTextAlignment(.center)
                        .padding(.top,24)
                        .padding(.bottom,4)
                    
                    //                    HStack(spacing: 16) {
                    HStack(spacing: UIScreen.main.bounds.width * 0.03) {
                        ForEach(0..<6, id: \.self) { index in
                            OTPTextField(text: $otpFields[index], focusedField: _focusedField, isPasting: self.$isPasting, index: index, onBackspace: {index in
                                if index > 0 {
                                    focusedField = index - 1
                                }
                            }, onPaste: pasteOTP)
                            .onAppear {
                                // optional: handle Done button dismissing keyboard
                                UITextFieldWrapper(text: $otpFields[index], onBackspace: {}, onPaste: {_ in }, onDone: {
                                    focusedField = nil
                                })
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    
                    HStack(){
                        Spacer()
                        CustomButton(title: "Verify \(buttonText)") {
                            focusedField = nil
                            verifyOtp()
                        }
                        Spacer()
                    }
                    .padding(.vertical,24)
                    
                    ZStack{
                        VStack{
                            Text("00:\(String(format: "%02d", timer))")
                                .font(.appRegular(28))
                                .foregroundColor(.blueMain700)
                        }
                        .frame(width: 166, height: 66)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neutral2200, lineWidth: 1)
                        )
                        VStack{
                            Text("Resend code in")
                                .font(.appRegular(14))
                                .foregroundColor(Color.neutral500)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal,8)
                                .padding(.vertical,3)
                                .background(.whiteNeutralCardBG)
                        }
                        .padding(.top,-44)
                    }
                    
                    Text("Didn't receive the code?")
                        .font(.appRegular(16))
                        .foregroundColor(Color.neutralMain700)
                        .multilineTextAlignment(.center)
                        .padding(.vertical,24)
                    
                    underlineText(text: "Resend Code", image: "resend") {
                        otpVerifyVM.resendOtp(input: ResendOtpRequest(userId        : Constants.getUserId(),
                                                                      verifyType    : verifyData?.verifyType))
                    }
                    .disabled(timer == 0 ? false : true)
                    .opacity(timer == 0 ? 1.0 : 0.6)
                    .padding(.bottom,15)
                }
                Spacer()
            }
        }
        .padding(20)
        .onAppear {
            startTimer()
            focusedField = 0
            if verifyData?.verifyType == 1{
                verifyText = "Verify Phone Number"
                sendCodeText = "phone number"
                changeNumberEmail = "number"
                buttonText = "Phone Number"
            }else{
                verifyText = "Verify Email Address"
                sendCodeText = "email"
                changeNumberEmail = "email"
                buttonText = "Email"
            }
        }
        .onChange(of: otpVerifyVM.resendOtpResponse) { newValue in
            if newValue {
                otpFields = Array(repeating: "", count: 6)
                startTimer()
                otpVerifyVM.resendOtpResponse = false
            }
        }
        .onChange(of: otpVerifyVM.otpVerified) { verified in
            if verified {
                onDelegate?()
                dismiss()
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(.neutralBg100)
        .ignoresSafeArea()
        .modifier(ToastModifier(toast: toastManager))
    }
    
    //MARK: - Methods
    //MARK: Timer Logic
    private func startTimer() {
        timer = 60
        isTimerRunning = true
        
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timer > 0 {
                    timer -= 1
                } else {
                    isTimerRunning = false
                    timerCancellable?.cancel()
                }
            }
    }
    
    private func pasteOTP(_ pasted: String) {
        // Remove spaces and take only digits
        isPasting = true
        let cleaned = pasted.filter { $0.isWholeNumber }
        guard !cleaned.isEmpty else { return }
        
        var chars = Array(cleaned.prefix(6))
        
        // Fill digits starting from first field
        for i in 0..<6 {
            if chars.isEmpty { break }
            otpFields[i] = String(chars.removeFirst())
        }
        
        // Move focus to last filled field (or nil if all filled)
        DispatchQueue.main.async {
            if let lastFilled = otpFields.lastIndex(where: { !$0.isEmpty }) {
                focusedField = lastFilled == 5 ? nil : lastFilled + 1
            } else {
                focusedField = 0
            }
            // Reset the flag after focus update
            isPasting = false
        }
    }
    
    func verifyOtp(){
        let otp = otpFields.joined()
        print("Entered OTP: \(otp)")
        if let errorMessage = LoginSignupValidations().validateVerifyOtp(otp: otp) {
            toastManager.showToast(message: errorMessage.localized, style: .error)
        } else {
            let input = OtpVerifyRequest(
                verifyType          : verifyData?.verifyType ?? 0,
                email               : verifyData?.email ?? "",
                phoneNumber         : verifyData?.phoneNumber ?? "",
                countryCode         : verifyData?.countryCode ?? "",
                otp                 : Int(otp) ?? 0,
                userId              : Constants.getUserId(),
                verifyMergeType     : verifyMergeType
            )
            otpVerifyVM.verifyOtpEdit(input: input, toastManager: toastManager)
        }
    }
}
