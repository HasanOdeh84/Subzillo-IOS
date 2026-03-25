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
    @StateObject private var viewModel  = InviteFriendsViewModel()
    @State private var referralLink     : String = ""
    var uLink                           : String? = ""
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            HStack(alignment: .center, spacing: 8) {
                // MARK: - back
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                Text("Invite friends")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                
                Spacer()
            }
            .padding(.top, 70)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // MARK: Invite Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Invite your friends")
                            .font(.appRegular(14))
                            .foregroundColor(Color.graphText)
                        
                        HStack(spacing: 12) {
                            TextField("", text: $referralLink)
                                .font(.appRegular(16))
                                .foregroundColor(Color.blueMain700)
                                .padding(.horizontal, 16)
                                .frame(height: 48)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.neutral2200, lineWidth: 1)
                                )
                                .disabled(true)
                            
                            CustomButton(title      : "Share",
                                         background : Color.navyBlueCTA700,
                                         textColor  : .white,
                                         width      : 100,
                                         height     : 48,
                                         isShare    : true,
                                         action     : {
                                if !referralLink.isEmpty {
                                    shareLink(referralLink)
                                } else {
                                    ToastManager.shared.showToast(message: "No referral link available", style: .info)
                                }
                            })
                            .frame(width: 100)
                            
//                            ShareLink(item: referralLink, subject: Text("Check out this amazing app!"), message: Text("Hey, I've been using this app and thought you'd like it. Use this link to download it.")) {
//                                Text("Share")
//                                    .font(.appSemiBold(16))
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 13)
//                                    .padding(.vertical, 11)
//                                    .background(
//                                        LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700],
//                                                       startPoint: .top,
//                                                       endPoint: .bottom)
//                                    )
//                                    .cornerRadius(7)
//                                    .frame(width: 100, height: 48)
//                            }
                        }
                    }
                    
                    //MARK: - How it works
                    GradienCustomeView(title            : "How it work?",
                                       subTitle         : "",
                                       isImage          : false,
                                       isInviteFriends  : true)
                    
                    // MARK: Rewards Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Rewards")
                            .font(.appSemiBold(24))
                            .foregroundColor(Color.neutralMain700)
                        if viewModel.rewards.isEmpty {
                            HStack{
                                Spacer()
                                Text("No rewards available")
                                    .padding(30)
                                    .foregroundStyle(Color.gray)
                                    .font(.appRegular(16))
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
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.neutralBg100)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            rewardsApi()
            if let link = uLink, !link.isEmpty {
                referralLink = link
            } else {
                referralLink = "https://subzillo.com"
            }
        }
        .onChange(of: viewModel.redeemSucess) { _ in
            if viewModel.redeemSucess{
                rewardsApi()
            }
        }
    }
    
    //MARK: - User defined methods
    private func shareLink(_ link: String) {
        
        var username = ""
        if let fullName = SessionManager.shared.loginData?.fullName{
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
struct RewardItemView: View {
    let reward      : RewardsData
    var onRedeem    : () -> Void
    
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
                                .font(.appSemiBold(16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 11)
                                .background(
                                    LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700],
                                                   startPoint: .top,
                                                   endPoint: .bottom)
                                )
                                .cornerRadius(7)
                        }
                    }
                }
                else {
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


