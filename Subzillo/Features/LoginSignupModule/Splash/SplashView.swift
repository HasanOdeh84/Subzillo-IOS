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
    @StateObject var appState         = AppState.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @EnvironmentObject var router     : AppIntentRouter
    
    var body: some View {
        ZStack {
            Group {
                Color("appBlack_white")
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("logo_svg")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .padding(.horizontal,70)
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .padding(.bottom,50)
                
                Text("One place for\n all your subscriptions")
                    .multilineTextAlignment(.center)
                    .font(.appRegular(24))
                    .foregroundColor(Color.blueMain700)
                    .padding(.bottom,60)
                
                LottieView(name: "splash_bubble",isAspectFit: false)
                    .frame(height: 242)
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(edges: .horizontal)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                //                withAnimation {
                //                }
                navigateToNextScreen()
            }
        }
    }
    
    private func navigateToNextScreen() {
        if appState.isLoggedIn {
            router.pendingRoute = .home
        } else {
            if hasSeenOnboarding {
                router.pendingRoute = .login
            } else {
                router.pendingRoute = .onboarding
            }
        }
    }
}

#Preview {
    SplashView()
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


