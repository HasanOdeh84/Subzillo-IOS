//
//  CircleBackButton.swift
//  Subzillo
//
//  Created by Antigravity on 01/02/26.
//

import SwiftUI

struct CircleBackButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager : ThemeManager
    
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            if let action = action {
                action()
            } else {
                dismiss()
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary0E101AF4F1FB)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.cardBgLoginFFFFFFFFFFFF)
                )
                .overlay(
                    Circle()
                        .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
                )
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        VStack(spacing: 20) {
            CircleBackButton()
                .preferredColorScheme(.light)
            
            CircleBackButton()
                .preferredColorScheme(.dark)
        }
    }
}
