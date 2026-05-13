//
//  TabBarView.swift
//  SwiftUI_project_setup
//
//  Created by swathipriya pattem on 03/09/25.
//

import SwiftUI

struct RootTabBar: View {
    
    //MARK: - Properties
    @EnvironmentObject var router: AppIntentRouter
    var selectedTab     : Tab? = nil
    var selectedSegment : Segment? = nil
    
    //MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                Color(.neutralBg100)
                switch router.selectedTab {
                case .home:
                    HomeView(tabSelected:$router.selectedTab)
                case .subscriptions:
                    SubscriptionsView(selectedTab: router.selectedSegment)
                case .addSubscription:
                    AddSubscriptionsView()
                case .smartAI:
                    AgentChatView()
                case .profile:
                    ProfileView()
                }
            }
            .applyGlobalTransition()
            .id(router.selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            
            Color.clear
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let tab = selectedTab {
                router.selectedTab = tab
            }
            if let segment = selectedSegment {
                router.selectedSegment = segment
            }
        }
    }
}

#Preview {
    RootTabBar()
}

//MARK: - Curved tab bar
//MARK: - Floating tab bar
struct CurvedTabBar: View {
    @EnvironmentObject var router: AppIntentRouter
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Tab
    @Binding var selectedSegment: Segment?
    
    var body: some View {
        HStack(alignment: .bottom) {
            HStack(spacing: 0) {
                // Home Tab
                TabBarItem(label: "Home", iconName: "home_tab", tab: .home)
                
                // Subs Tab
                TabBarItem(label: "Subs", iconName: "subs_tab", tab: .subscriptions)
                
                // Center Action Button
                centerActionButton
                
                // Smart AI Tab
                TabBarItem(label: "Subzi", iconName: "subzi_tab", tab: .smartAI)
                
                // Profile Tab
                TabBarItem(label: "Profile", iconName: "profile_tab", tab: .profile)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(Color.bgPrimaryF7F7F90A0612.opacity(0.3))
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 0)
            }
            
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    private var centerActionButton: some View {
        Button {
            withAnimation(.customScreenAnimation) {
                router.selectedTab = .addSubscription
                router.path = [.home]
            }
        } label: {
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 64, height: 64)
                    .shadow(color: themeManager.accentShadowColor, radius: 10, x: 0, y: 5)
                //                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image("add_tab")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
            .offset(y: -5) // Slightly elevated
        }
        .frame(maxWidth: .infinity)
    }
}

//MARK: - TabBarItem
struct TabBarItem: View {
    let label: String
    let iconName: String
    let tab: Tab
    
    @EnvironmentObject var router: AppIntentRouter
    @EnvironmentObject var themeManager: ThemeManager
    
    var isSelected: Bool {
        router.selectedTab == tab
    }
    
    var body: some View {
        Button {
            withAnimation(.customScreenAnimation) {
                if tab == .subscriptions {
                    router.selectedSegment = .first
                }
                router.selectedTab = tab
                router.path = [.home]
            }
        } label: {
            VStack(spacing: 4) {
                // Selection Dot Indicator
                Circle()
                    .fill(isSelected ? themeManager.accentTextColor : Color.clear)
                    .frame(width: 4, height: 4)
//                    .padding(.bottom, 2)
                    .offset(y: -11)
                
                Image(iconName)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? themeManager.accentTextColor : Color.textDim60637AA8A4C0)
                    .padding(.top, -4)
                
                Text(label)
                    .font(.geistSemiBold(9))
                    .foregroundColor(isSelected ? themeManager.accentTextColor : Color.textDim60637AA8A4C0)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
