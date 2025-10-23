//
//  SplashView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI

struct SplashView: View {
    @State private var animateBubbles = false
    @State var isActive               : Bool = false
    @Binding var path                 : NavigationPath
    @StateObject var appState         = AppState.shared
    
    var body: some View {
        ZStack {
            if self.isActive {
                if appState.isLoggedIn {
                    RootTabBar(path: $path)
                } else {
//                    LoginView(path: $path)
//                        .onAppear {
//                            if !path.isEmpty {
//                                path.removeLast(path.count) // reset stack on login view
//                            }
//                        }
                    OnboardingView(path: $path)
                }
            }else {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 60) {
                    Spacer()
                    
                    Image("splash_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .padding(.horizontal,70)
                        .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Text("One place for\n all your subscriptions")
                        .multilineTextAlignment(.center)
                        .font(.appRegular(24))
                        .foregroundColor(Color.blueMain700)
                    
                    Spacer()
                    
                    // Animated Bubbles Section
//                    ZStack {
//                        ForEach(0..<8) { index in
//                            BubbleView(size: CGFloat.random(in: 20...60))
//                                .offset(
//                                    x: CGFloat.random(in: -150...150),
//                                    y: animateBubbles ? CGFloat.random(in: -20...20) : CGFloat.random(in: 20...40)
//                                )
//                                .animation(
//                                    Animation.easeInOut(duration: Double.random(in: 2...4))
//                                        .repeatForever(autoreverses: true)
//                                        .delay(Double(index) * 0.3),
//                                    value: animateBubbles
//                                )
//                        }
//                    }
//                    .frame(height: 100)
//                    .onAppear {
//                        animateBubbles = true
//                    }
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashView(path: .constant(NavigationPath()))
}

// MARK: - Bubble View
struct BubbleView: View {
    let size: CGFloat
    private let color: Color = [Color.blue.opacity(0.7),
                                Color.purple.opacity(0.7),
                                Color.black.opacity(0.8)].randomElement()!
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}


