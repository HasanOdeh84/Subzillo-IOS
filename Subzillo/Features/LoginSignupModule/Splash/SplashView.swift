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
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var commonApiVM    = CommonAPIViewModel()
    
    var body: some View {
        ZStack {
            if self.isActive {
                if appState.isLoggedIn {
                    RootTabBar(path: $path)
                } else {
                    if hasSeenOnboarding{
                        LoginView(path: $path)
//                            .onAppear {
//                                if !path.isEmpty {
//                                    path.removeLast(path.count) // reset stack on login view
//                                }
//                            }
                    }else{
                        OnboardingView(path: $path)
                    }
                }
            }else {
//                Color.white
//                    .ignoresSafeArea()
                Group {
                    if colorScheme == .light {
                        Color.white // Light mode background
                    } else {
                        Color.black // Dark mode background
                    }
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
                    
                    LottieView(name: "splash_bubble")
                        .frame(height: 242)
                        .frame(maxWidth: .infinity)
                }
                .ignoresSafeArea(edges: .horizontal)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.isActive = true
                }
            }
            commonApiVM.getCurrencies()
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


