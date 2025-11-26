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
                
                if subTitle != ""
                {
                    VStack(alignment: .center, spacing: 8) {
                        Text(LocalizedStringKey(title ?? ""))
                            .font(.appSemiBold(24))
                            .foregroundStyle(.neutralMain700)
                            .multilineTextAlignment(.center)
                        
                        Text(LocalizedStringKey(subTitle ?? ""))
                            .font(.appRegular(18))
                            .foregroundStyle(.underlineGray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                else{
                    Text(LocalizedStringKey(title ?? ""))
                        .font(titleFont)
                        .foregroundStyle(.underlineGray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }
                   
                GradientBorderButton(title          : buttonTitle ?? "",
                                     isBtn          : true,
                                     buttonImage    : buttonIcon ?? "") {
                    onDelegate?()
                    dismiss()
                }
            Spacer()
         }
        .padding(.horizontal, 20)
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
            
            GradientBorderButton(title          : buttonTitle ?? "",
                                 isBtn          : true,
                                 buttonImage    : buttonIcon ?? "") {
                onDelegate?()
                dismiss()
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
