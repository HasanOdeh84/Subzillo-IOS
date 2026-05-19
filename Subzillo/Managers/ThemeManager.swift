//
//  ThemeManager.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//

import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    
    // MARK: - Enums
    
    enum AppearanceMode: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case auto = "Auto"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .auto: return nil
            }
        }
    }
    
    enum GradientStyle: String, CaseIterable {
        case horizontal = "Horizontal"
        case vertical   = "Vertical"
        case diagonal   = "Diagonal"
        
        var points: (start: UnitPoint, end: UnitPoint) {
            switch self {
            case .horizontal: return (.leading, .trailing)
            case .vertical:   return (.top, .bottom)
            case .diagonal:   return (.topLeading, .bottomTrailing)
            }
        }
    }
    
    enum AppAccent: String, CaseIterable {
        case violet = "Violet"
        case sunset = "Sunset"
        case aurora = "Aurora"
        
        var colors: [Color] {
            switch self {
            case .violet: return [.brandFromDarkA719DD, .brandMidDark7C5CFF, .brandToDark4489EB]
            case .sunset: return [.sunsetFromF35BB3, .sunsetMidCB61FA, .sunsetTo764CFF]
            case .aurora: return [.auroraFrom13D8B0, .auroraMid5598EA, .auroraTo9A28DF]
            }
        }
        
        var primaryColor: Color { colors[0] }
        var lastColor: Color { colors[2] }
        var senColor: Color { colors[1] }
        
        var textThemeColor: Color {
            switch self {
            case .violet: return Color.brandMidDark7C5CFF
            case .sunset: return Color.sunsetMidCB61FA
            case .aurora: return Color.brandToDark4489EB
            }
        }
        
        var shadowColor: Color {
            senColor.opacity(0.55)
        }
    }
    
    // MARK: - Published Properties
    @AppStorage("app_appearance_mode") var selectedAppearance: AppearanceMode = .auto
    @AppStorage("app_accent_color") var selectedAccent: AppAccent = .violet
    @AppStorage("app_gradient_style") var selectedGradientStyle: GradientStyle = .diagonal
    
    // These are published to trigger UI updates immediately
    @Published var currentAppearance: AppearanceMode = .auto
    @Published var currentAccent: AppAccent = .violet
    @Published var currentGradientStyle: GradientStyle = .diagonal
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        // Initialize from storage
        self.currentAppearance = selectedAppearance
        self.currentAccent = selectedAccent
        self.currentGradientStyle = selectedGradientStyle
    }
    
    // MARK: - Setters
    
    func setAppearance(_ mode: AppearanceMode) {
        withAnimation(.easeInOut) {
            selectedAppearance = mode
            currentAppearance = mode
        }
        HapticManager.shared.trigger(.selection)
    }
    
    func setAccent(_ accent: AppAccent) {
        withAnimation(.spring()) {
            selectedAccent = accent
            currentAccent = accent
        }
        HapticManager.shared.trigger(.impact(.medium))
    }
    
    func setGradientStyle(_ style: GradientStyle) {
        withAnimation(.easeInOut) {
            selectedGradientStyle = style
            currentGradientStyle = style
        }
        HapticManager.shared.trigger(.selection)
    }
    
    // MARK: - Computed Helpers
    
    // Returns the gradient using the GLOBAL style.
    var accentGradient: LinearGradient {
        gradient(style: currentGradientStyle)
    }
    
    // Returns the gradient using a SPECIFIC style (Vertical, Horizontal, etc.)
    func gradient(style: GradientStyle) -> LinearGradient {
        LinearGradient(
            colors: currentAccent.colors,
            startPoint: style.points.start,
            endPoint: style.points.end
        )
    }
    
    var accentColor: Color {
        currentAccent.primaryColor
    }
    
    var accentTextColor: Color {
        currentAccent.senColor
    }
    
    var accentLastColor: Color {
        currentAccent.lastColor
    }
    
    var accentThemeColor: Color {
        currentAccent.textThemeColor
    }
    
    var accentShadowColor: Color {
        currentAccent.shadowColor
    }
    
    var textPrimaryLight8_white8: Color {
        .dynamic(
            light: Color.textPrimaryLight0E101A.opacity(0.08),
            dark: Color.surfaceLightFFFFFF.opacity(0.08)
        )
    }
    
    var textPrimaryLight6_dark62: Color {
        .dynamic(
            light: Color.textPrimaryLight0E101A.opacity(0.6),
            dark: Color.textPrimaryDarkF4F1FB.opacity(0.62)
        )
    }
    
    var black5_white6: Color {
        .dynamic(
            light: Color.black.opacity(0.05),
            dark: Color.white.opacity(0.06)
        )
    }
    
    var black_white: Color {
        .dynamic(
            light: Color.black,
            dark: Color.white
        )
    }
    
    var white_white4: Color {
        .dynamic(
            light: Color.white,
            dark: Color.white.opacity(0.04)
        )
    }
    
    var textPrimaryLight14_white14: Color {
        .dynamic(
            light: Color.textPrimaryLight0E101A.opacity(0.14),
            dark: Color.white.opacity(0.14)
        )
    }
    
    var selectionFieldBorder: some View {
        return ZStack {
            // Soft outer glow/border
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    accentShadowColor,
                    lineWidth: 3
                )
                .padding(-2)
            // Main sharp border
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    accentTextColor,
                    lineWidth: 1.5
                )
        }
    }
}

/*

TExt primary light - 0E101A - rgb(14, 16, 26)
TExt primary dark - F4F1FB - rgb(244, 241, 251)
 
 
 title - textprimary - bold 28 geist
 desc - textPrimaryLight6_dark62- geist reg 14
 
 field title - textPrimaryLight6_dark62 - jet brains 11 reg
 placeholder - textprimary
 
 field border - textPrimaryLight8_white8
 field bg - white_white4
 
 terms - textPrimaryLight6_dark62 -geist reg 11
 
 1px solid rgb(124, 92, 255) - brandMidDark7C5CFF
 rgba(124, 92, 255, 0.12) 0px 0px 0px 4px
 
 1.5px solid rgb(124, 92, 255)
 rgba(124, 92, 255, 0.55) 0px 0px 0px 3px
 
 1.5px solid rgb(124, 92, 255)
 rgba(124, 92, 255, 0.55) 0px 0px 0px 3px
*/

