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
        ScrollView{
            VStack(spacing: 0) {
                // MARK: - Gauge
                ZStack {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: 0.5)
                            .stroke(
                                themeManager.textPrimaryLight6_dark62.opacity(0.1),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(180))
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(animatedProgress * 0.5))
                            .stroke(
                                Color.dangerDarkFF5A7A,
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(180))
                            .shadow(color: Color.dangerDarkFF5A7A.opacity(0.6), radius: 15, x: 0, y: 0)
                        
                        Circle()
                            .fill(Color.dangerDarkFF5A7A)
                            .frame(width: 22, height: 22)
                            .offset(x: 130)
                            .rotationEffect(.degrees(180 + (animatedProgress * 180)))
                            .shadow(color: Color.dangerDarkFF5A7A.opacity(0.6), radius: 8, x: 0, y: 0)
                    }
                    .frame(width: 260, height: 260)
                    .offset(y: 50)
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 0) {
                            Text("\(commonVM.userInfoResponse?.planSubscriptionLimit ?? 0)")
                                .font(.geistExtraBold(48))
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
                            .tracking(2)
                            .foregroundColor(
                                themeManager.textPrimaryLight6_dark62
                            )
                    }
                    .padding(.bottom, 20)
                }
                .frame(width: 220, height: 180)
                .padding(.top, 120)
                
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
                    //                AppIconView(
                    //                    background: .black,
                    //                    image: "limit1",
                    //                    imageColor: .red,
                    //                    locked: false
                    //                )
                    //
                    //                AppIconView(
                    //                    background: Color.green,
                    //                    image: "limit2",
                    //                    imageColor: .black,
                    //                    locked: false
                    //                )
                    //
                    //                AppIconView(
                    //                    background: .black,
                    //                    image: "limit3",
                    //                    imageColor: Color.white,
                    //                    locked: false
                    //                )
                    //
                    //                AppIconView(
                    //                    background: .white,
                    //                    image: "limit4",
                    //                    imageColor: .purple,
                    //                    locked: false,
                    //                    bordered: false
                    //                )
                    //
                    //                AppIconView(
                    //                    background: LinearGradient(
                    //                        colors: [
                    //                            Color(red: 250/255, green: 88/255, blue: 106/255),
                    //                            Color(red: 250/255, green: 36/255, blue: 60/255)
                    //                        ],
                    //                        startPoint: .topLeading,
                    //                        endPoint: .bottomTrailing
                    //                    ),
                    //                    image: "limit5",
                    //                    imageColor: .white,
                    //                    locked: true
                    //                )
                    
                    // Unlimited
                    //                ZStack {
                    //                    RoundedRectangle(cornerRadius: 10)
                    //                        .fill(themeManager.white_white4)
                    //                        .frame(width: 38, height: 38)
                    //                        .overlay {
                    //                            RoundedRectangle(cornerRadius: 10)
                    //                                .stroke(
                    //                                    themeManager.black_white.opacity(0.08),
                    //                                    lineWidth: 1
                    //                                )
                    //                        }
                    //
                    //                    Text("+∞")
                    //                        .font(.geistBold(11))
                    //                        .foregroundColor(
                    //                            themeManager.black_white.opacity(0.6)
                    //                        )
                    //                }
                    
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
                
                Spacer()
                
                // MARK: - Upgrade and later Button
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
                .padding(.bottom, 120)
                
                //            VStack(spacing: 0) {
                //                VStack(spacing: 10) {
                ////                    Button {
                ////                        clickOnUpgrade()
                ////                    } label: {
                ////                        Text("Upgrade now")
                ////                            .font(.geistBold(15))
                ////                            .foregroundStyle(Color.white)
                ////                            .frame(maxWidth: .infinity)
                ////                            .frame(height: 54)
                ////                            .background {
                ////                                themeManager.accentGradient
                ////                            }
                ////                            .cornerRadius(12)
                ////                            .shadow(
                ////                                color: themeManager.selectedAccent.senColor.opacity(0.55),
                ////                                radius: 12,
                ////                                y: 8
                ////                            )
                ////                    }
                ////                    .buttonStyle(.plain)
                ////                    .padding(.vertical, 12)
                //
                //                    GradientBgButton(
                //                        title       : "Upgrade now",
                //                        isSolid     : true,
                //                        showChevron : false
                //                    ) {
                //                        clickOnUpgrade()
                //                    }
                //
                //                    Button {
                //                        clickonMayBe()
                //                    } label: {
                //                        Text("Maybe later")
                //                            .font(.geistRegular(13))
                //                            .foregroundColor(
                //                                themeManager.textPrimaryLight6_dark62
                //                            )
                //                            .padding(.vertical, 4)
                //                    }
                //                    .buttonStyle(.plain)
                //                }
                //                .padding(.horizontal,20)
                //                Spacer()
                //            }
                //            .frame(height: 250, alignment: .bottomLeading)
                //            .ignoresSafeArea(edges: .bottom)
                //            .padding(.horizontal, 24)
                //            .padding(.top, 24)
                //            .padding(.bottom, 40)
                //            .background {
                //                RoundedRectangle(
                //                    cornerRadius: 28,
                //                    style: .continuous
                //                )
                //                .fill(themeManager.white_white4.opacity(0.96))
                //                .background(.ultraThinMaterial)
                //                .clipShape(
                //                    RoundedRectangle(
                //                        cornerRadius: 28,
                //                        style: .continuous
                //                    )
                //                )
                //                .shadow(
                //                    color: themeManager.black_white.opacity(0.06),
                //                    radius: 60,
                //                    y: -20
                //                )
                //            }
                
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
        .applyAppBackground()
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
