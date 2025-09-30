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
    @Binding var path                       : NavigationPath
    @State private var otpFields            : [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField    : Int?
    @State private var timer                = 30
    @State private var isTimerRunning       = true
    @State private var timerCancellable     : AnyCancellable?
    @FocusState private var pinFocusState   : FocusPin?
    @Environment(\.dismiss) private var dismiss   // To go back
    @State var email                        : String = ""
    @State var username                     : String = ""
    @State var from                         : ToVerify
    @State private var isPasting            = false
    
    //MARK: - Body
    var body: some View {
        HStack{
            Button(action: {
                dismiss()  // Go back
            }) {
                HStack {
                    Image("back")
                }
                .foregroundColor(.blue)
            }
            .padding(.top,10)
            .padding(.horizontal, 18)
            Spacer()
        }
        ScrollView{
            VStack(spacing: 20) {
                
                // Header
                VStack(alignment: .leading,spacing: 8) {
                    Text("Verify Your Email")
                        .font(.appBold(24))
                    
                    AttributedString1(email: email, from: from)
                    
                    Text("Please enter it below to continue")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                //             OTP Fields
                HStack(spacing: 12) {
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
                
                //                            HStack(spacing: 12) {
                //                                ForEach(0..<6, id: \.self) { index in
                //                                    OTPTextField(
                //                                        text: $otpFields[index],
                //                                        focusedField: _focusedField,
                //                                        index: index,
                //                                        onBackspace: { idx in
                //                                            // Move focus to previous field if not first
                //                                            if idx > 0 {
                //                                                focusedField = idx - 1
                //                                            }
                //                                        },
                //                                        onPaste: pasteOTP
                //                                    )
                //                                }
                //                            }
                
                VStack(alignment: .leading){
                    // Resend OTP
                    if isTimerRunning {
                        Text("Didn’t get the code? Resend in \(timer)s")
                            .foregroundColor(.gray)
                        //                            .padding(.leading)
                    } else {
                        HStack(){
                            Text("Didn’t get the code?")
                            Button("Resend Code") {
                                otpVerifyVM.resendOtp(input: ResendOtpRequest(userId: Constants.getUserId(), username: username))
                                timerFun()
                            }
                            .foregroundColor(ColorConstants.black)
                        }
                    }
                }
                
                HStack(){
                    Spacer()
                    CustomButton(title: "Verify & Continue", width: 185) {
                        let otp = otpFields.joined()
                        print("Entered OTP: \(otp)")
                        if let errorMessage = LoginSignupValidations().validateVerifyOtp(otp: otp) {
                            ToastManager.shared.showToast(message: errorMessage)
                        } else {
                            let input = OtpVerifyRequest(email      : email,
                                                         otp        : Int(otp) ?? 0,
                                                         userId     : Constants.getUserId(),
                                                         username   : username)
                            otpVerifyVM.verifyOtp(input : input,
                                                  path  : $path,
                                                  from  : from)
                        }
                    }
                    Spacer()
                }
                
                Spacer()
            }
            .onAppear {
                startTimer()
                focusedField = 0
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    
    func timerFun(){
        if otpVerifyVM.resendOtpResponse{
            startTimer()
        }
    }
    
    //MARK: - Methods
    //MARK: Timer Logic
    private func startTimer() {
        timer = 30
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
}

//MARK: - Attributed string view
struct AttributedString1: View{
    @State var email: String
    @State var from: ToVerify
    var body: some View {
        var desc = ""
        if from == .forgot{
            desc = "We’ve sent a 6-digit code to your registered email."
        }else{
            desc = "We’ve sent a 6-digit code to \(email) Edit"
        }
        var attributedString = AttributedString(desc)
        
        // Find the range of "Edit"
        if let range = attributedString.range(of: "Edit") {
            attributedString[range].foregroundColor = ColorConstants.black
            //                            attributedString[range].underlineStyle = .single
            attributedString[range].link = URL(string: "myapp://edit") // custom URL
        }
        
        return Text(attributedString)
            .onOpenURL { url in
                if url.scheme == "myapp", url.host == "edit" {
                    // Action: Show bottom sheet or navigate
                    //                                    showSheet = true
                }
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
        .frame(width: 45, height: 50)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .multilineTextAlignment(.center)
        .keyboardType(.numberPad)
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
