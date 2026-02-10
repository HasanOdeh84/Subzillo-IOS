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
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Drag Indicator Area
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.vertical, 24)
            
            // MARK: - Title
            HStack {
                Text("Preview")
                    .font(.appSemiBold(24))
                    .foregroundColor(.neutralMain700)
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
                Spacer()
                
                Button(action: {
                    onCancel()
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.appMedium(18))
                        .foregroundColor(Color.blueMain700)
                }
                
                Button(action: {
                    onConfirm()
                    dismiss()
                }) {
                    Text("Ok")
                        .font(.appSemiBold(18))
                        .foregroundColor(.white)
                        .frame(width: 100, height: 48)
                        .background(Color.blueMain700)
                        .cornerRadius(24)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
}
