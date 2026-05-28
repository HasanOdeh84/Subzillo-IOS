//
//  ExceedLimit.swift
//  Subzillo
//
//  Created by Ratna Kavya on 22/05/26.
//

import SwiftUI

struct ExceedLimit: View {
    
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject var subscriptionsVM            = SubscriptionsViewModel()
    @State private var subscriptionsList        = [SubscriptionListData]()
    @StateObject var commonVM                   = CommonAPIViewModel()
    @State private var animatedProgress         : Double = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Gauge
                    ZStack(alignment: .bottom) {
                        /*ZStack {
                            Circle()
                                .trim(from: 0.5, to: 1.0)
                                .stroke(
                                    themeManager.textPrimaryLight6_dark62.opacity(0.1),
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                            
                            Circle()
                                .trim(from: 0.5, to: 0.5 + CGFloat(animatedProgress * 0.5))
                                .stroke(
                                    Color.dangerDarkFF5A7A,
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .shadow(color: Color.dangerDarkFF5A7A.opacity(0.6), radius: 15, x: 0, y: 0)
                        }
                        .frame(width: 210, height: 210)
                        .frame(height: 105, alignment: .top) // Clip to top half*/
                        
                        ZStack {
                            ArcShape(startAngle: .degrees(-210),
                                     endAngle: .degrees(30))
                            .stroke(
                                themeManager.textPrimaryLight6_dark62.opacity(0.1),
                                style: StrokeStyle(lineWidth: 16, lineCap: .round)
                            )
                            
                            ArcShape(
                                startAngle: .degrees(-210),
                                endAngle: .degrees(30)
                            )
                            .trim(from: 0, to: animatedProgress)
                            .stroke(
                                Color.dangerDarkFF5A7A,
                                style: StrokeStyle(lineWidth: 16, lineCap: .round)
                            )
                            .shadow(color: Color.dangerDarkFF5A7A.opacity(0.6), radius: 15, x: 0, y: 0)
                        }
                        .frame(width: 210, height: 210)
                        .offset(y: -46)
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 0) {
                                Text("\(commonVM.userInfoResponse?.planSubscriptionLimit ?? 0)")
                                    .font(.geistExtraBold(50))
                                    .foregroundStyle(
                                        Color.dangerDarkFF5A7A
                                    )
                                
                                Text("/\(commonVM.userInfoResponse?.planSubscriptionLimit ?? 0)")
                                    .font(.geistMedium(22))
                                    .foregroundColor(
                                        themeManager.textPrimaryLight6_dark62
                                    )
                                    .offset(x: 0, y: 5)
                            }
                            .kerning(-2)
                            
                            Text("SUBSCRIPTIONS")
                                .font(.jetBrainsMedium(10))
                                .tracking(3)
                                .foregroundColor(
                                    themeManager.textPrimaryLight6_dark62
                                )
                        }
                        .padding(.bottom, 12) // Position text nicely inside the arc
                    }
                    .padding(.top, 100)
                    .padding(.bottom, 30)
                    
                    // MARK: - Title
                    Text("You've hit the limit")
                        .font(.geistBold(28))
                        .kerning(-1)
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    
                    // MARK: - Subtitle
                    Text("\(commonVM.userInfoResponse?.planName ?? "") plan caps at \(commonVM.userInfoResponse?.planSubscriptionLimit ?? 0). Unlock unlimited tracking with Premium.")
                        .font(.geistRegular(13))
                        .foregroundColor(
                            themeManager.textPrimaryLight6_dark62
                        )
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .frame(maxWidth: 240)
                        .padding(.top, 8)
                    
                    // MARK: - Icons
                    HStack(spacing: 10) {
                        Image("limit1")
                            .frame(width: 38, height: 38)
                        Image("limit2")
                            .frame(width: 38, height: 38)
                        Image("limit3")
                            .frame(width: 38, height: 38)
                        Image("limit4")
                            .frame(width: 38, height: 38)
                        Image("limit5")
                            .frame(width: 38, height: 38)
                        Image("limit6")
                            .frame(width: 38, height: 38)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
            }
            
            // MARK: - Upgrade and later Button
            VStack(spacing: 0) {
                GradientBgButton(
                    title       : "Upgrade now",
                    isSolid     : true,
                    showChevron : false
                ) {
                    clickOnUpgrade()
                }
                
                Button {
                    clickonMayBe()
                } label: {
                    Text("Maybe later")
                        .font(.geistRegular(13))
                        .foregroundColor(
                            themeManager.textPrimaryLight6_dark62
                        )
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .padding(.top, 15)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 120)
        }
        .applyAppBackground()
        .navigationBarBackButtonHidden()
        .onAppear
        {
            self.subscriptionsList.removeAll()
            listSubsApi()
            commonVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
            
            withAnimation(.easeOut(duration: 1.2).delay(0.1)) {
                animatedProgress = 1.0
            }
        }
        .onChange(of: subscriptionsVM.listSubsResponse) { _ in updateSubsList() }
    }
    
    func updateSubsList(){
        guard let listResponse = self.subscriptionsVM.listSubsResponse else { return }
        let listArray = listResponse.subscriptions ?? []
        self.subscriptionsList = listArray
    }
    
    func listSubsApi(){
        let input = ListSubscriptionsRequest(userId : Constants.getUserId(),
                                             page   : 0,
                                             filter : SubscriptionFilter(includeFamilyMembers        : true,
                                                                         includeExpiredSubscriptions : true,
                                                                         
                                                                         categoryId                  : "",
                                                                         familyMembers               : [],
                                                                         monthYear                   : ""),
                                             sortBy : 0)
        subscriptionsVM.listSubscriptions(input: input, showLoader: false)
    }
    
    func clickOnUpgrade()
    {
        AppIntentRouter.shared.pop()
        AppIntentRouter.shared.navigate(to: .pricingPlans())
    }
    
    func clickonMayBe()
    {
        AppIntentRouter.shared.pop()
    }
}

// MARK: - App Icon
struct AppIconView<Background: ShapeStyle>: View {
    
    var background: Background
    var image: String
    var imageColor: Color
    var locked: Bool = false
    var bordered: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.64)
                .fill(background)
                .frame(width: 38, height: 38)
                .overlay {
                    if bordered {
                        RoundedRectangle(cornerRadius: 10.64)
                            .stroke(
                                Color.black.opacity(0.06),
                                lineWidth: 0.5
                            )
                    }
                }
            
            Image(image)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(imageColor)
            
            if locked {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.55))
                    .frame(width: 38, height: 38)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .opacity(0.35)
        .grayscale(1)
    }
}
