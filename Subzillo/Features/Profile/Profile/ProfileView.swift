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
                VStack(spacing: 24){
                    VStack(spacing: 8){
                        ZStack(alignment: .topTrailing) {
                            if commonApiVM.userInfoResponse?.profileImage ?? "" != ""{
                                WebImage(url: URL(string: commonApiVM.userInfoResponse?.profileImage ?? ""))
                                //                            Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                //                                .indicator(.activity)
                                //                                .transition(.fade(duration: 0.5))
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .foregroundColor(.gray)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 96/2)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .cornerRadius(96/2)
                                    .shadow(color: Color.dropShadow, radius: 2, x: 0, y: 2)
                            }else{
                                Image("profile_avatar")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 96, height: 96)
//                                    .foregroundColor(.gray)
//                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 96/2)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .cornerRadius(96/2)
                                    .shadow(color: Color.dropShadow, radius: 2, x: 0, y: 2)
                            }
                            
                            VStack(spacing: 0) {
                                Button(action: {
                                    Constants.FeatureConfig.performS4Action {
                                        showUploadPopup = true
                                    }
                                }) {
                                    Image("camera_white")
                                        .frame(width: 16, height: 16)
                                }
                            }
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.blueMain700)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .shadow(color: Color.dropShadow, radius: 4, x: 0, y: 2)
                            .offset(x: 0, y: 64)
                        }
                        //                        ZStack(alignment: .bottomTrailing) {
                        //                            Image(systemName: "person.crop.circle.fill")
                        //                                .resizable()
                        //                                .scaledToFill()
                        //                                .frame(width: 150, height: 150)
                        //                                .foregroundColor(.gray)
                        //                                .background(Color.white)
                        //                                .clipShape(Circle())
                        //                                .overlay(
                        //                                    Circle()
                        //                                        .stroke(Color.white, lineWidth: 2)
                        //                                )
                        //                                .shadow(color: Color.dropShadow, radius: 10, x: 0, y: 5)
                        //
                        //                            Image(systemName: "camera.fill")
                        //                                .font(.system(size: 20))
                        //                                .foregroundColor(.white)
                        //                                .padding(12)
                        //                                .background(Color.blue)
                        //                                .clipShape(Circle())
                        //                                .overlay(
                        //                                    Circle()
                        //                                        .stroke(Color.white, lineWidth: 1)
                        //                                )
                        //                                .shadow(color: Color.dropShadow, radius: 4, x: 0, y: 2)
                        //                                .offset(x: -5, y: -5)
                        //                        }
                        
                        Text(fullName)
                            .font(.appRegular(24))
                            .foregroundStyle(Color.neutralMain700)
                            .multilineTextAlignment(.center)
                        
                        Text(mobile)
                            .font(.appRegular(18))
                            .foregroundStyle(Color.blueMain700)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Current Plan")
                            .font(.appSemiBold(14))
                            .foregroundStyle(Color.neutral600)
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            if commonApiVM.userInfoResponse?.planName ?? "" == "" {
                                Text("Free plan")
                                    .font(.appSemiBold(18))
                                    .foregroundStyle(Color.buttonsText)
                            }else{
                                Text(LocalizedStringKey(commonApiVM.userInfoResponse?.planName ?? "Free plan"))
                                    .font(.appSemiBold(18))
                                    .foregroundStyle(Color.buttonsText)
                            }
                            if let billingCycle = commonApiVM.userInfoResponse?.planBillingCycle {
                                if billingCycle != ""{
                                    Text(LocalizedStringKey("(\(billingCycle))"))
                                        .font(.appSemiBold(16))
                                        .foregroundColor(.buttonsText)
                                }
                            }
                        }
                        if let planExpiresAt = commonApiVM.userInfoResponse?.planExpiresAt {
                            if planExpiresAt != ""{
                                Text(LocalizedStringKey("Next renewal is \(planExpiresAt.toLocalizedStringDate().lowercased())"))
                                    .font(.appSemiBold(14))
                                    .foregroundColor(.neutral600)
                            }
                        }
                        
                        if commonApiVM.userInfoResponse?.upgradeBtnStatus ?? false{
                            GradientBgBtn(title: "Upgrade today", action: {
                                Constants.FeatureConfig.performS4Action {
                                    profileVM.navigate(to: .pricingPlans)
                                }
                            })
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    
                    VStack(spacing: 0) {
                        HStack{
                            Text("Account Information")
                                .font(.appRegular(16))
                                .foregroundStyle(Color.neutralMain700)
                                .padding(16)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        Divider()
                            .overlay(Color.border)
                        AccountInfo(title: "Full Name", subTitle: fullName) {
                            Constants.FeatureConfig.performS4Action {
                                selectedAccountType = .name
                            }
                        }
                        Divider()
                            .overlay(Color.border)
                        AccountInfo(title: "Email", subTitle: email) {
                            Constants.FeatureConfig.performS4Action {
                                selectedAccountType = .email
                            }
                        }
                        Divider()
                            .overlay(Color.border)
                        AccountInfo(title: "Mobile Number", subTitle: mobile) {
                            Constants.FeatureConfig.performS4Action {
                                selectedAccountType = .mobile
                            }
                        }
                        Divider()
                            .overlay(Color.border)
                        AccountInfo(title: "Currency", subTitle: currency) {
                            Constants.FeatureConfig.performS4Action {
                                selectedAccountType = .currency
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    
                    VStack(spacing: 0) {
                        ProfileItem(title: "Plans & Pricing", image: "award", action:{
                            Constants.FeatureConfig.performS4Action {
                                if Constants.FeatureConfig.featurePhase == .all{
                                    profileVM.navigate(to: .pricingPlans)
                                }else{
                                    ToastManager.shared.showToast(message: "Coming soon in S4", style: .info)
                                }
                            }
                        })
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "My Cards", image: "card", action:{
                            Constants.FeatureConfig.performS4Action {
                                profileVM.navigate(to: NavigationRoute.myCards)
                            }
                        })
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "Dark Mode", image: "darkMode", action:{
                            Constants.FeatureConfig.performS4Action {
                            }
                        }, isDarkMode: true)
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "Integrations", image: "link", action:{
                            Constants.FeatureConfig.performS4Action {
                                profileVM.navigate(to: NavigationRoute.connectedEmailsList(isIntegrations: true))
                            }
                        })
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "Family Members", image: "familyMembers", action:{
                            Constants.FeatureConfig.performS4Action {
                                profileVM.navigate(to: NavigationRoute.familyMembersView)
                            }
                        })
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "Invite friends", image: "user-add-02", action:{
                            Constants.FeatureConfig.performS4Action {
                                if Constants.FeatureConfig.featurePhase == .all{
                                    profileVM.navigate(to: .inviteFriends(uLink: commonApiVM.userInfoResponse?.referralLink))
                                }else{
                                    ToastManager.shared.showToast(message: "Coming soon in S4", style: .info)
                                }
                            }
                        })
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    
                    CustomBorderButton(title: "Logout") {
                        showDeletePopup = true
                    }
                    
                    HStack(spacing: 4) {
                        Text(LocalizedStringKey("Version \(appVersion)"))
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Text(LocalizedStringKey("Build \(buildNumber)"))
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom,90)
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
        .background(Color.neutralBg100.ignoresSafeArea())
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
            .presentationDetents([.height(350)])
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
                isCancelButtonVisible   : true
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

