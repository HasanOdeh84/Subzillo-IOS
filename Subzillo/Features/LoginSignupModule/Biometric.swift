//
//  Biometric.swift
//  Subzillo
//
//  Created by Ratna Kavya on 25/05/26.
//

import SwiftUI
import LocalAuthentication

enum SupportedBiometric {
    case faceID
    case touchID
    case none
}

struct Biometric: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedBiometric = 0
    @State private var context = LAContext()
    @State private var biometricType: LABiometryType = .none
    @State private var isSuccess = 0
    
    var body: some View {
        
        VStack(spacing: 0) {
            if isSuccess == 0 {
                ScrollView(showsIndicators: false){
                    // MARK: Top Action
                    
                    HStack {
                        
                        Spacer()
                        
                        Button("Not now") {
                            skipAction()
                        }
                        .font(.geistSemiBold(13))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.6)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    
                    Spacer(minLength: 20)
                    
                    
                    // MARK: Center Content
                    
                    VStack(spacing: 28) {
                        
                        biometricAnimationView
                        
                        titleView
                        
                        featuresView
                    }
                    .padding(.horizontal, 28)
                    
                    
                    Spacer(minLength: 20)
                    
                    
                    // MARK: Bottom Actions
                    
                    VStack(spacing: 10) {
                        
                        enableButton
                        
                        //biometricSelector
                        
                        Button("Skip for now") {
                            skipAction()
                        }
                        .font(.geistMedium(13))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.6)
                        )
                        .frame(height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
            else{
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green58D3B5,
                                    Color.blue4898DF
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 130, height: 130)
                        .shadow(
                            color: Color.green58D3B5
                                .opacity(0.50),
                            radius: 30,
                            x: 0,
                            y: 20
                        )
                    
                    Image("checkmark1")
                        .frame(width: 62, height: 62)
                }

                VStack(spacing: 8) {
                    
                    Text("\(selectedBiometric == 0 ? "Face ID" : "Touch ID") enabled")
                        .font(.geistBold(26))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                        )
                        .multilineTextAlignment(.center)
                    
                    Text("You're all set. Your subscriptions are locked behind biometrics.")
                        .font(.geistRegular(14))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.6)
                        )
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .frame(maxWidth: 300)
                .padding(.top, 60)
            }
        }
        .applyAppBackground()
        .onAppear {
            let biometric = supportedBiometric()

            if supportedBiometric() == .faceID {
                
                selectedBiometric = 0
                
            } else if biometric == .touchID {
                
                selectedBiometric = 1
                
            }
            setupBiometrics()
        }
    }
    
    func supportedBiometric() -> SupportedBiometric {
        
        let context = LAContext()
        var error: NSError?
        
        context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        
        switch context.biometryType {
            
        case .faceID:
            return .faceID
            
        case .touchID:
            return .touchID
            
        default:
            return .none
        }
    }
    
    func enableAction()
    {
        authenticate()
    }
    
    func skipAction()
    {
        AppIntentRouter.shared.navigate(to: .pushPermissions)
    }
}

private extension Biometric {
    
    func setupBiometrics() {
        
        context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: nil
        )
        
        biometricType = context.biometryType
    }
    
    func authenticate() {
        
        
        context = LAContext()
        context.localizedCancelTitle = ""//Enter OTP"
        
        var error: NSError?
        
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        ) else {
            
            print(error?.localizedDescription ?? "Can't evaluate policy")
            return
        }
        
        Task {
            
            do {
                
                try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: "Log in to your account"
                )
                
                await MainActor.run {
                    
                    let usersData = Constants.getUserDetails(for: "loginedUsersData")
                    let filteredUser = usersData.first {
                           $0["userId"] == Constants.getUserId()
                       }
                    
                    if filteredUser != nil
                    {
                        var usersBioData = Constants.getUserDetails(for: "BiometricUsers")
                        let userExists = usersBioData.contains {
                            $0["userId"] == Constants.getUserId()
                        }
                        
                        if userExists == false
                        {
                            usersBioData.append(filteredUser!)
                            Constants.saveDefaults(value:usersBioData, key: "BiometricUsers")
                        }
                    }
                    
                    
                    isSuccess = 1
                    biometricType = context.biometryType
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                        AppIntentRouter.shared.navigate(to: .pushPermissions)
                    }
                    
                }
                
            } catch {
                
                guard let authError = error as? LAError else {
                    print(error.localizedDescription)
                    return
                }
                
                switch authError.code {
                    
                case .userFallback:
                    
                    // User tapped "Enter OTP"
                    AppIntentRouter.shared.navigate(to: .pushPermissions)
                    
                case .userCancel:
                    
                    // User tapped "Enter OTP"
                    AppIntentRouter.shared.navigate(to: .pushPermissions)
                    
                case .biometryLockout:
                    
                    print("Biometry locked")
                    
                default:
                    
                    print(authError.localizedDescription)
                }
            }
        }
    }
    
}

// MARK: - Components

private extension Biometric {
    
    var biometricAnimationView: some View {
        
        ZStack {
            
            ForEach(0..<3, id: \.self) { index in
                
                Circle()
                    .stroke(
                        themeManager.selectedAccent.primaryColor
                            .opacity(0.13),
                        lineWidth: 1
                    )
                    .scaleEffect(1 + CGFloat(2) * 0.22)
                    .frame(width: 130, height: 130)
            }
            
            
            Circle()
                .fill(themeManager.accentGradient)
                .frame(width: 130, height: 130)
                .shadow(
                    color: themeManager.selectedAccent.senColor.opacity(0.55),
                    radius: 25,
                    y: 16
                )
                .overlay {
                    
                    Image(selectedBiometric == 0 ? "faceid" : "touchid")
                        .frame(width: 62, height: 62)
                }
        }
        .frame(width: 180, height: 180)
    }
    
    var titleView: some View {
        
        VStack(spacing: 8) {
            
            Text("Protect with \(selectedBiometric == 0 ? "Face ID" : "Touch ID")")
                .font(.geistBold(26))
                .foregroundStyle(
                    Color.textPrimary0E101AF4F1FB
                )
                .multilineTextAlignment(.center)
            
            Text("Quick, private access to your subs. No password typing every time you open the app.")
                .font(.geistRegular(14))
                .foregroundStyle(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.6)
                )
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: 300)
    }
    
    var featuresView: some View {
        
        VStack(spacing: 8) {
            
            FaceIDFeatureRow(
                title: "Instant unlock",
                subtitle: "Subs data hidden from shoulder-surfers"
            )
            
            FaceIDFeatureRow(
                title: "Confirm cancellations",
                subtitle: "Biometric check before canceling a sub"
            )
            
            FaceIDFeatureRow(
                title: "Fully private",
                subtitle: "Your biometrics never leave this device"
            )
        }
    }
    
    var enableButton: some View {
        
        GradientBgButton(
            title       : selectedBiometric == 0 ? "Enable Face ID" : "Enable Touch ID",
            isSolid     : true,
            showChevron : true
        ) {
            enableAction()
        }
    
    }
    
    var biometricSelector: some View {
        
        HStack(spacing: 6) {
            
            biometricTab(
                title: "Face ID",
                index: 0
            )
            
            biometricTab(
                title: "Touch ID",
                index: 1
            )
        }
        .padding(4)
        .background(themeManager.white_white4)
        .overlay {
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.08),
                    lineWidth: 1
                )
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
    
    func biometricTab(title: String,
                       index: Int) -> some View {
        
        Button {
            
            selectedBiometric = index
            
        } label: {
            
            Text(title)
                .font(.geistSemiBold(12))
                .foregroundStyle(
                    selectedBiometric == index ?
                    Color.textPrimary0E101AF4F1FB :
                    Color.textPrimary0E101AF4F1FB.opacity(0.6)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background {
                    
                    if selectedBiometric == index {
                        
                        RoundedRectangle(cornerRadius: 9)
                            .fill(
                                themeManager.black_white.opacity(0.05)
                            )
                    }
                }
        }
    }
}

// MARK: - Feature Row

struct FaceIDFeatureRow: View {
    
    let title: String
    let subtitle: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            
            RoundedRectangle(cornerRadius: 9)
                .fill(themeManager.accentGradient.opacity(0.133))
                .overlay {
                    
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(
                            themeManager.selectedAccent.primaryColor
                                .opacity(0.2),
                            lineWidth: 1
                        )
                }
                .frame(width: 28, height: 28)
                .overlay {
                    
                    Image("checkmark2")
                        .frame(width: 14, height: 14)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(title)
                    .font(.geistSemiBold(13))
                    .foregroundStyle(
                        Color.textPrimary0E101AF4F1FB
                    )
                
                Text(subtitle)
                    .font(.geistRegular(11))
                    .foregroundStyle(
                        Color.textPrimary0E101AF4F1FB
                            .opacity(0.6)
                    )
                    .lineSpacing(2)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(themeManager.white_white4)
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.08),
                    lineWidth: 1
                )
        }
        .shadow(
            color: Color.textPrimary0E101AF4F1FB
                .opacity(0.04),
            radius: 8,
            y: 3
        )
    }
}
