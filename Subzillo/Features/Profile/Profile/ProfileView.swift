//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    
    //MARK: - Properties
    @StateObject var loginVM                = LoginViewModel()
    @StateObject var profileVM              = ProfileViewModel()
    @EnvironmentObject var picker           : MediaPickerManager
    @State private var selectedImage        : UIImage?
    @State private var selectedDocumentName : String?
    @EnvironmentObject var router           : AppIntentRouter
    @State var appVersion                   = ""
    @State var buildNumber                  = ""
    @State var fullName                     = ""
    @State var email                        = ""
    @State var mobile                       = ""
    @State var currency                     = ""
    @EnvironmentObject var commonApiVM      : CommonAPIViewModel
    @State var selectedAccountType          : AccountType?
    @State private var showVerifyOtpSheet   = false
    
    @State var emailVerify                  = ""
    @State var mobileVerify                 = ""
    @State var countryCodeVerify            = ""
    @State var accountTypeVerify            = 2
    
    @State var showUploadPopup              : Bool = false
    @State private var isUploading          = false
    @State var showDeletePopup              : Bool = false
    @State private var deleteSheetHeight    : CGFloat = .zero
    @State private var imageLoadFailed      = false
    @EnvironmentObject var themeManager     : ThemeManager
    
    private var initials: String {
        let words = fullName
            .split(separator: " ")
            .filter { !$0.isEmpty }
        
        if words.count == 1 {
            return String(words[0].prefix(1)).uppercased()
        } else {
            return words.prefix(2)
                .map { String($0.prefix(1)).uppercased() }
                .joined()
        }
    }
    
    //MARK: - Body
    var body: some View {
        VStack{
            ProfileHeader(title: "My Profile", onSettings: {
                Constants.FeatureConfig.performS4Action {
                    profileVM.navigate(to: .settings)
                }
            }, onNotificationAction: {
                Constants.FeatureConfig.performS4Action {
                    profileVM.navigate(to: .notifications)
                }
            })
            .padding(.top, 50)
            
            ScrollView(showsIndicators: false){
                VStack(spacing: 0){
                    VStack(spacing: 2){
                        ZStack {
                            // Glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            themeManager.selectedAccent.senColor.opacity(0.55),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 124, height: 124)
                                .blur(radius: 18)
                            
                            // Main Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        themeManager.accentGradient
                                    )
                                    .shadow(
                                        color: themeManager.selectedAccent.senColor.opacity(0.55),
                                        radius: 30,
                                        y: 10
                                    )
                                
                                Circle()
                                    .fill(themeManager.white_black.opacity(0.12))
                                    .blur(radius: 8)
                                    .padding(6)
                                
                                if commonApiVM.userInfoResponse?.profileImage ?? "" != ""{
                                    if imageLoadFailed {
                                        Text(initials)
                                            .font(.geistSemiBold(36))
                                            .tracking(-1)
                                            .foregroundStyle(.white)
                                    }else{
                                        WebImage(url: URL(string: commonApiVM.userInfoResponse?.profileImage ?? ""))
                                            .onFailure { _ in
                                                imageLoadFailed = true
                                            }
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                    }
                                }else{
                                    Text(initials)
                                        .font(.geistSemiBold(36))
                                        .tracking(-1)
                                        .foregroundStyle(.white)
                                }
                                
                            }
                            .frame(width: 100, height: 100)
                            
                        }
                        .frame(width: 124, height: 124)
                        
                        Text(fullName)
                            .font(.geistSemiBold(26))
                            .foregroundStyle(themeManager.black_white)
                            .multilineTextAlignment(.center)
                        
                        HStack{
                            Text(mobile == "" ? email : mobile)
                                .font(.geistRegular(12))
                                .foregroundStyle(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                                .multilineTextAlignment(.center)
                            
                            if commonApiVM.userInfoResponse?.createdAt ?? "" != ""{
                                Text(". \(commonApiVM.userInfoResponse?.createdAt?.formattedDate(from: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", to: "MMM yyyy") ?? "")")
                                    .font(.geistRegular(12))
                                    .foregroundStyle(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding(.vertical, 14)
                    
                    ZStack {
                        // Background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.white_white4)
                        
                        // Top Glow
                        Ellipse()
                            .fill(
                                themeManager.selectedAccent.primaryColor
                                    .opacity(0.2)
                            )
                            .blur(radius: 20)
                            .offset(y: -18)
                        
                        HStack(spacing: 10) {
                            // Text
                            VStack(alignment: .leading, spacing: 2) {
                                
                                HStack(spacing: 5) {
                                    Image("sparkles")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundStyle(themeManager.accentGradient)
                                        .frame(width: 16, height: 16)
                                    
                                    let planText = commonApiVM.userInfoResponse?.planName ?? "Free plan"
                                    let cycle = "\(commonApiVM.userInfoResponse?.planBillingCycle ?? "")"
                                    Text("\(planText) \(cycle == "" ? "" : "· \(cycle)")")
                                        .font(.jetBrainsBold(14))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    themeManager.selectedAccent.primaryColor,
                                                    themeManager.selectedAccent.lastColor
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                
                                if commonApiVM.userInfoResponse?.planExpiresAt ?? "" != ""{
                                    Text("Next renewal is \(commonApiVM.userInfoResponse?.planExpiresAt?.formattedDate(from: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", to: "MMM yyyy") ?? "")")
                                        .font(.geistSemiBold(10))
                                        .foregroundStyle(
                                            Color.textPrimary0E101AF4F1FB
                                                .opacity(0.8)
                                        )
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Button {
                                    Constants.FeatureConfig.performS4Action {
                                        if commonApiVM.userInfoResponse?.internalPlanType ?? 0 == 3{
                                            profileVM.navigate(to: .pricingPlans(selectedTab: .second))
                                        }else{
                                            profileVM.navigate(to: .pricingPlans())
                                        }
                                    }
                                } label: {
                                    Text("Manage")
                                        .font(.geistSemiBold(15))
                                }
                            }
                            .foregroundStyle(
                                themeManager.selectedAccent.senColor
                            )
                            .padding(.horizontal, 14)
                            .frame(width: 130, height: 32)
                            .background(
                                LinearGradient(
                                    colors: [
                                        themeManager.selectedAccent.primaryColor.opacity(0.2),
                                        themeManager.selectedAccent.lastColor.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        themeManager.selectedAccent.senColor
                                            .opacity(0.4),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(
                                Capsule()
                            )
                        }
                        .padding(.horizontal, 14)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame( height: 67)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                themeManager.textPrimaryLight8_white8,
                                lineWidth: 1
                            )
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("ACCOUNT")
                            .font(.jetBrainsMedium(10))
                            .tracking(1.4)
                            .textCase(.uppercase)
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                            .padding(.horizontal, 2)
                            .padding(.bottom, 10)
                        VStack(spacing: 6) {
                            ProfileItem(title: "Edit account info", image: "cardName", action:{
                                profileVM.navigate(to: NavigationRoute.editProfile)
                            })
                            
                            ProfileItem(title: "Family members", image: "cardName", action:{
                                Constants.FeatureConfig.performS4Action {
                                    profileVM.navigate(to: NavigationRoute.familyMembersView)
                                }
                            })
                            
                            ProfileItem(title: "My cards", image: "email_purple1", action:{
                                Constants.FeatureConfig.performS4Action {
                                    profileVM.navigate(to: NavigationRoute.myCards)
                                }
                            })
                            
                            ProfileItem(title: "Plans & pricing", image: "start", action:{
                                Constants.FeatureConfig.performS4Action {
                                    if Constants.FeatureConfig.featurePhase == .all{
                                        profileVM.navigate(to: .pricingPlans())
                                    }else{
                                        ToastManager.shared.showToast(message: "Coming soon in S4", style: .info)
                                    }
                                }
                            })
                            
                            ProfileItem(title: "Appearance", image: "appricon", action:{
                                Constants.FeatureConfig.performS4Action {
                                    profileVM.navigate(to: .appearance)
                                }
                            }, isDarkMode: false)
                            
//                            ProfileItem(title: "Integrations", image: "sparkles", action:{
//                                Constants.FeatureConfig.performS4Action {
//                                    profileVM.navigate(to: NavigationRoute.connectedEmailsList(isIntegrations: true))
//                                }
//                            })
                            
                            ProfileItem(title: "Invite friends", image: "notification-03", action:{
                                Constants.FeatureConfig.performS4Action {
                                    if Constants.FeatureConfig.featurePhase == .all{
                                        profileVM.navigate(to: .inviteFriends(uLink: commonApiVM.userInfoResponse?.referralLink))
                                    }else{
                                        ToastManager.shared.showToast(message: "Coming soon in S4", style: .info)
                                    }
                                }
                            })
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("Danger zone")
                            .font(.jetBrainsMedium(10))
                            .tracking(1.4)
                            .textCase(.uppercase)
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                            .padding(.horizontal, 2)
                            .padding(.bottom, 10)
                        
                        Button {
                            showDeletePopup = true
                        } label: {
                            HStack(spacing: 14) {
                                
                                // Icon
                                ZStack {
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            Color.dangerE43C5CFF5A7A.opacity(0.13)
                                        )
                                    
                                    Image("crossicon")
                                        .frame(width: 13, height: 13)
                                }
                                .frame(width: 32, height: 32)
                                
                                // Title
                                Text("Sign out")
                                    .font(.geistMedium(14))
                                    .foregroundStyle(
                                        Color.dangerE43C5CFF5A7A
                                    )
                                
                                Spacer()
                                
                                // Arrow
                                Image("backGrayright")
                                    .renderingMode(.template)
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.36)
                                    )
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(themeManager.white_white4)
                            )
                            .overlay {
                                
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.08),
                                        lineWidth: 1
                                    )
                            }
                        }
                        
                    }
                    .padding(.bottom,120)
                    .padding(.horizontal, 4)
                    
                    //                    HStack(spacing: 4) {
                    //                        Text(LocalizedStringKey("Version \(appVersion)"))
                    //                            .font(.footnote)
                    //                            .foregroundColor(.gray)
                    //
                    //                        Text(LocalizedStringKey("Build \(buildNumber)"))
                    //                            .font(.footnote)
                    //                            .foregroundColor(.gray)
                    //                    }
                    //
                }
                .navigationBarBackButtonHidden(true)
                .background(MediaPickerHost().allowsHitTesting(false)) // host
                .onAppear{
                    appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                    buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
                    getUserDetailsApi()
                }
                .onChange(of: commonApiVM.userInfoResponse) { _ in updateUserInfo() }
            }
        }
        .padding(20)
        .applyAppBackground()
        .sheet(item: $selectedAccountType) { type in
            EditAccountBottomSheet(onDelegate       : {
            },
                                   accountType      : type,
                                   name             : fullName,
                                   email            : email,
                                   mobile           : commonApiVM.userInfoResponse?.phoneNumber ?? "",
                                   currency         : currency,
                                   currencySymbol   : commonApiVM.userInfoResponse?.preferredCurrencySymbol ?? "",
                                   action           : { name, email, mobile, currency, type, countryCode, currencySymbol in
                let input = UpdateProfileRequest(userId         : Constants.getUserId(),
                                                 type           : type,
                                                 fullName       : name,
                                                 email          : email,
                                                 phoneNumber    : mobile,
                                                 countryCode    : countryCode,
                                                 currency       : currency,
                                                 currencySymbol : currencySymbol)
                emailVerify         = email
                mobileVerify        = mobile
                countryCodeVerify   = countryCode
                accountTypeVerify   = type
                profileVM.updateProfile(input: input)
            })
            //            .presentationDetents(selectedAccountType == .currency ? [.medium, .large] : [.height(350)])
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showVerifyOtpSheet) {
            VerifyOtpBottomSheet(verifyData: LoginSignupVerifyData(verifyType   : accountTypeVerify == 2 ? 2 : 1,
                                                                   email        : emailVerify,
                                                                   phoneNumber  : mobileVerify,
                                                                   countryCode  : countryCodeVerify),
                                 onDelegate:{
                getUserDetailsApi()
            })
            .presentationDetents([.medium, .large])
            //            .presentationDetents([.height(550)])
            .presentationDragIndicator(.hidden)
        }
        .onChange(of: profileVM.isUpdate) { value in
            if value{
                if self.accountTypeVerify == 2 || self.accountTypeVerify == 3{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showVerifyOtpSheet = true
                    }
                }
                getUserDetailsApi()
                profileVM.isUpdate = false
            }
        }
        .sheet(isPresented: $showUploadPopup, onDismiss: {
        }) {
            UploadImageSheet(isUploading: $isUploading, fromProfile: true, onDelegate: {
                getUserDetailsApi()
            })
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(315)])
            .interactiveDismissDisabled(isUploading)
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            showUploadPopup = false
        }
        .sheet(isPresented: $showDeletePopup) {
            InfoAlertSheet(
                onDelegate: {
                    loginVM.logout(input: LogoutRequest(userId: Constants.getUserId()))
                }, title                : "Logout",
                subTitle                : "Are you sure you want to logout?",
                imageName               : "del_red_big",
                buttonIcon              : "deleteIcon",
                buttonTitle             : "Ok",
                imageSize               : 70,
                isCancelButtonVisible   : true,
                isImageVisible          : false
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
    }
    
    //MARK: - User defined methods
    func updateUserInfo()
    {
        fullName   = commonApiVM.userInfoResponse?.fullName ?? ""
        email      = commonApiVM.userInfoResponse?.email ?? ""
        if commonApiVM.userInfoResponse?.phoneNumber ?? "" != ""{
            mobile     = "\(commonApiVM.userInfoResponse?.countryCode ?? "") \(commonApiVM.userInfoResponse?.phoneNumber ?? "")"
        }
        currency   = commonApiVM.userInfoResponse?.preferredCurrency ?? Constants.shared.regionCode
    }
    
    func getUserDetailsApi(){
        commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
    }
}

#Preview {
    ProfileView()
}

