//
//  ProfileViews.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 13/11/25.
//

import SwiftUI

struct ProfileHeaderView: View {
    
    //MARK: - Properties
    var title           : LocalizedStringKey
    var trailingTitle   : LocalizedStringKey? = nil
    var onBack          : (() -> Void)? = nil
    var onTrailingAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            CircleBackButton {
                onBack?()
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.geistBold(16))
                    .foregroundColor(
                        Color("TextPrimary_ 0E101A_F4F1FB")
                    )
            }
            Spacer()
            
            if let trailingTitle = trailingTitle {
                Button(action: {
                    onTrailingAction?()
                }) {
                    Text(trailingTitle)
                        .font(.appRegular(14))
                        .foregroundColor(.blueMain700)
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 32)
    }
}

struct ProfileHeader: View {
    
    //MARK: - Properties
    var title                           : LocalizedStringKey
    var onSettings                      : (() -> Void)? = nil
    var onNotificationAction            : (() -> Void)? = nil
    @EnvironmentObject var commonApiVM  : CommonAPIViewModel
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            Button(action: {
                onSettings?()
            }) {
                HStack {
                    if colorScheme == .dark
                    {
                        Image("settings")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 20,height: 20)
                    }
                    else{
                        Image("settings")
                            .frame(width: 20,height: 20)
                    }
                    
                }
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(themeManager.white_white4)
                )
                .overlay(
                    Circle()
                        .stroke(
                            themeManager.black_white.opacity(0.08),
                            lineWidth: 1
                        )
                )
            }
            
            Spacer()
            
            Text(title)
                .font(.geistBold(16))
                .foregroundColor(.textPrimary0E101AF4F1FB)
            
            Spacer()
            
            ZStack(alignment: .topTrailing) {
                Button(action: {
                    onNotificationAction?()
                }) {
                    HStack {
                        if colorScheme == .dark
                        {
                            Image("notification-03")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 18,height: 18)
                        }
                        else{
                            Image("notification-03")
                                .frame(width: 18,height: 18)
                        }
                    }
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(themeManager.white_white4)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                themeManager.black_white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
                }
                
                if let count = commonApiVM.unreadCountResponse?.unreadCount{
                    if count != 0{
                        let filterCount = ""//count >= 10 ? "9+" : "\(count)"
//                        Text(filterCount)
//                            .font(.geistBold(9))
//                            .foregroundColor(Color.white)
//                            .frame(width: 10, height: 10)
//                            .multilineTextAlignment(.center)
//                        //                        .padding(4)
//                            .background(Color.dangerLightE43C5C)
//                            .cornerRadius(4)
//                            .offset(x: 0, y: -5)
                        Text(filterCount)
                            .font(.appBold(11))
                            .foregroundColor(.white)
                            .frame(width: 5, height: 5)
                            .padding(3)
                            .background(themeManager.accentTextColor)
                            .clipShape(Circle())
                            .shadow(color: themeManager.accentShadowColor, radius: 5, x: 0, y: 0)
                            .offset(x: -7, y: 4)
                    }
                }
            }
        }
        .offset(x: 0, y: -5)
        .frame(height: 32)
        .onAppear{
            if Constants.FeatureConfig.isS4Enabled {
                //                if commonApiVM.unreadCountResponse == nil{
                //                    commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
                //                }
                commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
            }
        }
    }
}

//struct GradientBgBtn: View {
//
//    //MARK: - Properties
//    var title           : String = "Add Subscription by AI Agent"
//    var image           : String = "robotic"
//    var action          : () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 5) {
//                Image(image)
//                    .frame(width: 20, height: 20)
//                    .padding(.leading, 24)
//                Spacer()
//                Text(title)
//                    .font(.appSemiBold(18))
//                    .foregroundColor(.white)
//                Spacer()
//            }
//            .padding()
//            .frame(maxWidth: .infinity, alignment: .center)
//            .background(
//                LinearGradient(
//                    colors: [Color.linearGradient1, Color.linearGradient2],
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
//            )
//            .cornerRadius(8)
//        }
//    }
//}

struct GradientBgBtn: View {
    var title   : LocalizedStringKey = "Add Subscription by AI Agent"
    var image   : String = "robotic"
    var action  : () -> Void
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        Button(action: action) {
            ZStack {
                HStack {
                    //                    Image(image)
                    //                        .frame(width: 20, height: 20)
                    //                        .padding(.leading, 24)
                    HStack{
                        Text(title)
                            .font(.appSemiBold(18))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                        //                        Spacer()
                    }
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                themeManager.gradient(style: .horizontal)
            )
            .cornerRadius(8)
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}

struct AccountInfo: View {
    var title                   : LocalizedStringKey
    var subTitle                : String
    var action                  : () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.appRegular(14))
                        .foregroundColor(.neutral500)
                    
                    Text(subTitle)
                        .font(.appSemiBold(16))
                        .foregroundColor(.buttonsText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 0) {
                    Button(action: {
                        action()
                    }) {
                        Image("edit_blue")
                            .frame(width: 20, height: 20)
                    }
                }
                .frame(alignment: .leading)
                .frame(width: 40, height: 40)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.neutral300Border, lineWidth: 2)
                )
                
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .frame(height: 72)
        }
    }
}

struct ProfileItem: View {
    var title                           : LocalizedStringKey
    var subtitle                        : LocalizedStringKey? = nil
    var image                           : String
    var action                          : () -> Void
    var isDarkMode                      = false
    @State private var isEnabled        = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            
            HStack(spacing: 14) {
                
                // Icon
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            Color.calenderF1F2F7FFFFFF
                        )
                    
                    Image(image)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(
                            themeManager.selectedAccent.senColor
                        )
                }
                .frame(width: 32, height: 32)
                
                // Title
                Text(title)
                    .font(.geistMedium(14))
                    .foregroundStyle(
                        Color.textPrimary0E101AF4F1FB
                    )
                
                Spacer()
                
                // Subtitle
                if let subtitle = subtitle {
                    
                    Text(subtitle)
                        .font(.geistRegular(12))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.6)
                        )
                }
                
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
                        themeManager.textPrimaryLight8_white8,
                        lineWidth: 1
                    )
            }
        }
    }
}

#Preview{
    ProfileHeader(title: "Profile")
}
