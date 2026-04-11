//
//  ConnectICloudView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/03/26.
//

import SwiftUI

struct ConnectICloudView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var email            : String = ""
    @State private var password         : String = ""
    @State private var showInstructions : Bool = true
    @StateObject var connectEmailVM     = ConnectEmailViewModel()
    
    var isValid: Bool {
        let validDomains = ["@icloud.com", "@me.com", "@mac.com"]
        return validDomains.contains(where: { email.lowercased().hasSuffix($0) }) && !password.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // MARK: - Header
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    // MARK: - back
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image("back_gray")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // MARK: - Title
                    Text("Connect Your iCloud Account")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                    Spacer()
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ReusableTextField2(placeholder   : "Enter iCloud email",
                                       text          : $email,
                                       isEmail       : true,
                                       header        : "iCloud Email",
                                       isImage       : false)
                    .padding(2)
                    iCloudReusableTextField(placeholder  : "Enter app-specific password",
                                            text          : $password,
                                            isEmail       : false,
                                            header        : "App-Specific Password")
                    .padding(2)
                    
                    // MARK: Instructions Section
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
//                            showInstructions.toggle()
                            print("showInstructions is \(showInstructions)")
                        }) {
                            HStack {
                                Text("How to generate an App-Specific Password?")
                                    .font(.appRegular(14))
                                    .foregroundColor(Color.neutralMain700)
                                
                                Spacer()
                            }
                        }
                        
                        if showInstructions {
                            VStack(alignment: .leading, spacing: 6) {
                                
                                VStack(alignment: .leading, spacing: 4) {
//                                    HStack(spacing: 0) {
//                                        Text("Step1. Go to ")
//                                        Link("appleid.apple.com", destination: URL(string: "https://appleid.apple.com")!)
//                                            .underline()
//                                    }
                                    HStack(spacing: 0) {
                                        Text("Step1. Go to ")
                                        Text("appleid.apple.com")
                                            .underline()
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                if let url = URL(string: "https://appleid.apple.com") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }
                                    }
                                    Text("Step2. Sign in with your Apple ID")
                                    Text("Step3. Navigate to Sign-In and Security → App-Specific Passwords")
                                    Text("Step4. Tap Generate Password")
                                    Text("Step5. Copy and paste it here")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Text("Note: Do NOT use your Apple ID password")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .font(.appRegular(14))
                            .foregroundColor(Color.neutralMain700)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                    
                    // MARK: Disclaimer
                    Text("We do not store your Apple ID password. Your credentials are used only to securely connect your iCloud Mail to detect subscriptions from your emails.")
                        .font(.appRegular(14))
                        .foregroundColor(.gray)
                    
                    // MARK: Connect Button
                    CustomButton(title: "Connect iCloud"){
                        connectICloud()
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)
        .background(Color.neutralBg100)
        .onChange(of: connectEmailVM.isManualICloudSuccess) { success in
            if success {
                connectEmailVM.isManualICloudSuccess = false
                dismiss()
            }
        }
    }
    
    // MARK: Action
    private func connectICloud() {
        if email.trimmed.isEmpty{
            ToastManager.shared.showToast(message: "Please enter email", style: .error)
        } else if !email.trimmed.isEmpty && !Validations().isValidICloudEmail(email.trimmed) {
            ToastManager.shared.showToast(message: "Please enter valid email", style: .error)
        } else if password.trimmed.isEmpty {
            ToastManager.shared.showToast(message: "Please enter app specific password", style: .error)
        } else if !isValidAppSpecificPassword(password.trimmed){
            ToastManager.shared.showToast(message: "Please enter valid app specific password", style: .error)
        }
        else{
            connectEmailVM.iCloudConnect(input: ICloudConnectRequest(userId         : Constants.getUserId(),
                                                                     email          : email.trimmed,
                                                                     appPassword    : password.trimmed))
        }
    }
    
    func isValidAppSpecificPassword(_ password: String) -> Bool {
        password.replacingOccurrences(of: "-", with: "").count == 16
    }
}

#Preview {
    ConnectICloudView()
}
