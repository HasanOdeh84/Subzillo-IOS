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
            case .violet: return [.accentVioletStart, .accentVioletMid, .accentVioletEnd]
            case .sunset: return [.accentSunsetStart, .accentSunsetMid, .accentSunsetEnd]
            case .aurora: return [.accentAuroraStart, .accentAuroraMid, .accentAuroraEnd]
            }
        }
        
        var primaryColor: Color { colors[0] }
    }
    
    // MARK: - Published Properties
    @AppStorage("app_appearance_mode") var selectedAppearance: AppearanceMode = .auto
    @AppStorage("app_accent_color") var selectedAccent: AppAccent = .violet
    @AppStorage("app_gradient_style") var selectedGradientStyle: GradientStyle = .diagonal
    
    // These are published to trigger UI updates immediately
    @Published var currentAppearance: AppearanceMode = .auto
    @Published var currentAccent: AppAccent = .violet
    @Published var currentGradientStyle: GradientStyle = .diagonal
    
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
}
