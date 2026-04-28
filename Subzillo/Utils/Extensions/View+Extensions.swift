//
//  View+Extensions.swift
//  Subzillo
//
//  Created by Antigravity on 08/01/26.
//

import SwiftUI

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func readHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SheetContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Title")
                .font(.headline)
                .padding()

            ForEach(0..<5) { _ in
                Text("Dynamic content")
                    .padding()
            }
            Spacer()
        }
        .padding()
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: SheetHeightKey.self,
                                value: geo.size.height)
            }
        )
    }
}

struct ContentView1: View {
    @State private var showSheet = false
    @State private var sheetHeight: CGFloat = .zero

    var body: some View {
        Button("Open sheet") {
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            SheetContentView()
            .padding()
            .overlay {
                GeometryReader { geometry in
                    Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                }
            }
            .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                sheetHeight = newHeight
            }
            .presentationDetents([.height(sheetHeight)])
        }
    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
