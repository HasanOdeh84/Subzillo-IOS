//
//  ThemeManager.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//

import SwiftUI
//
//import SwiftUI
//
//@MainActor
//final class ThemeManager: ObservableObject {
//    // Persist theme state
//    @AppStorage("isDarkMode") private var storedIsDarkMode: Bool = false
//    @AppStorage("isUserChangedTheme") private var storedUserChanged: Bool = false
//
//    @Published var isDarkMode: Bool = false
//    @Published var userChangedTheme: Bool = false
//
//    init() {
//        // Load saved state
//        self.isDarkMode = storedIsDarkMode
//        self.userChangedTheme = storedUserChanged
//    }
//
//    /// Called when user toggles dark mode in app
//    func setDarkMode(_ isOn: Bool) {
//        isDarkMode = isOn
//        userChangedTheme = true
//        storedIsDarkMode = isOn
//        storedUserChanged = true
//    }
//
//    /// Called automatically when device theme changes
//    func updateFromSystem(_ scheme: ColorScheme) {
//        guard !userChangedTheme else { return } // follow system only if user hasn’t changed manually
//        isDarkMode = (scheme == .dark)
//    }
//
//    /// Used by `.preferredColorScheme`
//    var preferredColorScheme: ColorScheme? {
//        userChangedTheme ? (isDarkMode ? .dark : .light) : nil
//    }
//}
//
//import SwiftUI
//
//@MainActor
//final class ThemeManager: ObservableObject {
//    @AppStorage("isDarkMode") private var storedIsDarkMode: Bool = false
//    @AppStorage("isUserChangedTheme") private var storedUserChanged: Bool = false
//
//    @Published var isDarkMode: Bool = false
//    @Published var userChangedTheme: Bool = false
//
//    init() {
//        // Immediately align on main queue after @AppStorage syncs
//        DispatchQueue.main.async {
//            let systemIsDark = UITraitCollection.current.userInterfaceStyle == .dark
//            self.userChangedTheme = self.storedUserChanged
//            self.isDarkMode = self.userChangedTheme ? self.storedIsDarkMode : systemIsDark
//        }
//    }
//
//    func setDarkMode(_ isOn: Bool) {
//        withAnimation {
//            isDarkMode = isOn
//        }
//        storedIsDarkMode = isOn
//        storedUserChanged = true
//        userChangedTheme = true
//    }
//
//    func updateFromSystem(_ scheme: ColorScheme) {
//        guard !userChangedTheme else { return }
//        withAnimation {
//            isDarkMode = (scheme == .dark)
//        }
//    }
//
//    var preferredColorScheme: ColorScheme? {
//        userChangedTheme ? (isDarkMode ? .dark : .light) : nil
//    }
//}


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
}


