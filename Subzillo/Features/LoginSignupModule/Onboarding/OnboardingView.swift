//
//  OnboardingView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/09/25.
//

import SwiftUI

struct OnboardingPage {
    let image       : String
    let title       : String
    let description : String
}

struct OnboardingView: View {
    
    @State private var currentPage  = 0
    @Binding var path               : NavigationPath
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "onboarding",
            title: "Manage your and your family's subscriptions in one place",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
        ),
        OnboardingPage(
            image: "onboarding",
            title: "Manage your and your family's subscriptions in one place",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
        ),
        OnboardingPage(
            image: "onboarding",
            title: "Manage your and your family's subscriptions in one place",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
        ),
        OnboardingPage(
            image: "onboarding",
            title: "Manage your and your family's subscriptions in one place",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
        ),
        OnboardingPage(
            image: "onboarding",
            title: "Manage your and your family's subscriptions in one place",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
        )
    ]
    
    var body: some View {
        VStack {

            HStack(spacing: 10){
                Spacer()
                NavigationLink("Skip Onboarding", destination: LoginView(path: $path))
                    .foregroundColor(Color.navyBlueCTA700)
                    .font(.appRegular(14))
                Image(systemName: "arrow.right")
                    .foregroundColor(Color.blueMain700)
                    .frame(width: 20,height: 20)
            }
            .padding(.vertical,32)
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack {
                        if currentPage == pages.count - 1{
                            
                        }else{
                            
                        }
                        Image(pages[index].image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 190)
                        
                        Text(LocalizedStringKey(pages[index].title))
                            .font(.appRegular(28))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top,64)
                        
                        Text(LocalizedStringKey(pages[index].description))
                            .font(.appRegular(18))
                            .foregroundColor(Color.neutral500)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top,32)
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // hide default dots
            
            // Custom page indicator
            HStack(spacing: 13) {
                ForEach(0..<pages.count, id: \.self) { index in
                    if index == currentPage{
                        Capsule()
                            .fill(Color.blueMain700)
                            .frame(width: 32, height: 8)
                    }else{
                        Circle()
                            .fill(Color.neutral400)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.bottom, 23)
           
            GradientBorderButton(title: currentPage == pages.count - 1 ?
                                 "Lets Go!" : "Next") {
//                withAnimation {
                    if currentPage == pages.count - 1{
                        path.append(PendingRoute.login)
                    }else{
                        currentPage += 1
                    }
//                }
            }
            .padding(.bottom,48)
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(path: .constant(NavigationPath()))
    }
}
