//
//  ThemeManager.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//

import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") private var storedIsDarkMode = false
    @AppStorage("userChangedTheme") private var storedUserChanged = false
    
    @Published var isDarkMode: Bool = false
    @Published var userChangedTheme: Bool = false
    
    init() {
        // After properties are initialized, now read stored values
        let savedDark = storedIsDarkMode
        let savedUserChanged = storedUserChanged
        
        self.isDarkMode = savedDark
        self.userChangedTheme = savedUserChanged
    }
    
    func toggleTheme() {
        withAnimation {
            isDarkMode.toggle()
        }
        storedIsDarkMode = isDarkMode
        storedUserChanged = true
        userChangedTheme = true
    }
    
    func resetToSystem() {
        storedUserChanged = false
        userChangedTheme = false
    }
    
    func applyUserTheme(_ isDark: Bool) {
        withAnimation {
            isDarkMode = isDark
        }
        userChangedTheme = true
        storedIsDarkMode = isDark
        storedUserChanged = true
    }
    
    // Used internally when following system
    func applySystemTheme(_ isDark: Bool) {
        guard !userChangedTheme else { return }
        isDarkMode = isDark
    }
}
