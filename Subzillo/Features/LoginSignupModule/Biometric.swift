//
//  Biometric.swift
//  Subzillo
//
//  Created by Ratna Kavya on 25/05/26.
//

import SwiftUI

struct Biometric: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedBiometric = 0
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            // MARK: Top Action
            
            HStack {
                
                Spacer()
                
                Button("Not now") {
                    
                }
                .font(.geistSemiBold(13))
                .foregroundStyle(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.6)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
            
            
            Spacer(minLength: 20)
            
            
            // MARK: Center Content
            
            VStack(spacing: 28) {
                
                biometricAnimationView
                
                titleView
                
                featuresView
            }
            .padding(.horizontal, 28)
            
            
            Spacer(minLength: 20)
            
            
            // MARK: Bottom Actions
            
            VStack(spacing: 10) {
                
                enableButton
                
                biometricSelector
                
                Button("Skip for now") {
                    
                }
                .font(.geistMedium(13))
                .foregroundStyle(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.6)
                )
                .frame(height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .applyAppBackground()
    }
}

// MARK: - Components

private extension Biometric {
    
    var biometricAnimationView: some View {
        
        ZStack {
            
            ForEach(0..<3, id: \.self) { index in
                
                Circle()
                    .stroke(
                        Color(hex: "#A719DD")
                            .opacity(0.13),
                        lineWidth: 1
                    )
                    .scaleEffect(1 + CGFloat(index) * 0.22)
                    .frame(width: 130, height: 130)
            }
            
            Circle()
                .fill(themeManager.accentGradient)
                .frame(width: 130, height: 130)
                .shadow(
                    color: Color(hex: "#7C5CFF").opacity(0.55),
                    radius: 25,
                    y: 16
                )
                .overlay {
                    
                    Image(systemName: "faceid")
                        .font(.system(size: 58, weight: .light))
                        .foregroundStyle(.white)
                }
        }
        .frame(width: 180, height: 180)
    }
    
    var titleView: some View {
        
        VStack(spacing: 8) {
            
            Text("Protect with Face ID")
                .font(.geistBold(26))
                .foregroundStyle(
                    Color.textPrimary0E101AF4F1FB
                )
                .multilineTextAlignment(.center)
            
            Text("Quick, private access to your subs. No password typing every time you open the app.")
                .font(.geistRegular(14))
                .foregroundStyle(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.6)
                )
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: 300)
    }
    
    var featuresView: some View {
        
        VStack(spacing: 8) {
            
            FaceIDFeatureRow(
                title: "Instant unlock",
                subtitle: "Subs data hidden from shoulder-surfers"
            )
            
            FaceIDFeatureRow(
                title: "Confirm cancellations",
                subtitle: "Biometric check before canceling a sub"
            )
            
            FaceIDFeatureRow(
                title: "Fully private",
                subtitle: "Your biometrics never leave this device"
            )
        }
    }
    
    var enableButton: some View {
        
        Button {
            
        } label: {
            
            HStack(spacing: 8) {
                
                Text("Enable Face ID")
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .font(.geistSemiBold(15))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(themeManager.accentGradient)
            .clipShape(Capsule())
            .shadow(
                color: Color(hex: "#7C5CFF").opacity(0.55),
                radius: 14,
                y: 6
            )
        }
    }
    
    var biometricSelector: some View {
        
        HStack(spacing: 6) {
            
            biometricTab(
                title: "Face ID",
                index: 0
            )
            
            biometricTab(
                title: "Touch ID",
                index: 1
            )
        }
        .padding(4)
        .background(.white)
        .overlay {
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.08),
                    lineWidth: 1
                )
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
    
    func biometricTab(title: String,
                       index: Int) -> some View {
        
        Button {
            
            selectedBiometric = index
            
        } label: {
            
            Text(title)
                .font(.geistSemiBold(12))
                .foregroundStyle(
                    selectedBiometric == index ?
                    Color.textPrimary0E101AF4F1FB :
                    Color.textPrimary0E101AF4F1FB.opacity(0.6)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background {
                    
                    if selectedBiometric == index {
                        
                        RoundedRectangle(cornerRadius: 9)
                            .fill(
                                Color.black.opacity(0.05)
                            )
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feature Row

struct FaceIDFeatureRow: View {
    
    let title: String
    let subtitle: String
    
    private let gradient = LinearGradient(
        colors: [
            Color(hex: "#A719DD").opacity(0.13),
            Color(hex: "#4489EB").opacity(0.13)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            
            RoundedRectangle(cornerRadius: 9)
                .fill(gradient)
                .overlay {
                    
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(
                            Color(hex: "#A719DD")
                                .opacity(0.2),
                            lineWidth: 1
                        )
                }
                .frame(width: 28, height: 28)
                .overlay {
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(
                            Color(hex: "#7C5CFF")
                        )
                }
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(title)
                    .font(.geistSemiBold(13))
                    .foregroundStyle(
                        Color.textPrimary0E101AF4F1FB
                    )
                
                Text(subtitle)
                    .font(.geistRegular(11))
                    .foregroundStyle(
                        Color.textPrimary0E101AF4F1FB
                            .opacity(0.6)
                    )
                    .lineSpacing(2)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.08),
                    lineWidth: 1
                )
        }
        .shadow(
            color: Color.textPrimary0E101AF4F1FB
                .opacity(0.04),
            radius: 8,
            y: 3
        )
    }
}
