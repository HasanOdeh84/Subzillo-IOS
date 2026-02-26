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
    var titleFont                           : Font? = .appRegular(18)
    var imageSize                           : CGFloat = 100
    var isCancelButtonVisible               : Bool = false
    var isImageVisible                      : Bool = true
    var isBtn                               : Bool = true
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top,24)
            
            if !isCancelButtonVisible{
                if isImageVisible{
                    ZStack(alignment: .topTrailing) {
                        Image(imageName ?? "")
                            .frame(width: imageSize, height: imageSize)
                    }
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            if subTitle != ""
            {
                VStack(alignment: .center, spacing: isCancelButtonVisible ? 12 : 8) {
                    Text(LocalizedStringKey(title ?? ""))
                        .font(.appSemiBold(24))
                        .foregroundStyle(.neutralMain700)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(LocalizedStringKey(subTitle ?? ""))
                        .font(.appRegular(18))
                        .foregroundStyle(.underlineGray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            else{
                Text(LocalizedStringKey(title ?? ""))
                    .font(titleFont)
                    .foregroundStyle(.underlineGray)
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
                    GradientBorderButton(title: "Cancel", action:{
                        dismiss()
                    }, backgroundColor:.whiteBlack)
                    .padding(.horizontal)
                    CustomButton(title: buttonTitle ?? "", height:50, action: {
                        onDelegate?()
                        dismiss()
                    })
                    .padding(.horizontal)
                }
            }
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

//MARK: - InfoVoiceAlertSheet view
struct InfoVoiceAlertSheet: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    var title                               : String?
    var imageName                           : String?
    var buttonIcon                          : String?
    var buttonTitle                         : String?
    var titleFont                           : Font? = .appRegular(18)
    var imageSize                           : CGFloat = 100
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top,24)
            
            ZStack(alignment: .topTrailing) {
                Image(imageName ?? "")
                    .frame(width: imageSize, height: imageSize)
            }
            .frame(width: imageSize, height: imageSize, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Text(LocalizedStringKey(title ?? ""))
                .font(titleFont)
                .foregroundStyle(.underlineGray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            GradientBorderButton(title          : buttonTitle ?? "",
                                 isBtn          : true,
                                 buttonImage    : buttonIcon ?? "") {
                onDelegate?()
                dismiss()
            }
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
