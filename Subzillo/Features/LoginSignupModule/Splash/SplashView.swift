//
//  SplashView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI

struct SplashView: View {
    @State private var animateBubbles   = false
    @State var isActive                 : Bool = false
    @StateObject var appState           = AppState.shared
    @EnvironmentObject var router       : AppIntentRouter
    @StateObject private var pricingVM  = PricingPlansViewModel.shared

    var body: some View {
        ZStack {
            Group {
                Color(.white)
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
            if appState.isLoggedIn {
            }

//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                navigateToNextScreen()
//            }
        }
    }
    
    private func navigateToNextScreen() {
        // If a notification already triggered a navigation, 
        // don't perform the default splash navigation.
        if router.hasNavigatedFromSplash {
            return
        }
        if appState.isLoggedIn {
            if let target = router.pendingNotification {
                router.resetStackTo = [.home, target]
                router.pendingNotification = nil
            } else {
                router.navigatingRoute = .home
            }
        } else {
            router.navigatingRoute = .login
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


