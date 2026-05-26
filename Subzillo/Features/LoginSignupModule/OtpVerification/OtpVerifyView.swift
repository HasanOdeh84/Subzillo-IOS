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
    @State private var shakeAttempts        : Int = 0
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
    @State var isEditProfile                : Bool = false
    @State var editEmail                    : String = ""
    @State var editPhone                    : String = ""
    @State var editCountryCode              : String = ""
    @State var editVerifyType               : Int = 1
    @EnvironmentObject var themeManager     : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    //MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                contentView
            }
        }
        .keyboardAdaptive()
        .applyAppBackground()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startTimer()
            focusedField = 0
            if let data = SessionManager.shared.loginData {
                verifyData = data
                updateVerifyText()
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
                if let data = SessionManager.shared.loginData {
                    verifyData = data
                }
                updateVerifyText()
                otpFields = Array(repeating: "", count: 6)
                startTimer()
            }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack {
            CircleBackButton {
                AppIntentRouter.shared.pop()
            }
            Spacer()
        }
        .padding(.leading, 40)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 24) {
                cardHeader
                    .padding(.top, 24)
                otpFieldsSection
                timerSection
                actionButtons
            }
            .background(cardBackground)
            .padding(.horizontal, 40) // Spacing from screen edges
            //            .padding(.bottom, 120)    // Padding for keyboard clearance
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var cardHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(themeManager.accentTextColor.opacity(0.133))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                themeManager.accentColor.opacity(0.267),
                                lineWidth: 1
                            )
                    )
                
                Image((isEditProfile ? editVerifyType : verifyData?.verifyType) == 2 ? "email_purple" : "phone_purple")
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .foregroundColor(themeManager.accentTextColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(verifyText)
                    .font(.geistBold(18))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                
                HStack(spacing: 4) {
                    Text("Code sent to")
                        .font(.geistRegular(12))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    Text((isEditProfile ? editVerifyType : verifyData?.verifyType) == 2 ? (isEditProfile ? editEmail : (verifyData?.email ?? "")) : getFormattedPhoneNumber())
                        .font(.geistSemiBold(12))
                        .foregroundColor(.textPrimary0E101AF4F1FB)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var otpFieldsSection: some View {
        HStack(spacing: 10) { // Slightly tighter spacing to fit margins
            ForEach(0..<6, id: \.self) { index in
                OTPTextField(text: $otpFields[index], focusedField: _focusedField, isPasting: self.$isPasting, index: index, onBackspace: { index in
                    if index > 0 {
                        focusedField = index - 1
                    }
                }, onPaste: pasteOTP)
            }
        }
        .padding(.horizontal, 20)
        .modifier(Shake(animatableData: CGFloat(shakeAttempts)))
    }
    
    @ViewBuilder
    private var timerSection: some View {
        if timer > 0 {
            HStack(spacing: 4) {
                Text("Resend in")
                    .font(.geistRegular(13))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                Text("00:\(String(format: "%02d", timer))")
                    .font(.geistBold(14))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
            }
        } else {
            Button {
                otpVerifyVM.resendOtp(input: ResendOtpRequest(userId: Constants.getUserId(), verifyType: isEditProfile ? editVerifyType : verifyData?.verifyType))
            } label: {
                Text("Resend code")
                    .font(.geistSemiBold(13))
                    .foregroundStyle(themeManager.accentGradient)
            }
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        let isOtpComplete = otpFields.joined().count == 6
        
        Button {
            if isOtpComplete {
                verifyOtp()
            } else {
                withAnimation(.default) {
                    shakeAttempts += 1
                }
            }
        } label: {
            HStack {
                Text("Verify")
                Image(systemName: "arrow.right")
            }
            .font(.geistBold(15))
            .foregroundColor(isOtpComplete ? .white : themeManager.textPrimaryLight6_dark62)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isOtpComplete ? AnyView(themeManager.accentGradient) :  colorScheme == .light ? AnyView(Color.black.opacity(0.07)) : AnyView(Color.white.opacity(0.08)))
            .cornerRadius(16)
            .shadow(color: isOtpComplete ? themeManager.accentShadowColor : .clear, radius: 12, x: 0, y: 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(colorScheme == .dark ? Color.grayBg0E0820.opacity(0.94) : Color.surfaceLightFFFFFF.opacity(0.97))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.textPrimary0E101AF4F1FB.opacity(0.14), lineWidth: 1)
            )
    }
    
    private func updateVerifyText() {
        let type = isEditProfile ? editVerifyType : verifyData?.verifyType
        if type == 1 {
            verifyText = "Verify your phone number"
            sendCodeText = "phone number"
        } else {
            verifyText = "Verify your email"
            sendCodeText = "email"
        }
    }
    
    private func getFormattedPhoneNumber() -> String {
        let code = isEditProfile ? editCountryCode : (verifyData?.countryCode ?? "")
        let number = isEditProfile ? editPhone : (verifyData?.phoneNumber ?? "")
        if code.isEmpty { return number }
        let cleanCode = code.hasPrefix("+") ? code : "+\(code)"
        return "\(cleanCode) \(number)"
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
                verifyType          : isEditProfile ? editVerifyType : (verifyData?.verifyType ?? 0),
                email               : isEditProfile ? editEmail : (verifyData?.email ?? ""),
                phoneNumber         : isEditProfile ? editPhone : (verifyData?.phoneNumber ?? ""),
                countryCode         : isEditProfile ? editCountryCode : (verifyData?.countryCode ?? ""),
                otp                 : Int(otp) ?? 0,
                userId              : isEditProfile ? Constants.getUserId() : (verifyData?.userId ?? ""),
                verifyMergeType     : verifyMergeType
            )
            otpVerifyVM.verifyOtp(input             : input,
                                  fromLogin         : fromLogin,
                                  fromSocialLogin   : verifyData?.socialLogin ?? false,
                                  isEdit            : isEditProfile)
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
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    
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
        .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.width * 0.14)
        .background(colorScheme == .dark ? Color.white.opacity(0.04) : Color.offWhiteF9F9FB)
        .cornerRadius(12)
        .overlay(
            ZStack {
                // Soft outer glow/border
//                if focusedField == index {
//                    RoundedRectangle(cornerRadius: 14)
//                        .stroke(
//                            themeManager.accentTextColor.opacity(0.25),
//                            lineWidth: 4
//                        )
//                        .padding(-2)
//                } //only one box highlight when it is focused
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        themeManager.accentTextColor.opacity(0.25),
                        lineWidth: 4
                    )
                    .padding(-2)
                
                // Main sharp border
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
//                        focusedField == index
//                        ? themeManager.accentTextColor
//                        : Color.textPrimary0E101AF4F1FB.opacity(0.12),
//                        lineWidth: focusedField == index ? 1.5 : 1 //only one box highlight when it is focused
                        themeManager.accentTextColor,
                        lineWidth: 1.5
                    )
            }
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
    
    func makeUIView(context: Context) -> BackspaceTextField {
        let textField = BackspaceTextField()
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.delegate = context.coordinator
        textField.isSecureTextEntry = true
        textField.onBackspace = onBackspace
        
        // Add Done button toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    func updateUIView(_ uiView: BackspaceTextField, context: Context) {
        uiView.text = text
        uiView.onBackspace = onBackspace
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
            if string.isEmpty { // backspace detected via delegate (non-empty case/standard)
                parent.text = "" // clear current field anyway
                parent.onBackspace() // move to previous
                return false
            }
            
            let text = string.trimmed
            
            // paste case
            if text.count > 1 {
                parent.onPaste(text)
                return false
            }
            
            // accept single digit
            DispatchQueue.main.async {
                self.parent.text = String(text.prefix(1))
            }
            return false
        }
    }
}

// MARK: - Backspace Aware TextField
class BackspaceTextField: UITextField {
    var onBackspace: (() -> Void)?
    
    override func deleteBackward() {
        // For empty fields, delegate is NOT called, so we trigger onBackspace here
        if text?.isEmpty ?? true {
            onBackspace?()
        }
        super.deleteBackward()
    }
}

// MARK: - Shake Animation Effect
struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
