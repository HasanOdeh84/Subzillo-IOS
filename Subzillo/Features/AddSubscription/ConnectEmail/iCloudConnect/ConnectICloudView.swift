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
    @EnvironmentObject var themeManager : ThemeManager
    var isValid: Bool {
        let validDomains = ["@icloud.com", "@me.com", "@mac.com"]
        return validDomains.contains(where: { email.lowercased().hasSuffix($0) }) && !password.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                
                Color.clear
                    .frame(width: 20, height: 40)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Connect Your iCloud Account")
                        .font(.geistBold(16))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                }
                
                Spacer()
                
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ReusableTextField2(placeholder   : "Enter iCloud email",
                                       text          : $email,
                                       isEmail       : true,
                                       header        : "iCloud Email",
                                       isImage       : false,
                                       isiCloud      : true)
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
                            HStack(spacing: 12) {
                                ZStack {
                                    
                                    // Gradient Icon Box
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            themeManager.accentGradient
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(
                                            color: themeManager.accentTextColor
                                                .opacity(0.55),
                                            radius: 12,
                                            y: 0
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color("BGPrimary_ F7F7F9_0A0612").opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    Image("sparkles")
                                        .frame(width: 16, height: 16)
                                }
                                
                                Text("How to generate an App-Specific Password?")
                                    .font(.geistSemiBold(14))
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                    )
                                
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
                                            //.underline()
                                            .foregroundColor(themeManager.selectedAccent.lastColor)
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
                                    .font(.geistSemiBold(12))
                                    .foregroundColor(.dangerLightE43C5C)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .font(.geistRegular(12))
                            .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            //.background(Color(.systemGray6))
                           // .cornerRadius(10)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.accentGradient.opacity(0.133))
                    )
                    .overlay {
                        
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                themeManager.selectedAccent.senColor
                                    .opacity(0.3),
                                lineWidth: 1
                            )
                    }
                    .cornerRadius(20)
                    
                    // MARK: Disclaimer
                    Text("We do not store your Apple ID password. Your credentials are used only to securely connect your iCloud Mail to detect subscriptions from your emails.")
                        .font(.geistRegular(12))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                    
                    // MARK: Connect Button
                    
                    GradientBgButton(title: "Connect iCloud", isSolid: true, showChevron: false) {
                        connectICloud()
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
        .applyAppBackground()
        .onChange(of: connectEmailVM.isManualICloudSuccess) { success in
            if success {
                connectEmailVM.isManualICloudSuccess = false
                AppIntentRouter.shared.pop()
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
