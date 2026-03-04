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
            Button(action: {
                onBack?()
            }) {
                Image("back_gray")
                    .frame(width: 24,height: 24)
            }
            
            Text(title)
                .font(.appRegular(24))
                .foregroundColor(.neutralMain700)
            
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
    
    var body: some View {
        HStack {
            Button(action: {
                onSettings?()
            }) {
                Image("settings")
                    .frame(width: 24,height: 24)
            }
            
            Spacer()
            
            Text(title)
                .font(.appRegular(24))
                .foregroundColor(.neutralMain700)
            
            Spacer()
            
            ZStack(alignment: .topTrailing) {
                Button(action: {
                    onNotificationAction?()
                }) {
                    Image("notification-03")
                        .frame(width: 32, height: 32)
                }
                
                if let count = commonApiVM.unreadCountResponse?.unreadCount{
                    if count != 0{
                        var filterCount = count >= 10 ? "9+" : "\(count)"
                        Text(filterCount)
                            .font(.appBold(11))
                            .foregroundColor(Color.white)
                            .frame(width: 16, height: 15)
                            .multilineTextAlignment(.center)
                        //                        .padding(4)
                            .background(Color.redBadge)
                            .cornerRadius(4)
                            .offset(x: 0, y: -5)
                    }
                }
            }
        }
        .offset(x: 0, y: -5)
        .frame(height: 32)
        .onAppear{
//            if commonApiVM.unreadCountResponse == nil{
//                commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
//            }
//            commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
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
                LinearGradient(
                    colors: [Color.linearGradient2, Color.linearGradient1],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
        }
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
    var image                           : String
    var action                          : () -> Void
    var isDarkMode                      = false
    @State private var isEnabled        = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(spacing: 0) {
                    Image(image)
                        .frame(width: 48, height: 48)
                        .background(Color.neutralBg100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(alignment: .leading)
                .frame(width: 40, height: 40)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.neutral300Border, lineWidth: 2)
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.appRegular(16))
                        .foregroundColor(.neutralMain700)                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if isDarkMode{
                    Toggle("", isOn: Binding(
                        get: { themeManager.isDarkMode },
                        set: { newValue in
//                            themeManager.applyUserTheme(newValue)
                        }
                    ))
                }else{
                    Image("arrow-right-01-round")
                        .renderingMode(.template)
                        .foregroundColor(.secondaryNavyBlue400)
                        .frame(width: 24, height: 24)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .frame(height: 72)
        }
    }
}

#Preview{
    ProfileHeader(title: "Profile")
}
