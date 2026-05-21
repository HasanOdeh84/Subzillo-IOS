//
//  LoginView.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import SwiftUI
import GoogleSignInSwift
import _AuthenticationServices_SwiftUI
import libPhoneNumber

struct LoginView: View {
    
    //MARK: - Properties
    @StateObject private var loginVM            = LoginViewModel()
    @State private var phoneNumber              : String = ""
    @State private var email                    : String = ""
    @State private var loginType                : loginType = .google
    @State private var isPasswordVisible        : Bool = false
    @EnvironmentObject var appDelegate          : AppDelegate
    @State private var selectedCurrency         : Currency?
    @State private var selectedCountry          : Country?
    @State var segmentSelected                  : Segment? = .first
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @State private var restoreAccSheetHeight    : CGFloat = .zero
    @State var createNewAcc                     = false
    @State var isLoginClicked                   = true
    @Environment(\.colorScheme) var systemScheme
    @EnvironmentObject var themeManager         : ThemeManager
    
    //MARK: - Body
    var body: some View {
        ScrollView {
            VStack{
                // Logo and Header
                VStack(alignment: .leading) {
                    // Logo with Glow
                    ZStack {
                        Circle()
                            .fill(themeManager.accentColor.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .blur(radius: 20)
                        
                        Image("logo_new")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 60)
                    }
                    .padding(.top, 70)
                    .padding(.leading, -20)
                    .padding(.bottom, -10)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome back")
                            .font(.geistBold(32))
                            .foregroundColor(.textPrimary0E101AF4F1FB)
                        
                        Text("Sign in to continue")
                            .font(.geistRegular(16))
                            .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                SegmentView(selectedSegment : $segmentSelected,
                            leftImage       : "phone_new",
                            rightImage      : "email_new",
                            leftText        : "Phone",
                            rightText       : "Email")
                .padding(.top, 30)
                .padding(.bottom, 16)
                
                VStack {
                    if segmentSelected == .first {
                        PhoneNumberField(phoneNumber        : $phoneNumber,
                                         header             : "",
                                         placeholder        : "00 000 0000",
                                         selectedCurrency   : $selectedCurrency,
                                         selectedCountry    : $selectedCountry,
                                         isCountry          : true)
                        .addDoneButton { }
                    } else {
                        ReusableTextField(placeholder   : "you@mail.com",
                                          text          : $email,
                                          isEmail       : true,
                                          header        : "")
                    }
                    
                    CustomButton(title: "Log in") {
                        isLoginClicked = true
                        loginApi()
                    }
                    .padding(.top, 12)
                }
                
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(themeManager.textPrimaryLight8_white8)
                        .frame(height: 1)
                    Text("or")
                        .font(.geistMedium(14))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    Rectangle()
                        .fill(themeManager.textPrimaryLight8_white8)
                        .frame(height: 1)
                }
                .padding(.top, 28)
                .padding(.bottom, 20)
                
                // Social logins - Horizontal Row
                HStack(spacing: 20) {
                    SocialSquareButton(image: "apple_withoutPadding") {
                        isLoginClicked = false
                        createNewAcc = false
                        loginType = .apple
                        loginVM.socialLogin(loginType: .apple, deviceId: appDelegate.deviceToken ?? "", createNewAcc: createNewAcc)
                    }
                    
                    SocialSquareButton(image: "google") {
                        isLoginClicked = false
                        createNewAcc = false
                        loginType = .google
                        loginVM.socialLogin(loginType: .google, deviceId: appDelegate.deviceToken ?? "", createNewAcc: createNewAcc)
                    }
                    
                    SocialSquareButton(image: "microsoft") {
                        isLoginClicked = false
                        createNewAcc = false
                        loginType = .microsoft
                        loginVM.socialLogin(loginType: .microsoft, deviceId: appDelegate.deviceToken ?? "", createNewAcc: createNewAcc)
                    }
                }
                
                TermsAndPrivacyText(
                    onTapTerms: {
                        Constants.FeatureConfig.performS4Action {
                            loginVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: true))
                        }
                    },
                    onTapPrivacy: {
                        Constants.FeatureConfig.performS4Action {
                            loginVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: false))
                        }
                    }
                )
                .padding(.top, 36)
                .padding(.bottom, 40)
                Spacer()
            }
            .padding(.horizontal, 28)
            .navigationBarBackButtonHidden(true)
            .onAppear{
                Constants.saveDefaults(value: false, key: "isSyncing")
                if let countries = commonApiVM.countriesResponse {
                    if let savedData = SessionManager.shared.loginData {
                        if let savedDialCode = savedData.countryCode,
                           let matched = countries.first(where: { $0.dialCode == savedDialCode }) {
                            selectedCountry = matched
                        } else {
                            selectedCountry = countries.first(where: { $0.countryCode == Constants.shared.regionCode })
                        }
//                        phoneNumber = savedData.phoneNumber ?? ""
                    } else if selectedCountry == nil {
                        selectedCountry = countries.first(where: { $0.countryCode == Constants.shared.regionCode })
                    }
                }
            }
            .onChange(of: segmentSelected) { value in
                createNewAcc = false
            }
            .sheet(isPresented: $loginVM.showRestoreAccSheet) {
                RenewSubscriptionBottomSheet(
                    title   : "Account Found",
                    desc    : "An account associated with this information was previously deleted. Would you like to restore your account or create a new one?",
                    btn1    : "Restore Account",
                    btn2    : "Create New Account",
                    btn3    : "Cancel",
                    onRenew : {
                        let phone = phoneNumber.normalizedPhoneNumber()
                        let ph = PhoneNumberFormatterService(regionCode: selectedCountry?.countryCode ?? "").formattedNumber(digits: phoneNumber)
                        loginVM.restoreUser(input           : RestoreUserRequest(userId    : Constants.getUserId(),
                                                                                 deviceId  : appDelegate.deviceToken ?? "",
                                                                                 loginType : isLoginClicked ? (segmentSelected == .first ? loginCheckType.mobile : loginCheckType.email).rawValue : loginCheckType.email.rawValue),
                                            fromLogin       : isLoginClicked,
                                            email           : email.trimmed,
                                            phoneNo         : phone,
                                            formattedPhNo   : ph,
                                            countryCode     : selectedCountry?.dialCode ?? "+\(NBPhoneNumberUtil.sharedInstance().getCountryCode(forRegion: Constants.shared.regionCode))")
                    },
                    onRenewWithChanges: {
                        createNewAcc = true
                        if isLoginClicked{
                            loginApi()
                        }else{
                            loginVM.socialLogin_createAcc(loginType     : loginType,
                                                          deviceId      : appDelegate.deviceToken ?? "",
                                                          createNewAcc  : createNewAcc)
                        }
                    },
                    onNo: {
                        loginVM.showRestoreAccSheet = false
                    }
                )
                .overlay {
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: InnerHeightPreferenceKey.self,
                                value: geo.size.height
                            )
                    }
                }
                .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                    if height > 150 {
                        restoreAccSheetHeight = height
                    }
                }
                .presentationDetents([.height(restoreAccSheetHeight)])
                .presentationDragIndicator(.hidden)
            }
        }
        .keyboardAdaptive()
        .dismissKeyboardOnBackgroundTap()
        .applyAppBackground()
        .ignoresSafeArea()
    }
    
    //MARK: - User defined methods
    func loginApi(){
        let phone = phoneNumber.normalizedPhoneNumber()
        let ph = PhoneNumberFormatterService(regionCode: selectedCountry?.countryCode ?? "").formattedNumber(digits: phoneNumber)
        print("phone no is \(phone) \(ph)")
        let input = checkLoginRequest(
            loginType       : (segmentSelected == .first ? loginCheckType.mobile : loginCheckType.email).rawValue,
            email           : email.trimmed,
            phoneNumber     : phone,
            countryCode     : selectedCountry?.dialCode ?? "+\(NBPhoneNumberUtil.sharedInstance().getCountryCode(forRegion: Constants.shared.regionCode))",
            deviceId        : appDelegate.deviceToken ?? ""
            ,
            referralCode    : Constants.getUserDefaultsValue(for: Constants.referrerId),
            createNewAcc    : createNewAcc
        )
        if let errorMessage = LoginSignupValidations().validateLogin(input: input) {
            ToastManager.shared.showToast(message: errorMessage.localized,style: ToastStyle.error)
        } else {
            loginVM.login(input: input, formattedPhNo: ph)
        }
    }
}

#Preview {
    LoginView()
}

//MARK: - Social login buttons
struct SocialSquareButton: View {
    var image: String
    var action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .frame(width: 60, height: 60)
//            .background(colorScheme == .dark ? Color.surfaceLightFFFFFF.opacity(0.2) : Color.surfaceLightFFFFFF)
            .background(Color.cardBgLoginFFFFFFFFFFFF)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.cardBorderE2E8F0E2E8F0, lineWidth: 1)
            )
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}

//MARK: - Apple signin button
struct AppleSignInButtonView: View {
    var action : () -> Void
    var body: some View {
        SignInWithAppleButton(.continue, onRequest: { request in
            action()
        }, onCompletion: { result in
            print("success")
            // handle result
        })
        .frame(height: 50)
        .signInWithAppleButtonStyle(.whiteOutline)
    }
}
