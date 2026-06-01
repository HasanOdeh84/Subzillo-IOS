//
//  GradientViews.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct GradientBorderView: View {
    var title           : LocalizedStringKey
    var subTitle        : LocalizedStringKey
    var buttonImage     : String?
    var nextBtnImage    : String = "arrow-right-01"
    var action          : () -> Void
    var titleColor      : Color
    var minHeight       = 82
    var titleFont       = 16
    var subTitleFont    = 12
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    Image(buttonImage ?? "")
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 18)
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(title)
                        .font(.appSemiBold(CGFloat(titleFont)))
                        .foregroundColor(titleColor)
                    
                    Text(subTitle)
                        .font(.appRegular(CGFloat(subTitleFont)))
                        .foregroundColor(Color.neutral500)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    Image(nextBtnImage)
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 18)
            }
            .frame(maxWidth: .infinity, minHeight: CGFloat(minHeight))
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            )
            .cornerRadius(8)
            .contentShape(RoundedRectangle(cornerRadius: 8)) // Ensures whole button is tappable
        }
    }
}


struct GradienCustomeView: View {
    var title           : String
    var subTitle        : String
    var imageName       : String = "howItWorks"
    var isImage         = true
    var isInviteFriends : Bool = false
    
    var body: some View {
        //Button(action: action) {
            HStack(alignment: .top, spacing: 0) {
                if isImage{
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Image(imageName)
                        }
                    }
                    .frame(width: 48, height: 48)
                    .background(Color.lightPurple)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.border, lineWidth: 0)
                    )
                    .cornerRadius(12)
                    .padding(.trailing, 16)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedStringKey(title))
                        .font(.appSemiBold(16))
                        .foregroundColor(.white)
                    if !isImage{
                        if isInviteFriends{
                            VStack(alignment: .leading, spacing: 5) {
                                instructionRow(number: "•", text: "Invite friends using your link")
                                instructionRow(number: "•", text: "You earn rewards only when they sign up and subscribe")
                                instructionRow(number: "•", text: "Each successful referral moves you closer to the next reward")
                            }
                        }else{
                            VStack(alignment: .leading, spacing: 5) {
                                instructionRow(number: "•", text: "We never store full email content")
                                instructionRow(number: "•", text: "We cannot send emails or access personal messages")
                            }
                        }
                    }else{
                        Text(subTitle)
                            .font(.appRegular(14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.linearGradient2, Color.linearGradient1],
                    startPoint: .leading,
                    endPoint: .topTrailing
                )
            )
            .cornerRadius(12)
        }
    
    func instructionRow(number: String, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 3) {
            Text(number)
                .font(.appRegular(18))
                .foregroundColor(.white)
            
            Text(text)
                .font(.appRegular(14))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

//MARK: - NormalOptionView
/*struct NormalOptionView: View {
    
    var title       : LocalizedStringKey
    var subTitle    : LocalizedStringKey
    var buttonImage : String
    var titleColor  : Color
    var action      : () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                
                Image(buttonImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.appSemiBold(16))
                        .foregroundColor(titleColor)
                    
                    Text(subTitle)
                        .font(.appRegular(14))
                        .foregroundColor(Color.neutral500)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(titleColor)
            }
            .padding(16)
//            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.black.opacity(0.08), lineWidth: 2)
                    .blur(radius: 4)
                    .offset(y: 2)
                    .mask(RoundedRectangle(cornerRadius: 8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(titleColor, lineWidth: 1)
            )
            .background(Color.whiteBlack)
            .cornerRadius(8)
        }
    }
}*/
struct NormalOptionView: View {
    
    var title                               : LocalizedStringKey
    var subTitle                            : LocalizedStringKey
    var buttonImage                         : String
    var titleColor                          : Color
    var isHighlighted                       : Bool = false
    var action                              : () -> Void
    @EnvironmentObject var themeManager     : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        Button(action: action) {
            
            HStack(spacing: 14) {
                
                // MARK: - Icon Container
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            isHighlighted ?
                            themeManager.accentGradient
                            :
                            LinearGradient(
                                colors: [
                                    themeManager.black_white.opacity(0.08),
                                    themeManager.black_white.opacity(0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    isHighlighted ?
                                    Color.clear :
                                    themeManager.black_white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                    
                    Image(buttonImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(
                            isHighlighted ? themeManager.white_white4 : themeManager.selectedAccent.senColor
                        )
                }
                .frame(width: 46, height: 46)
                .shadow(
                    color: isHighlighted ?
                    themeManager.selectedAccent.senColor.opacity(0.35) :
                    .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
                
                // MARK: - Text
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(title)
                        .font(.geistSemiBold(15))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    
                    Text(subTitle)
                        .font(.geistRegular(12))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // MARK: - Arrow
                
                if colorScheme == .dark
                {
                    Image("backGrayright1")
                        .frame(width: 16, height: 16)
                }
                else{
                    Image("rightArrow1")
                        .frame(width: 16, height: 16)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isHighlighted ?
                        LinearGradient(
                            colors: [
                                themeManager.selectedAccent.primaryColor.opacity(0.13),
                                themeManager.selectedAccent.lastColor.opacity(0.13)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        :
                        LinearGradient(
                            colors: [themeManager.white_white4],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isHighlighted ?
                        themeManager.selectedAccent.senColor.opacity(0.33) :
                        Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct DynamicBackgroundView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if colorScheme == .dark {
                ZStack {
                    Color.bgPrimaryDark0A0612
                        .ignoresSafeArea()
                    
                    ZStack {
                        Image(topImageName)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(themeManager.selectedAccent.primaryColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        
                        Image(bottomImageName)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(themeManager.selectedAccent.lastColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                    .ignoresSafeArea()
                }
            } else {
                Color.bgPrimaryLightF7F7F9
                    .ignoresSafeArea()
            }
        }
        .animation(.customScreenAnimation, value: themeManager.currentAccent)
        .animation(.customScreenAnimation, value: colorScheme)
    }
    
    private var topImageName: String {
        switch themeManager.currentAccent {
        case .violet:
            return "topCircle"
        case .sunset:
            return "topCircle"
        case .aurora:
            return "topCircle"
        }
    }
    
    private var bottomImageName: String {
        switch themeManager.currentAccent {
        case .violet:
            return "bottomCircle"
        case .sunset:
            return "bottomCircle"
        case .aurora:
            return "bottomCircle"
        }
    }
}
