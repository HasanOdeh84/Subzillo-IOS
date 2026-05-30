//
//  ImagePreviewSheet.swift
//  Subzillo
//
//  Created by Antigravity on 02/02/26.
//

import SwiftUI

struct ImagePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    var image       : UIImage
    var onConfirm   : () -> Void
    var onCancel    : () -> Void
    @EnvironmentObject var themeManaer: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Drag Indicator Area
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 40, height: 5)
                .padding(.vertical, 24)
            
            // MARK: - Title
            HStack {
                Spacer()
                Text("Preview")
                    .font(.geistSemiBold(24))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // MARK: - Image Preview
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
            }
            
            // MARK: - Action Buttons
            HStack(spacing: 32) {
                
                CustomBorderButton(
                    title       : "Cancel",
                    background  : Color.clear,
                    borderColor : themeManaer.textPrimaryLight14_white14,
                    action      : {
                        onCancel()
                        dismiss()
                    }
                )
                
                CustomButton(title          : "Ok",
                             background     : .dangerE43C5CFF5A7A,
                             shadow         : .dangerE43C5CFF5A7A.opacity(0.55),
                             textColor      : .white,
                             height         : 48,
                             isBgGradient   : true,
                             action         : {
                    onConfirm()
                    dismiss()
                })
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(.bottomBGFFFFFF120A1F)
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
}
