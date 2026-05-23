//
//  AppearanceView.swift
//  Subzillo
//
//  Created by Antigravity on 18/05/26.
//

import SwiftUI

struct AppearanceView: View {
    
    // MARK: - Properties
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack(spacing: 16) {
                // Circular Back Button
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                
                Text("Appearance")
                    .font(.geistBold(18))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                
                Spacer()
            }
            .padding(.top, 60)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // MARK: - THEME Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("THEME")
                            .font(.jetBrainsMedium(11))
                            .foregroundColor(themeManager.textPrimaryLight6_dark62)
                            .tracking(1.5)
                            .padding(.horizontal, 4)
                        
                        HStack(spacing: 12) {
                            ForEach(ThemeManager.AppearanceMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    themeManager.setAppearance(mode)
                                }) {
                                    ThemeCard(mode: mode, isSelected: themeManager.currentAppearance == mode)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    // MARK: - ACCENT Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("ACCENT")
                            .font(.jetBrainsMedium(11))
                            .foregroundColor(themeManager.textPrimaryLight6_dark62)
                            .tracking(1.5)
                            .padding(.horizontal, 4)
                        
                        HStack(spacing: 12) {
                            ForEach(ThemeManager.AppAccent.allCases, id: \.self) { accent in
                                Button(action: {
                                    themeManager.setAccent(accent)
                                }) {
                                    AccentCard(accent: accent, isSelected: themeManager.currentAccent == accent)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
        }
        .applyAppBackground()
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Theme Card View
struct ThemeCard: View {
    @EnvironmentObject var themeManager : ThemeManager
    let mode        : ThemeManager.AppearanceMode
    let isSelected  : Bool
    
    var body: some View {
        ScrollView{
            VStack(spacing: 0) {
                // Preview Graphic Container
                ZStack {
                    if mode == .light {
                        lightPreview
                    } else if mode == .dark {
                        darkPreview
                    } else {
                        autoPreview
                    }
                }
                .frame(height: 72)
                .frame(maxWidth: .infinity)
                .background(
                    mode == .light ? .offWhiteF5F3FC :
                        mode == .dark ? .grayBg0E0820 :
                        Color.clear
                )
                
                // Label
                Text(mode.rawValue)
                    .font(.geistSemiBold(12))
                    .foregroundColor(
                        isSelected ? themeManager.accentThemeColor : themeManager.textPrimaryLight6_dark62
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(
                        isSelected ? (themeManager.selectedAccent == .violet ? LinearGradient.brandFromDark0133_brandToDark0133 : themeManager.selectedAccent == .sunset ? LinearGradient.sunsetFrom0133_sunsetTo0133 : LinearGradient.auroraFrom0133_auroraTo0133 ) : LinearGradient(colors: [themeManager.white_white4], startPoint: .leading, endPoint: .trailing)
                    )
                
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(16)
            .overlay(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                themeManager.accentThemeColor,
                                lineWidth: 2
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                themeManager.textPrimaryLight8_white8,
                                lineWidth: 1
                            )
                    }
                }
            )
            .shadow(
                color: isSelected ? .brandMidDark7C5CFF.opacity(0.55) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: 4
            )
        }
    }
    
    // Light Preview Shapes
    private var lightPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.black.opacity(0.06))
                .frame(width: 32, height: 3)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.black.opacity(0.04))
                .frame(height: 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.black.opacity(0.02), lineWidth: 0.5)
                )
            
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.black.opacity(0.04))
                    .frame(width: 20, height: 3)
                Spacer()
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.black.opacity(0.04))
                    .frame(width: 10, height: 3)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
    
    // Dark Preview Shapes
    private var darkPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.08))
                .frame(width: 32, height: 3)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.04))
                .frame(height: 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.white.opacity(0.04), lineWidth: 0.5)
                )
            
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 20, height: 3)
                Spacer()
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 10, height: 3)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
    
    // Split Auto Preview
    private var autoPreview: some View {
        HStack(spacing: 0) {
            ZStack {
                Color(red: 247/255, green: 247/255, blue: 248/255)
                lightPreview
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ZStack {
                Color(red: 14/255, green: 16/255, blue: 26/255)
                darkPreview
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Accent Card View
struct AccentCard: View {
    @EnvironmentObject var themeManager : ThemeManager
    let accent      : ThemeManager.AppAccent
    let isSelected  : Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Gradient Solid Display Block
            ZStack {
                LinearGradient(
                    colors: accent.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Centered Checkmark when selected
                if isSelected {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(height: 72)
            .frame(maxWidth: .infinity)
            
            Text(accent.rawValue)
                .font(.geistSemiBold(12))
                .foregroundColor(
                    isSelected ? themeManager.accentColor : themeManager.textPrimaryLight6_dark62
                )
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    isSelected ? themeManager.accentColor.opacity(0.133) : themeManager.white_white4
                )
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(14)
        .overlay(
            Group {
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                themeManager.accentColor,
                                lineWidth: 2
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                themeManager.textPrimaryLight8_white8,
                                lineWidth: 1
                            )
                    }
                }
            }
        )
        .shadow(
            color: isSelected ? themeManager.accentTextColor.opacity(0.333) : Color.clear,
            radius: isSelected ? 8 : 0,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    AppearanceView()
        .environmentObject(ThemeManager())
}
