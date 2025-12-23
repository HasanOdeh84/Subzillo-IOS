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
    @StateObject private var commonApiVM    = CommonAPIViewModel()
    @EnvironmentObject var router           : AppIntentRouter
    @State var appVersion   = ""
    @State var buildNumber  = ""
    @State var fullName     = "Alaa Hassan"
    @State var email        = "allhassn@gmail.com"
    @State var mobile       = "+971 123-4567"
    @State var currency     = "USD"
    
    //MARK: - Body
    var body: some View {
        VStack{
            ProfileHeader(title: "My Profile", onSettings: {
                ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
            }, onNotificationAction: {
                ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
            })
            .padding(.top, 70)
            .padding(.horizontal, 20)
            ScrollView(showsIndicators: false){
                VStack(spacing: 24){
                    VStack(spacing: 8){
                        ZStack(alignment: .topTrailing) {
                            WebImage(url: URL(string: "https://stagingsubzillo.krify.com/api/providers/amazon-music.png"))
                                .resizable()
                                .indicator(.activity)
                                .transition(.fade(duration: 0.5))
                                .scaledToFit()
                                .frame(width: 96, height: 96)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 96/2)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .cornerRadius(96/2)
                                .shadow(color: Color.dropShadow, radius: 2, x: 0, y: 2)
                            
                            VStack(spacing: 0) {
                                Button(action: {
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
                        
                        Text("Alaa Hassan")
                            .font(.appRegular(24))
                            .foregroundStyle(Color.neutralMain700)
                        
                        Text("+971 258741369")
                            .font(.appRegular(18))
                            .foregroundStyle(Color.blueMain700)
                    }
                    
                    GradientBgBtn(title: "Upgrade today and save 30%", image: "percentage", action: {
                        ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                    })
                    
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
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        }
                        Divider()
                            .overlay(Color.border)
                        AccountInfo(title: "Email", subTitle: email) {
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        }
                        Divider()
                            .overlay(Color.border)
                        AccountInfo(title: "Mobile Number", subTitle: mobile) {
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        }
                        Divider()
                            .overlay(Color.border)
                        AccountInfo(title: "Currency", subTitle: currency) {
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    
                    VStack(spacing: 0) {
                        ProfileItem(title: "Subscription Plans", image: "award", action:{
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        })
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "My Cards", image: "card", action:{
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        })
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "Dark Mode", image: "darkMode", action:{
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        }, isDarkMode: true)
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "Integrations", image: "link", action:{
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        })
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "Family Members", image: "familyMembers", action:{
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        })
                        Divider()
                            .overlay(Color.border)
                        ProfileItem(title: "Invite friends", image: "user-add-02", action:{
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        })
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    
                    CustomBorderButton(title: "Logout") {
                        AlertManager.shared.showAlert(
                            title       : "Logout",
                            message     : "Are you sure you want to logout?",
                            cancelText  : "Cancel",
                            okAction    : {
                                loginVM.logout(input: LogoutRequest(userId: Constants.getUserId()))
                            }
                        )
                    }
                    
                    HStack(spacing: 4) {
                        Text("Version \(appVersion)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Text("Build \(buildNumber)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom,90)
                }
                .padding(20)
                .navigationBarBackButtonHidden(true)
                .background(MediaPickerHost().allowsHitTesting(false)) // host
                .onAppear{
                    appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                    buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
                }
            }
        }
        .background(.neutralBg100)
        .ignoresSafeArea()
    }
}

#Preview {
    ProfileView()
}
