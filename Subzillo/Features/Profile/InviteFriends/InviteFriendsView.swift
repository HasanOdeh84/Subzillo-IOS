//
//  InviteFriendsView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 02/02/26.
//

import SwiftUI

struct InviteFriendsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel      = InviteFriendsViewModel()
    @EnvironmentObject private var commonVM : CommonAPIViewModel
    @State private var referralLink         : String = ""
    var uLink                               : String? = ""
    @EnvironmentObject var themeManager     : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    var progress                            : CGFloat = 0.5
    var currentValue                        : Int = 1
    var totalValue                          : Int = 2
    @State private var circleprogress       : Double = 0.0
    
    private var attributedDescription: AttributedString {
        var result = AttributedString("Next: ")
        result.foregroundColor = themeManager.textPrimaryLight6_dark62
        var streaming = AttributedString("Add \(viewModel.rewardsResponse?.nextReward?.subscriptionReward ?? 0) subscriptions") //subscriptionReward
        streaming.font = .geistSemiBold(11)
        streaming.foregroundColor = .textPrimary0E101AF4F1FB
        result += streaming
        return result
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            HStack(alignment: .center, spacing: 12) {
                
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    
                    Text("Earn together")
                        .font(.jetBrainsRegular(11))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.6)
                        )
                        .tracking(1.5)
                        .textCase(.uppercase)
                    
                    Text("Invite friends")
                        .font(.geistBold(22))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                        )
                        .tracking(-0.8)
                        .lineSpacing(2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                
                HStack(spacing: 20) {
                    
                    ZStack {
                        ZStack {
                            ArcShape(startAngle: .degrees(-210),
                                     endAngle: .degrees(30))
                            .stroke(
                                themeManager.black_white.opacity(0.05),
                                style: StrokeStyle(
                                    lineWidth: 9,
                                    lineCap: .round
                                )
                            )
                            
                            ArcShape(
                                startAngle: .degrees(-210),
                                endAngle: .degrees(30)
                            )
                            .trim(from: 0, to: circleprogress)
                            .stroke(
//                                themeManager.accentGradient,
                                themeManager.gradient(style: .horizontal),
                                style: StrokeStyle(
                                    lineWidth: 9,
                                    lineCap: .round
                                )
                            )
                            .shadow(
                                color: themeManager.selectedAccent.senColor.opacity(0.45),
                                radius: 6
                            )
                        }
                        .frame(width: 150, height: 150)
                        .offset(y: -46)
                        
                        VStack(spacing: 2) {
                            
                            Text("\(viewModel.rewardsResponse?.nextReward?.creditsNeeded ?? 0)/\(viewModel.rewardsResponse?.nextReward?.creditsRequired ?? 0)")
                                .font(.geistExtraBold(32))
                                .foregroundStyle(
                                    themeManager.black_white
                                )
                            
                            Text("REFERRALS")
                                .font(.jetBrainsRegular(11))
                                .tracking(1)
                                .foregroundStyle(
                                    themeManager.black_white.opacity(0.4)
                                )
                        }
                        .offset(y: 12)
                    }
                    .frame(width: 150, height: 150)
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("\((viewModel.rewardsResponse?.nextReward?.creditsRequired ?? 0)-(viewModel.rewardsResponse?.nextReward?.creditsNeeded ?? 0)) more to next reward")
                            .font(.geistBold(16))
                            .tracking(-0.4)
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                            )
                            .lineLimit(2)
//                        
                        Text(attributedDescription)
                            .font(.geistRegular(12))
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                            .padding(.top, 6)
                        
//                        VStack(alignment: .leading, spacing: 0) {
//                            
//                            GeometryReader { geo in
//                                
//                                ZStack(alignment: .leading) {
//                                    
//                                    Capsule()
//                                        .fill(
//                                            themeManager.black_white.opacity(0.08)
//                                        )
//                                    
//                                    Capsule()
//                                        .fill(
//                                            themeManager.accentGradient
//                                        )
//                                        .frame(
//                                            width: geo.size.width * progress
//                                        )
//                                }
//                            }
//                            .frame(height: 5)
//                            
//                            Text("1/2 referrals")
//                                .font(.jetBrainsRegular(10))
//                                .foregroundStyle(
//                                    Color.textPrimary0E101AF4F1FB
//                                        .opacity(0.6)
//                                )
//                                .padding(.top, 4)
//                        }
//                        .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(themeManager.white_white4)
                        .overlay(alignment: .top) {
                            
                            RadialGradient(
                                colors: [
                                    themeManager.selectedAccent.primaryColor
                                        .opacity(0.16),
                                    .clear
                                ],
                                center: .top,
                                startRadius: 0,
                                endRadius: 300
                            )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 28)
                        )
                }
                .overlay {
                    
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.14),
                            lineWidth: 1
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: Invite Section
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("YOUR INVITE LINK")
                            .font(.jetBrainsRegular(11))
                            .tracking(1.5)
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                        
                        HStack(spacing: 8) {
                            
                            HStack {
                                
                                TextField("", text: $referralLink)
                                    .font(.jetBrainsRegular(13))
                                    .foregroundColor(Color.textPrimary0E101AF4F1FB
                                        .opacity(0.6))
                                    .disabled(true)
                                
                            }
                            .frame(height: 50)
                            .padding(.horizontal, 14)
                            .background(
                                themeManager.white_white4
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                            .overlay {
                                
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.08),
                                        lineWidth: 1
                                    )
                            }
                            
                            Button {
                                if !referralLink.isEmpty {
                                    shareLink(referralLink)
                                } else {
                                    ToastManager.shared.showToast(message: "No referral link available", style: .info)
                                }
                            } label: {
                                
                                HStack(spacing: 6) {
                                    
                                    Text("Share")
                                        .font(.geistBold(13))
                                }
                                .foregroundStyle(.white)
                                .frame(width:73, height: 50)
                                .padding(.horizontal, 18)
                                .background(
                                    themeManager.accentGradient
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 14)
                                )
                                .shadow(
                                    color: themeManager.selectedAccent.senColor.opacity(0.55),
                                    radius: 20,
                                    y: 6
                                )
                            }
                        }
                    }
                    
                    //MARK: - How it works
                    ReferralHowItWorksView()
                    
                    // MARK: Rewards Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("REWARDS")
                            .font(.jetBrainsRegular(11))
                            .tracking(1.5)
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                        if viewModel.rewards.isEmpty {
                            HStack{
                                Spacer()
                                VStack{
                                    Spacer()
                                    LottieView(name: "no_product")
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.clear)
                                    
                                    Text("No rewards yet. Invite your friends and start earning today!")
                                        .padding(30)
                                        .foregroundStyle(Color.textPrimary0E101AF4F1FB)
                                        .multilineTextAlignment(.center)
                                        .font(.geistSemiBold(16))
                                    Spacer()
                                }
                                Spacer()
                            }
                        }else{
                            ForEach(viewModel.rewards) { reward in
                                RewardItemView(reward: reward) {
                                    if let index = viewModel.rewards.firstIndex(where: { $0.rewardConfigId == reward.rewardConfigId }) {
                                        let hasUnredeemedPrevious = viewModel.rewards[..<index].contains { prevReward in
                                            (prevReward.eligible ?? false) && !(prevReward.redeemed ?? false)
                                        }
                                        if hasUnredeemedPrevious {
                                            ToastManager.shared.showToast(message: "Please redeem previous rewards first", style: .info)
                                            return
                                        }
                                    }
                                    viewModel.redeemReward(input: RedeemRewardRequest(userId          : Constants.getUserId(),
                                                                                      rewardConfigId  : reward.rewardConfigId ?? ""))
                                }
                            }
                        }
                    }
                    .padding(.bottom, 140)
                }
                .padding(.horizontal, 20)
            }
        }
        .applyAppBackground()
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            rewardsApi()
            //            if let link = uLink, !link.isEmpty {
            //                referralLink = link
            //            } else {
            //                referralLink = "https://subzillo.com"
            //            }
            commonVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
            
            withAnimation(.easeOut(duration: 1.2).delay(0.1)) {
                circleprogress = 0.5
            }
            
        }
        .onChange(of: viewModel.redeemSucess) { _ in
            if viewModel.redeemSucess{
                rewardsApi()
            }
        }
        .onChange(of: commonVM.userInfoResponse) { _ in
            if let url = commonVM.userInfoResponse?.referralLink{
                referralLink = url
            }else{
                referralLink = "https://subzillo.com"
            }
        }
    }
    
    //MARK: - User defined methods
    private func shareLink(_ link: String) {
        
        var username = ""
        if let fullName = commonVM.userInfoResponse?.fullName{
            username = fullName
        }
        
        let message = """
            Hey! \(username == "" ? "" : "It’s \(username)")😊
            I’m using Subzillo to manage subscriptions easily.
            Check it out here: \(link)
            """
        
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        // For iPad compatibility
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func rewardsApi(){
        viewModel.rewards(input: RewardsRequest(userId: Constants.getUserId()))
    }
}

// MARK: - Subviews
struct RewardItemViewold: View {
    let reward      : RewardsData
    var onRedeem    : () -> Void
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left Icon
            Image("gift")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24, alignment: .top)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Add \(reward.subscriptionReward ?? 0) subscription")
                    .font(.appSemiBold(14))
                    .foregroundColor(Color.neutralMain700)
                
                (Text("Unlock at ") + Text("\(reward.creditsRequired ?? 0)").font(.appSemiBold(14)) + Text(" referral subscriptions"))
                    .font(.appRegular(14))
                    .foregroundColor(Color.neutralMain700)
                
                if reward.eligible ?? false || reward.redeemed ?? false{
                    HStack(spacing: 4) {
                        Image("checkmark_green")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        
                        Text("Unlocked")
                            .font(.appBold(12))
                            .foregroundColor(Color.greenClr)
                    }
                    .padding(.top, 2)
                }
            }
            
            Spacer()
            
            VStack{
                Spacer()
                if reward.eligible ?? false || reward.redeemed ?? false{
                    if reward.redeemed ?? false{
                        Text("Redeemed")
                            .font(.appSemiBold(14))
                            .foregroundColor(Color.gray2)
                    } else{
                        Button(action: onRedeem) {
                            Text("Redeem")
                                .font(.jetBrainsBold(10))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 4)
                                .background(
                                    themeManager.accentGradient
                                )
                                .cornerRadius(7)
                        }
                    }
                } else {
                    HStack(spacing: 4) {
                        Image("lock_gray")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Locked")
                            .font(.appBold(12))
                            .foregroundColor(Color.gray2)
                    }
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }
}
struct RewardItemView: View {
    
    let reward      : RewardsData
    var onRedeem    : () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            // MARK: - Icon
            
            ZStack {
                
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        (reward.redeemed ?? false) == true ? themeManager.accentColor : themeManager.black_white.opacity(0.05)
                    )
                    .frame(width: 40, height: 40)
                
                Image(
                    (reward.redeemed ?? false) || colorScheme == .dark
                    ? "giftwhite"
                    : "gift"
                )
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18, alignment: .top)
                
                
            }
            
            // MARK: - Content
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text("Add \(reward.subscriptionReward ?? 0) subscriptions")
                    .font(.geistBold(14))
                    .tracking(-0.2)
                    .foregroundStyle(
                        Color.textPrimary0E101AF4F1FB
                    )
                
//                (Text("Unlock at ") + Text("\(reward.creditsRequired ?? 0)").font(.jetBrainsRegular(12)) + Text(" referral subscriptions"))
                Text("\(reward.subscriptionReward ?? 0) more free sub slots . \(reward.creditsRequired ?? 0) referrals")
                    .font(.jetBrainsRegular(11))
                    .foregroundStyle(
                        themeManager.textPrimaryLight6_dark62
                    )
            }
            
            Spacer(minLength: 0)
            
            // MARK: - Lock
            
            HStack(spacing: 5) {
                
                if reward.eligible ?? false || reward.redeemed ?? false{
                    if reward.redeemed ?? false{
                        HStack(spacing: 5) {
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("EARNED")
                                .font(.jetBrainsMedium(10))
                                .tracking(1)
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        .background(
                            themeManager.accentGradient
                        )
                        .clipShape(
                            Capsule()
                        )
                        .shadow(
                            color: themeManager.selectedAccent.senColor.opacity(0.55),
                            radius: 12,
                            y: 4
                        )
                        
                    } else{
                        Button(action: onRedeem) {
                            Text("Redeem")
                                .font(.jetBrainsRegular(16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 11)
                                .background(
                                    themeManager.accentGradient
                                )
                                .cornerRadius(7)
                        }
                        
                    }
                } else {
                    Image("lock")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.6)
                        )
                    
                    Text("Locked")
                        .font(.jetBrainsRegular(11))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.6)
                        )
                }
                
                
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            Group {
                if (reward.redeemed ?? false) == true {
                    themeManager.accentGradient.opacity(0.133)
                } else {
                    themeManager.white_white4
                }
            }
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
        .overlay {
            
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    (reward.redeemed ?? false) == true ? themeManager.selectedAccent.senColor : Color.textPrimary0E101AF4F1FB.opacity(0.08),
                    lineWidth: 1
                )
        }
    }
}
struct ReferralHowItWorksView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    let steps: [String] = [
        "Share your link with friends",
        "They sign up and add a subscription",
        "You both earn rewards automatically"
    ]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("How it works")
                .font(.geistBold(13))
                .foregroundStyle(
                    Color.textPrimary0E101AF4F1FB
                )
                .padding(.bottom, 12)
            
            VStack(alignment: .leading, spacing: 10) {
                
                ForEach(Array(steps.enumerated()), id: \.offset) { index, title in
                    
                    HStack(alignment: .top, spacing: 10) {
                        
                        ZStack {
                            
                            Circle()
                                .fill(
                                    themeManager.accentGradient
                                )
                                .frame(width: 22, height: 22)
                                .shadow(
                                    color: themeManager.selectedAccent.senColor.opacity(0.55),
                                    radius: 10
                                )
                            
                            Text("\(index + 1)")
                                .font(.geistBold(11))
                                .foregroundStyle(.white)
                        }
                        
                        Text(title)
                            .font(.geistRegular(13))
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                            )
                            .lineSpacing(4)
                            .padding(.top, 2)
                        
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background {
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            themeManager.selectedAccent.primaryColor.opacity(0.13),
                            themeManager.selectedAccent.lastColor.opacity(0.13)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    themeManager.selectedAccent.primaryColor.opacity(0.2),
                    lineWidth: 1
                )
        }
    }
}
// MARK: - Arc Shape
struct ArcShape: Shape {
    
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        
        let radius = min(rect.width, rect.height) / 2
        
        let center = CGPoint(
            x: rect.midX,
            y: rect.maxY
        )
        
        var path = Path()
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        return path
    }
}
