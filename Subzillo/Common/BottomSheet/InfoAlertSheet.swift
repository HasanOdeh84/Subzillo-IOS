//
//  InfoAlertSheet.swift
//  Subzillo
//
//  Created by Ratna Kavya on 12/11/25.
//

import SwiftUI

struct InfoAlertSheet: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    var title                               : String?
    var subTitle                            : String?
    var imageName                           : String?
    var buttonIcon                          : String?
    var buttonTitle                         : String?
    var titleFont                           : Font? = .geistRegular(18)
    var imageSize                           : CGFloat = 100
    var isCancelButtonVisible               : Bool = false
    var isImageVisible                      : Bool = true
    var isBtn                               : Bool = true
    var isBgGradient                        : Bool = false
    @EnvironmentObject var themeManager     : ThemeManager
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Capsule()
                .fill(Color.capsuleBlack12White14)
                .frame(width: 40, height: 5)
                .padding(.top,24)
            
            if isImageVisible{
                ZStack(alignment: .topTrailing) {
                    Image(imageName ?? "")
                        .frame(width: imageSize, height: imageSize)
                }
                .frame(width: imageSize, height: imageSize, alignment: .center)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if subTitle != ""
            {
                VStack(alignment: .center, spacing: isCancelButtonVisible ? 12 : 8) {
                    Text(LocalizedStringKey(title ?? ""))
                        .font(.geistSemiBold(16))
                        .foregroundStyle(.textPrimary0E101AF4F1FB)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(LocalizedStringKey(subTitle ?? ""))
                        .font(.geistMedium(12))
                        .foregroundStyle(themeManager.textPrimaryLight6_dark62)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            else{
                Text(LocalizedStringKey(title ?? ""))
                    .font(.geistSemiBold(16))
                    .foregroundStyle(.textPrimary0E101AF4F1FB)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if !isCancelButtonVisible{
                GradientBorderButton(title          : buttonTitle ?? "",
                                     isBtn          : isBtn,
                                     buttonImage    : buttonIcon ?? "") {
                    onDelegate?()
                    dismiss()
                }
                                     .padding(.bottom, 24)
            }else{
                HStack(spacing: 0)  {
                    CustomBorderButton(
                        title       : "Cancel",
                        background  : Color.clear,
                        borderColor : themeManager.textPrimaryLight14_white14,
                        action      : {
                            dismiss()
                        }
                    )
                    .padding(.horizontal)
                    CustomButton(title          : buttonTitle ?? "",
                                 background     : .dangerE43C5CFF5A7A,
                                 shadow         : .dangerE43C5CFF5A7A.opacity(0.55),
                                 textColor      : .white,
                                 height         : 50,
                                 isBgGradient   : isBgGradient,
                                 action         : {
                        onDelegate?()
                        dismiss()
                    })
                    .padding(.horizontal)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .fixedSize(horizontal: false, vertical: true)
        .background(.bottomBGFFFFFF120A1F)
        .overlay {
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: InnerHeightPreferenceKey.self,
                        value: geo.size.height
                    )
            }
        }
    }
}

//MARK: - InfoVoiceAlertSheet view
struct InfoVoiceAlertSheet: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    var title                               : String?
    var imageName                           : String?
    var buttonIcon                          : String?
    var buttonTitle                         : String?
    var titleFont                           : Font? = .geistSemiBold(16)
    var imageSize                           : CGFloat = 100
    @EnvironmentObject var themeManager     : ThemeManager
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 40, height: 5)
                .padding(.top,24)
            
            ZStack(alignment: .topTrailing) {
                Image(imageName ?? "")
                    .frame(width: imageSize, height: imageSize)
            }
            .frame(width: imageSize, height: imageSize, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Text(LocalizedStringKey(title ?? ""))
                .font(titleFont)
                .foregroundStyle(.textPrimary0E101AF4F1FB)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            
            CustomBorderButton(
                title       : buttonTitle ?? "",
                background  : .auroraMid5598EA,
                borderColor : Color.clear,
                textColor   : Color.white,
                height      : 52,
                showIcon    : true,
                icon        : buttonIcon ?? "",
                iconOnLeft  : true,
                isBgGradient: true,
                action      : {
                    onDelegate?()
                    dismiss()
                }
            )
            
//            GradientBorderButton(title          : buttonTitle ?? "",
//                                 isBtn          : true,
//                                 buttonImage    : buttonIcon ?? "") {
//                onDelegate?()
//                dismiss()
//            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .fixedSize(horizontal: false, vertical: true)
        .overlay {
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: InnerHeightPreferenceKey.self,
                        value: geo.size.height
                    )
            }
        }
    }
}

struct SubscriptionAlertSheet: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    var title                               : String?
    var subTitle                            : String?
    var buttonIcon                          : String?
    var buttonTitle                         : String?
    var titleFont                           : Font? = .geistRegular(18)
    var isBtn                               : Bool = true
    @EnvironmentObject var themeManager     : ThemeManager
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top,24)
            
            VStack(alignment: .center, spacing: 8) {
                Text(LocalizedStringKey(title ?? ""))
                    .font(.geistSemiBold(16))
                    .foregroundStyle(.neutralMain700)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(LocalizedStringKey(subTitle ?? ""))
                    .font(.geistMedium(12))
                    .foregroundStyle(.underlineGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
//            CustomButton(title: buttonTitle ?? "",shadow: themeManager.accentShadowColor, height:50, action: {
//                onDelegate?()
//                dismiss()
//            })
            
            GradientBgButton(
                title       : buttonTitle ?? "",
                isSolid     : true,
                showChevron : false
            ) {
                onDelegate?()
                dismiss()
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .fixedSize(horizontal: false, vertical: true)
        .overlay {
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: InnerHeightPreferenceKey.self,
                        value: geo.size.height
                    )
            }
        }
    }
}
