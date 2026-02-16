//
//  OtpVerificationView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 24/09/25.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct OtpVerifyView: View {
    
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
//    @State private var showNumberSheet      = false
    @State private var phoneNumber          : String = ""
    @State private var selectedCurrency     : Currency?
    @State var verifyData                   : LoginSignupVerifyData?
    @EnvironmentObject var sessionManager   : SessionManager
    @State var fromLogin                    : Bool
    @State var verifyText                   : String = "Verify Phone Number"
    @State var sendCodeText                 : String = "phone number"
    @State var changeNumberEmail            : String = "number"
    @State var buttonText                   : String = "Phone Number"
    @State var verifyMergeType              : Int = 1
    
    //MARK: - Body
    var body: some View {
        ZStack{
            Group {
                Color(.neutralBg100)
            }
            .ignoresSafeArea()
            
            ScrollView{
                VStack() {
                    Text("Welcome to")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .multilineTextAlignment(.center)
                    
                    Image("logo_svg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128,height: 88)
                        .padding(.vertical,24)
                    
                    VStack(spacing: 4) {
                        Text(verifyText)
                            .font(.appRegular(24))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                        Text("We send a code to your \(sendCodeText)")
                            .font(.appRegular(16))
                            .foregroundColor(Color.gray)
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
                    
                    underlineText(text: "Change \(changeNumberEmail)", image: "phone") {
                        let data = LoginSignupVerifyData(verifyType         : verifyData?.verifyType == 2 ? 1 : 2,
                                                         email              : SessionManager.shared.loginData?.email,
                                                         phoneNumber        : SessionManager.shared.loginData?.phoneNumber,
                                                         countryCode        : SessionManager.shared.loginData?.countryCode,
                                                         userId             : SessionManager.shared.loginData?.userId ?? "",
                                                         isNewUser          : SessionManager.shared.loginData?.isNewUser ?? false,
                                                         isSignupCompleted  : SessionManager.shared.loginData?.isSignupCompleted ?? false,
                                                         fullName           : SessionManager.shared.loginData?.fullName,
                                                         socialLogin        : verifyData?.socialLogin ?? false)
                        SessionManager.shared.saveLoginData(data)
                        dismiss()
                    }
                    .padding(.top,24)
                    .padding(.bottom,30)
                    
                    TermsAndPrivacyText(
                        onTapTerms: {
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
//                            otpVerifyVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: true))
                        },
                        onTapPrivacy: {
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
//                            otpVerifyVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: false))
                        }
                    )
                    
                    Spacer()
                }
                .padding(20)
                .onAppear {
                    startTimer()
                    focusedField = 0
                    if let data = SessionManager.shared.loginData {
                        verifyData = data
                        if fromLogin{
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
                        }else{
//                            if verifyData?.verifyType == 1{
//                                verifyText = "Verify Email Address"
//                                sendCodeText = "email"
//                                changeNumberEmail = "email"
//                                buttonText = "Email"
//                            }else{
//                                verifyText = "Verify Phone Number"
//                                sendCodeText = "phone number"
//                                changeNumberEmail = "number"
//                                buttonText = "Phone Number"
//                            }
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
                    }
                }
                .onChange(of: otpVerifyVM.resendOtpResponse) { newValue in
                    if newValue {
                        otpFields = Array(repeating: "", count: 6)
                        startTimer()                 // ⏱ restart timer
                        otpVerifyVM.resendOtpResponse = false // reset flag
                    }
                }
                .onChange(of: otpVerifyVM.otpVerified) { verified in
                    if verified {
                        if let data = SessionManager.shared.loginData {
                            verifyData = data
                        }
                        verifyText          = "Verify Phone Number"
                        sendCodeText        = "phone number"
                        changeNumberEmail   = "number"
                        buttonText          = "Phone Number"
                        otpFields = Array(repeating: "", count: 6)
                        startTimer()                 // ⏱ restart timer
                    }
                }
                .navigationBarBackButtonHidden(true)
//                .sheet(isPresented: $showNumberSheet) {
//                    BottomSheetView(header:"Change mobile number",selectedCurrency: $selectedCurrency, phoneNumber: $phoneNumber)
//                        .presentationDragIndicator(.hidden)
//                    //                        .presentationDetents([.medium])
//                        .presentationDetents([.height(320)])
//                }
            }
        }
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
            ToastManager.shared.showToast(message: errorMessage,style: ToastStyle.error)
        } else {
            let input = OtpVerifyRequest(
                verifyType          : verifyData?.verifyType ?? 0,
                email               : verifyData?.email ?? "",
                phoneNumber         : verifyData?.phoneNumber ?? "",
                countryCode         : verifyData?.countryCode ?? "",
                otp                 : Int(otp) ?? 0,
                userId              : verifyData?.userId ?? "",
                verifyMergeType     : verifyMergeType
            )
            otpVerifyVM.verifyOtp(input             : input,
                                  fromLogin         : fromLogin,
                                  fromSocialLogin   : verifyData?.socialLogin ?? false)
        }
    }
}

// MARK: - Custom OTP TextField
struct OTPTextField: View {
    @Binding var text: String
    @FocusState var focusedField: Int?
    @Binding var isPasting : Bool
    let index: Int
    var onBackspace: (_ index: Int) -> Void
    var onPaste: (String) -> Void
    
    var body: some View {
        UITextFieldWrapper(text: $text, onBackspace: {
            DispatchQueue.main.async {
                text = ""   // safe update
                onBackspace(index)
            }
        }, onPaste: onPaste,
                           onDone: {
            focusedField = nil // dismiss keyboard
        })
        //        .frame(width: 63, height: 62)
        .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.width * 0.12)
        .background(Color.whiteBlackBG)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral2200, lineWidth: 1)
        )
        .multilineTextAlignment(.center)
        .keyboardType(.numberPad)
        .textContentType(.oneTimeCode)
        .focused($focusedField, equals: index)
        .onChange(of: text) { newValue in
            guard !isPasting else { return } // skip auto-focus if we just pasted
            if newValue.count == 1 {
                if index < 5 {
                    focusedField = index + 1
                } else {
                    focusedField = nil
                }
            }
        }
    }
}

// MARK: - UIKit Wrapper for Backspace + Paste
struct UITextFieldWrapper: UIViewRepresentable {
    @Binding var text: String
    var onBackspace: () -> Void
    var onPaste: (String) -> Void
    var onDone: (() -> Void)? = nil  // new Done callback
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.delegate = context.coordinator
        textField.isSecureTextEntry = true
        
        // Add Done button toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: UITextFieldWrapper
        
        init(_ parent: UITextFieldWrapper) {
            self.parent = parent
        }
        
        @objc func doneTapped() {
            parent.onDone?()
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty { // backspace
                if parent.text.isEmpty {
                    parent.onBackspace()  // trigger moving to previous field
                } else {
                    parent.text = "" // clear current field
                    parent.onBackspace()
                }
                return false
            }
            
            let text = string.trimmed
            
            // paste case
            if text.count > 1 {
                parent.onPaste(text)
                return false
            }
            
            // accept single digit
            //            parent.text = String(string.prefix(1))
            DispatchQueue.main.async {
                self.parent.text = String(text.prefix(1))
            }
            return false
        }
    }
}

//#Preview {
//    OtpVerifyView()
//}
