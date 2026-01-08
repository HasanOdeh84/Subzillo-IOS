//
//  ShimmerManager.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 02/01/26.
//

import SwiftUICore

//struct ShimmerModifier: ViewModifier {
//    @State private var animate = true
//    
//    func body(content: Content) -> some View {
//        content
//            .redacted(reason: .placeholder) // Applies system gray boxes
//            .opacity(animate ? 1 : 0.5) // Adds a subtle breathing/pulsing effect
//            .onAppear {
//                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
//                    animate = true
//                }
//            }
//    }
//}

struct ShimmerModifier: ViewModifier {
    @State private var animate = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.white.opacity(0.3),
                        Color.clear
                    ]),
                    startPoint: animate ? .topTrailing : .bottomLeading,
                    endPoint: animate ? .bottomLeading : .topTrailing
                )
                .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: animate)
                .onAppear {
                    animate = true
                }
                    .mask(content)
            )
    }
}
