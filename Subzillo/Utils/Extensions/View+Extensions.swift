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
    
    /// Applies the global "Fade + Slide Up" transition
    func applyGlobalTransition() -> some View {
        self.transition(.fadeAndSlideUp)
    }
    
    /// Applies the brand dynamic background (glow circles) to the view.
    func applyAppBackground() -> some View {
        self.modifier(AppBackgroundModifier())
    }
    
    /// Applies a staggered entrance animation (Fade + Slide Up) to an individual element.
    /// - Parameter index: The position in the sequence (used for delay).
    func animateEntrance(index: Int = 0) -> some View {
        modifier(EntranceAnimationModifier(index: index))
    }
}

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            DynamicBackgroundView()
            content
        }
    }
}

// MARK: - Global Transitions

struct EntranceAnimationModifier: ViewModifier {
    let index: Int
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.customScreenAnimation.delay(Double(index) * 0.08)) {
                    isVisible = true
                }
            }
    }
}

extension AnyTransition {
    static var fadeAndSlideUp: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .offset(y: 5))
                .animation(.customScreenAnimation),
            removal: .opacity
                .animation(.easeOut(duration: 0.2))
        )
    }
}

extension Animation {
    static var customScreenAnimation: Animation {
        .timingCurve(0.2, 0.9, 0.3, 1.0, duration: 0.3)
    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Interactive Button Style
/*struct InteractiveButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {

        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(
                configuration.isPressed
                ? .interactiveSpring(response: 0.15,
                                     dampingFraction: 0.8)
                : .spring(response: 0.35,
                          dampingFraction: 0.6),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { pressed in
                if pressed {
                    UIImpactFeedbackGenerator(style: .medium)
                        .impactOccurred()
                }
            }
    }
}*/
struct InteractiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        InteractiveButtonWrapper(configuration: configuration)
    }
}

private struct InteractiveButtonWrapper: View {
    let configuration: ButtonStyle.Configuration
    @State private var quickTapped = false
    @State private var didLongPress = false

    var body: some View {
        let isCurrentlyPressed = configuration.isPressed || quickTapped
        
        configuration.label
            .scaleEffect(isCurrentlyPressed ? 0.92 : 1.0)
            .animation(
                .interactiveSpring(response: 0.2, dampingFraction: 0.7),
                value: isCurrentlyPressed
            )
            .onChange(of: configuration.isPressed) { pressed in
                if pressed {
                    didLongPress = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        didLongPress = false
                    }
                }
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    if !didLongPress {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        quickTapped = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            quickTapped = false
                        }
                    }
                }
            )
    }
}
/*
struct InteractiveButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {

        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(
                .spring(response: 0.22, dampingFraction: 0.7),
                value: configuration.isPressed
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !configuration.isPressed {
                            UIImpactFeedbackGenerator(style: .medium)
                                .impactOccurred()
                        }
                    }
            )
    }
}*/
//extension ShapeStyle where Self == LinearGradient {
//    static var primaryTextGradient: LinearGradient {
//        LinearGradient(
//            colors: [
//                Color.brandGlowDarkA719DD,
//                Color.brandToDark4489EB
//            ],
//            startPoint: .leading,
//            endPoint: .trailing
//        )
//    }
//}

extension LinearGradient {
    static let primaryTextGradient = LinearGradient(
        colors: [
            Color.brandGlowDarkA719DD,
            Color.brandToDark4489EB
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let brandFromDark0133_brandToDark0133 = LinearGradient(
        colors: [
            .brandFromDarkA719DD.opacity(0.133),
            .brandToDark4489EB.opacity(0.133)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let sunsetFrom0133_sunsetTo0133 = LinearGradient(
        colors: [
            .sunsetFromF35BB3.opacity(0.133),
            .sunsetTo764CFF.opacity(0.133)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let auroraFrom0133_auroraTo0133 = LinearGradient(
        colors: [
            .auroraFrom13D8B0.opacity(0.133),
            .auroraTo9A28DF.opacity(0.133)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

