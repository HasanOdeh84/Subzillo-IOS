//
//  TabBarView.swift
//  SwiftUI_project_setup
//
//  Created by swathipriya pattem on 03/09/25.
//

import SwiftUI

struct RootTabBar: View {
    @State private var selectedTab              : Tab = .home
    @EnvironmentObject var router               : AppIntentRouter
    @Binding var path                           : NavigationPath
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    //                        HomeView()
                    VoiceCommandView()
                case .subscriptions:
                    SubscriptionsView()
                case .analytics:
                    AnalyticsView()
                case .activity:
                    ActivityView()
                case .profile:
                    ProfileView(path: $path)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
            
            tabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .onChange(of: router.pendingRoute) { new in
            if let new = new {
                path.append(new)
                router.pendingRoute = nil
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var tabBar: some View {
        HStack {
            tabButton(.home, icon: "house.fill", title: "Home")
            Spacer()
            tabButton(.subscriptions, icon: "shippingbox.fill")
            
            Spacer().frame(width: 120) // space for center button
            
            tabButton(.activity, icon: "chart.bar.fill")
            Spacer()
            tabButton(.profile, icon: "arrow.clockwise")
        }
        .padding(.horizontal, 30)
        .frame(height: 75)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        )
        .overlay(centerButton, alignment: .top)
    }
    
    // Center floating button
    private var centerButton: some View {
        Button(action: {
            selectedTab = .analytics
        }) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 65, height: 65)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                   startPoint: .top, endPoint: .bottom)
                )
                .clipShape(Circle())
                .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .offset(y: -30)
    }
    
    // Tab button
    private func tabButton(_ tab: Tab, icon: String, title: String? = nil) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                if let title = title {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                }
            }
        }
    }
    
    //Local push for testing
    func scheduleTestPush(type: String, extra: [String: Any] = [:]) {
        let content = UNMutableNotificationContent()
        content.title = "Test Push"
        content.body = "Triggered for \(type)"
        
        // 👇 add payload data to userInfo
        let userInfo: [String: Any] = ["type": type]
        //        extra.forEach { userInfo[$0] = $1 }
        content.userInfo = userInfo
        
        // trigger after 5 sec
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    //    RootTabBar()
}
