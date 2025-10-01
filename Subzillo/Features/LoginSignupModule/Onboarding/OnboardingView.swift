//
//  OnboardingView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/09/25.
//

import SwiftUI

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}

struct OnboardingView: View {
    
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "carousel",
            title: "All Your Subscriptions in One Place",
            description: "Add and track every subscription easily — from Netflix to gym memberships — all inside Subzillo"
        ),
        OnboardingPage(
            image: "carousel",
            title: "Let Subzillo Do the Work",
            description: "Add subscriptions by voice, screenshot, email, or bank statement. No more manual tracking."
        ),
        OnboardingPage(
            image: "carousel",
            title: "Stay Ahead with Reminders & Insights",
            description: "Get notified before renewals, monitor spending, and manage plans with ease."
        )
    ]
    
    var body: some View {
        VStack {
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        
                        Image(pages[index].image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .padding(.horizontal, 24)  
                        
                        Text(pages[index].title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text(pages[index].description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // hide default dots
            
            // Custom page indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.black : Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 20)
            
            // Buttons
            HStack {
                if currentPage == pages.count - 1 {
                }else{
                    Button("Skip") {
                        currentPage = pages.count - 1
                    }
                    .foregroundColor(.black)
                    Spacer()
                }
                
                if currentPage == pages.count - 1 {
                    Spacer()
                    CustomButton(title: "Get Started") {
                        print("Get Started tapped")
                    }
                    Spacer()
                } else {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}


#Preview {
    OnboardingView()
}
