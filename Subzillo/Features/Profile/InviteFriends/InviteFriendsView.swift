//
//  InviteFriendsView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 02/02/26.
//

import SwiftUI

struct RewardPlanInfo: Identifiable {
    let id = UUID()
    let title: String
    let requirementText: String
    let isCompleted: Bool
    let note: String
}

struct RewardPlan: Identifiable {
    let id = UUID()
    let title: String
    let features: [String]
}

struct InviteFriendsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var referralLink: String = ""
    var uLink : String? = ""
    
    // Data list representing the sections in the rewards card
    let rewardPlans = [
        RewardPlan(title: "Free Plan", features: [
            "Basic renewal reminders",
            "Track up to 5 subscriptions",
            "Simple expense tracking"
        ]),
        RewardPlan(title: "Premium Plan", features: [
            "Basic renewal reminders",
            "Track up to 5 subscriptions",
            "Simple expense tracking"
        ]),
        RewardPlan(title: "Family", features: [
            "Basic renewal reminders",
            "Track up to 5 subscriptions",
            "Simple expense tracking"
        ])
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: Title
                    Text("Invite friends")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    // MARK: SubTitle
                    Text("in Ut laoreet porta at, nec facilisi")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutral500)
                }
                Spacer()
            }
            .padding(.top, 50)
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
                            
                            CustomButton(title: "Share",
                                         background: Color.navyBlueCTA700,
                                         textColor: .white,
                                         width: 100,
                                         height: 48,
                                         action: {
                                if !referralLink.isEmpty {
                                    shareLink(referralLink)
                                } else {
                                    ToastManager.shared.showToast(message: "No referral link available", style: .info)
                                }
                            })
                            .frame(width: 100)
                        }
                    }
                    
                    // MARK: Rewards Card
                    VStack(alignment: .leading, spacing: 0) {
                        // Card Header
                        Text("Your Rewards")
                            .font(.appSemiBold(24))
                            .foregroundColor(Color.neutralMain700)
                            .padding(16)
                        
                        Divider()
                            .background(Color.neutral300Border)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(rewardPlans.enumerated()), id: \.offset) { index, plan in
                                RewardPlanRow(plan: plan)
                                
                                if index < rewardPlans.count - 1 {
                                    VStack(spacing: 5){
                                        Divider()
                                            .background(Color.neutral300Border)
                                            .padding(.horizontal, 1)
                                        Divider()
                                            .background(Color.neutral300Border)
                                            .padding(.horizontal, 1)
                                    }
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                
                RewardCardView(title: "Your Rewards") {
                    RewardPlanRow1(info: RewardPlanInfo(
                        title: "Free Plan",
                        requirementText: "Add 2 more Subscriptions",
                        isCompleted: false,
                        note: "Note : Reward will unlock after register of 3 members which you shared"
                    ))
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 24)
                
                RewardCardView(title: "Your Rewards", claimAction: {
                    // Handle claim action
                }) {
                    RewardPlanRow1(info: RewardPlanInfo(
                        title: "Free Plan",
                        requirementText: "Add 2 more Subscriptions",
                        isCompleted: true,
                        note: "Note : Reward will unlock after register of 3 members which you shared"
                    ))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.neutralBg100)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let link = uLink, !link.isEmpty {
                referralLink = link
            } else {
                referralLink = "https://subzillo.com" // Default fallback or empty
            }
        }
    }
    
    private func shareLink(_ link: String) {
        let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
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
}

// MARK: - Subviews
struct RewardPlanRow: View {
    let plan: RewardPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(plan.title)
                .font(.appRegular(14))
                .foregroundColor(Color.secondaryNavyBlue800)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(plan.features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image("checkmark_circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text(feature)
                            .font(.appRegular(14))
                            .foregroundColor(Color.neutralMain700)
                    }
                }
            }
        }
        .padding(24)
    }
}

struct RewardPlanRow1: View {
    let info: RewardPlanInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(info.title)
                .font(.appRegular(14))
                .foregroundColor(Color.secondaryNavyBlue800)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: info.isCompleted ? "checkmark.circle.fill" : "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(info.isCompleted ? Color.primaryBlue800 : Color.neutral400)
                    
                    Text(info.requirementText)
                        .font(.appRegular(14))
                        .foregroundColor(Color.neutralMain700)
                }
                
                Text(info.note)
                    .font(.appRegular(12))
                    .foregroundColor(Color.neutralMain700)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
    }
}

struct RewardCardView<Content: View>: View {
    let title: String
    var claimAction: (() -> Void)? = nil
    let content: Content
    
    init(title: String, claimAction: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.claimAction = claimAction
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.appSemiBold(24))
                .foregroundColor(Color.neutralMain700)
                .padding(16)
            
            Divider()
                .background(Color.neutral300Border)
            
            content
            
            if let action = claimAction {
                Divider()
                    .background(Color.neutral300Border)
                
                Button(action: action) {
                    Text("Claim Your Reward")
                        .font(.appSemiBold(18))
                        .foregroundColor(Color.green)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color.success)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: 1)
                        )
                }
                .padding(16)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
    }
}


