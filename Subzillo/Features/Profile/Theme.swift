//
//  Theme.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//

import SwiftUI

struct Theme: View {
    @EnvironmentObject var themeManager: ThemeManager
        @Environment(\.colorScheme) private var systemScheme

        // Determine the active theme (system or overridden)
        private var activeScheme: ColorScheme {
            if themeManager.userChangedTheme {
                return themeManager.isDarkMode ? .dark : .light
            } else {
                return systemScheme // follow system instantly
            }
        }

        var body: some View {
            VStack(spacing: 30) {
                Text("Hello, SwiftUI!")
                    .padding()
                    .foregroundColor(activeScheme == .dark ? .white : .black)
                    .background(activeScheme == .dark ? .blue : .red)
                    .cornerRadius(20)

                Toggle(isOn: Binding(
                    get: { themeManager.isDarkMode },
                    set: { _ in themeManager.toggleTheme() }
                )) {
                    Label("Dark Mode", systemImage: "moon.fill")
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))

                if themeManager.userChangedTheme {
                    Button("Use System Theme Again") {
                        withAnimation {
                            themeManager.resetToSystem()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .animation(.easeInOut, value: activeScheme)
        }
    }


struct SystemTheme: View {
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    Button("Hello, SwiftUI!", action: {})
      .padding()
      .foregroundColor(colorScheme == .dark ? .white : .black)
      .background(colorScheme == .dark ? .blue : .red)
      .cornerRadius(20)
  }
}
