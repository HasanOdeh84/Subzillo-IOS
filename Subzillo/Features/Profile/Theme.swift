//
//  Theme.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//

import SwiftUI

struct Theme: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Hello, SwiftUI!")
                .padding()
                .foregroundColor(.primaryText)
                .background(.appBackground)
                .cornerRadius(20)
            
            Toggle(isOn: Binding(
                get: { themeManager.isDarkMode },
                set: { _ in themeManager.toggleTheme() }
            )) {
                Label("Dark Mode", systemImage: "moon.fill")
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            
//            if themeManager.userChangedTheme {
//                Button("Use System Theme Again") {
//                    withAnimation {
//                        themeManager.resetToSystem()
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//            }
        }
        .padding()
    }
}
