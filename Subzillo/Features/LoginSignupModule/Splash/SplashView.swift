//
//  SplashView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI

struct SplashView: View {
    
    //MARK: - Properties
    @StateObject var appState           = AppState.shared
    @EnvironmentObject var router       : AppIntentRouter
    @EnvironmentObject var themeManager : ThemeManager
    @State private var progress         : CGFloat = 0.0
    @State private var statusText       : String = "Initializing..."
    private let statusMessages          = [
        "Initializing...",
        "Loading...",
        "Setting up...",
        "Building Subzi Ai",
        "Ready..."
    ]
    
    //MARK: - Body
    var body: some View {
        VStack {
            Spacer()
            
//            LottieView(name: "splash_animation", loopMode: .loop)
//                .frame(width: 300, height: 300)
            Image("splash_new")
                .frame(width: 300, height: 300)
            
            Spacer()
            
            VStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.grayCBD5E1)
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(themeManager.accentGradient)
                            .frame(width: geo.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)
                
                HStack {
                    Text(statusText)
                        .font(.jetBrainsMedium(11))
                        .foregroundColor(Color.textFaintDark7A7698)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.jetBrainsMedium(11))
                        .foregroundColor(Color.textFaintDark7A7698)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .applyAppBackground()
        .onAppear {
            startSplashSequence()
        }
    }
    
    private func startSplashSequence() {
        progress = 0.0
        
        let totalSteps = 100
        let duration: Double = 3.0
        let stepDuration = duration / Double(totalSteps)
        
        var currentStep = 0
        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            let targetProgress = CGFloat(currentStep) / CGFloat(totalSteps)
            
            withAnimation(.linear(duration: stepDuration)) {
                self.progress = targetProgress
            }
            
            if currentStep >= totalSteps {
                timer.invalidate()
            }
        }
        
        let initialMessages = Array(statusMessages.prefix(4))
        for (index, message) in initialMessages.enumerated() {
            let delay = Double(index) * 0.675
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut) {
                    statusText = message
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            withAnimation(.easeInOut) {
                statusText = "Ready..."
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            navigateToNextScreen()
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
                router.resetStack(to: [.home, target])
                router.pendingNotification = nil
            } else {
                router.resetStack(to: [.home])
            }
        } else {
            router.resetStack(to: [.login])
        }
    }
}

#Preview {
    SplashView()
}
