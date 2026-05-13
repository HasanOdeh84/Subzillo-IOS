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
struct CurvedTabBar: View {
    @EnvironmentObject var router: AppIntentRouter
    @Binding var selectedTab : Tab
    @Binding var selectedSegment: Segment?
    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .bottom) {
                TabBarItem(label: "Home", iconName: router.selectedTab == .home ? "home-tabSelected" : "home-tab", action: {
                    withAnimation(.customScreenAnimation) {
                        router.selectedTab = .home
                        router.path = [.home]
                    }
                }, selectedTab: $router.selectedTab, tab: .home)
                TabBarItem(label: "My Subs", iconName: router.selectedTab == .subscriptions ? "mySubs-tabSelected" : "mySubs-tab", action: {
                    withAnimation(.customScreenAnimation) {
                        router.selectedSegment = .first
                        router.selectedTab = .subscriptions
                        router.path = [.home]
                    }
                }, selectedTab: $router.selectedTab, tab: .subscriptions)
                
                VStack {
                    Button {
                        withAnimation(.customScreenAnimation) {
                            router.selectedTab = .addSubscription
                            router.path = [.home]
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700],
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .frame(width: 55, height: 55)
                            
                            Image("plus-tab")
                                .frame(width: 55/2, height: 55/2)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 14)
                .frame(height: 86)
                
                TabBarItem(label: "Smart AI", iconName: router.selectedTab == .smartAI ? "smartAI-tabSelected" : "smartAI-tab", action: {
                    Constants.FeatureConfig.performS5Action {
                        withAnimation(.customScreenAnimation) {
                            router.selectedTab = .smartAI
                            router.path = [.home]
                        }
                    }
                }, selectedTab: $router.selectedTab, tab: .smartAI)
                TabBarItem(label: "My Profile", iconName: router.selectedTab == .profile ? "profile-tabSelected" : "profile-tab", action: {
                    withAnimation(.customScreenAnimation) {
                        router.selectedTab = .profile
                        router.path = [.home]
                    }
                }, selectedTab: $router.selectedTab, tab: .profile)
            }
            .font(.footnote)
            .padding(.horizontal, 10)
            .padding(.bottom, max(0, 8 - proxy.safeAreaInsets.bottom))
            .background {
                CurvedShape()
                    .fill(Color.whiteNeutralCardBG)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    .ignoresSafeArea()
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

//MARK: - TabBarItem
struct TabBarItem: View {
    let label                   : String
    let iconName                : String
    let action                  : () -> Void
    @Binding var selectedTab    : Tab
    @State var tab              : Tab
    
    var body: some View {
        
        Button(action: action) {
            VStack(spacing: 4) {
                Image(iconName)
                    .frame(width: 24,height: 24)
                if selectedTab == tab {
                    Text(label)
                        .overlay(
                            LinearGradient(
                                colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .mask(
                            Text(label)
                        )
                } else {
                    Text(label)
                        .foregroundColor(.neutral400)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

//MARK: - Curved shape
struct CurvedShape: Shape {
    private enum Constants {
        static let cornerRadius: CGFloat = 0
        static let smallCornerRadius: CGFloat = 20
        static let buttonRadius: CGFloat = 35
        static let buttonPadding: CGFloat = 9
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Move to the starting point at the bottom-left corner
        var x = rect.minX
        var y = rect.maxY
        path.move(to: CGPoint(x: x, y: y))
        
        // Add the rounded corner on the top-left corner
        x += Constants.cornerRadius
        y = Constants.buttonRadius + Constants.cornerRadius - 10
        path.addArc(
            center: CGPoint(x: x, y: y),
            radius: Constants.cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        // Add a small corner leading to the main half-circle
        x = rect.midX - Constants.buttonRadius - (Constants.buttonPadding / 2) - Constants.smallCornerRadius + 9
        y = Constants.buttonRadius - Constants.smallCornerRadius - 10
        path.addArc(
            center: CGPoint(x: x, y: y),
            radius: Constants.smallCornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(35), // 0
            clockwise: true
        )
        // Add the main half-circle
        x = rect.midX
        y += Constants.smallCornerRadius + Constants.buttonPadding
        y = y + 11
        path.addArc(
            center: CGPoint(x: x, y: y),
            radius: Constants.buttonRadius + Constants.buttonPadding,
            startAngle: .degrees(215), // 180
            endAngle: .degrees(325), // 0
            clockwise: false
        )
        // Add a trailing small corner
        x += Constants.buttonRadius + (Constants.buttonPadding / 2) + Constants.smallCornerRadius - 9
        y = Constants.buttonRadius - Constants.smallCornerRadius - 10
        path.addArc(
            center: CGPoint(x: x, y: y),
            radius: Constants.smallCornerRadius,
            startAngle: .degrees(145), // 180
            endAngle: .degrees(90),
            clockwise: true
        )
        // Add the rounded corner on the top-right corner
        x = rect.maxX - Constants.cornerRadius
        y = Constants.buttonRadius + Constants.cornerRadius - 10
        path.addArc(
            center: CGPoint(x: x, y: y),
            radius: Constants.cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        // Connect the bottom corner
        x = rect.maxX
        y = rect.maxY
        path.addLine(to: CGPoint(x: x, y: y))
        
        // Close the path to complete the shape
        path.closeSubpath()
        return path
    }
}
