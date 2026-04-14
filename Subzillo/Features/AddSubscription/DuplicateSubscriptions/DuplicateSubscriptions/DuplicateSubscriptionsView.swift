//
//  DuplicateSubscriptionsView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 19/11/25.
//

import SwiftUI
import UIKit

var modifiedDuplicateDataInfo  : ModifiedDuplicateDataInfo?
var duplicateDataCount         : Int?
var isFromAdd                  : Bool?

// MARK: - DuplicateSubscriptionsView
struct DuplicateSubscriptionsView: View {

    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State var duplicateSubsList    : [DuplicateDataInfo]
    @StateObject var dupSubscriptionVM = DuplicateSubscriptionsViewModel()
    @State var fromFamily           : Bool = false
    @State var isFromEmail          : Bool = false

    /// Index of the duplicate we are currently resolving (0-based)
    @State private var currentIndex : Int = 0
    /// Which existing subscription page is visible in the pager
    @State private var existingPage : Int = 0
    /// Tracks whether an API call is in flight for the current card
    @State private var isProcessing : Bool = false

    // MARK: - Computed helpers
    private var totalCount: Int   { duplicateSubsList.count }
    private var currentItem: DuplicateDataInfo? {
        guard currentIndex < totalCount else { return nil }
        return duplicateSubsList[currentIndex]
    }
    private var existingList: [SubscriptionInfo] {
        currentItem?.existingSubscriptions ?? []
    }
    private var newSub: SubscriptionInfo? {
        currentItem?.newSubscriptions?.first
    }

    // MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Header
            headerView

            if let item = currentItem {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Progress label
                        progressLabel
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 12)

                        // New Subscription section
                        sectionLabel("New Subscription", color: Color.linearGradient3Start)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        if let sub = newSub {
                            DupSubCard(sub: sub, isNew: true, statusText: nil)
                                .padding(.horizontal, 20)
                        }

                        // VS badge
                        vsBadge
                            .padding(.vertical, 12)

                        // Existing Subscription section
                        sectionLabel("Existing Subscription", color: Color.blueMain700)
                            .padding(.horizontal, 20)
//                            .padding(.bottom, 4)

                        if existingList.isEmpty {
                            // No existing – shouldn't happen, but guard gracefully
                            EmptyView()
                        } else if existingList.count == 1 {
                            DupSubCard(sub: existingList[0], isNew: false, statusText: existingList[0].status)
                                .padding(.horizontal, 20)
                        } else {
                            // Paged existing subscriptions
                            existingPager
                        }

                        Spacer(minLength: 16)
                        
                        actionButtons(for: item)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                            .padding(.top, 8)
                    }
                }

                // MARK: - Action buttons (pinned at bottom)
//                actionButtons(for: item)
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 24)
//                    .padding(.top, 8)

            } else {
                // All duplicates handled – show nothing while navigation fires
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
        .background(Color.neutralBg100)
        .onChange(of: duplicateSubsList.count) { _ in
            existingPage = 0
        }
        .onChange(of: dupSubscriptionVM.subscriptioIds) { _ in
            isProcessing = false
            advanceOrFinish()
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image("back_gray")
                    .frame(width: 24, height: 24)
            }
            Text("Possible Duplicated Found")
                .font(.appRegular(22))
                .foregroundColor(Color.neutralMain700)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Progress label  "Checking New Subscription **1** of 5"
    private var progressLabel: some View {
        HStack(spacing: 0) {
            Text("Checking New Subscription ")
                .font(.appRegular(16))
                .foregroundColor(Color.neutralMain700)
            Text("\(currentIndex + 1)")
                .font(.appSemiBold(16))
                .foregroundColor(Color.navyBlueCTA700)
            Text(" of ")
                .font(.appRegular(16))
                .foregroundColor(Color.neutralMain700)
            Text("\(totalCount)")
                .font(.appSemiBold(16))
                .foregroundColor(Color.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Section label
    private func sectionLabel(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.appRegular(16))
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - VS badge
    private var vsBadge: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.navyBlueCTA700, lineWidth: 1)
                .frame(width: 40, height: 40)
            Text("VS")
                .font(.appSemiBold(16))
                .foregroundColor(Color.navyBlueCTA700)
        }
    }

    // MARK: - Existing pager (TabView + page dots)
    private var existingPager: some View {
        VStack(spacing: 8) {
            TabView(selection: $existingPage) {
                ForEach(existingList.indices, id: \.self) { idx in
                    DupSubCard(sub: existingList[idx], isNew: false, statusText: existingList[idx].status)
                        .padding(.horizontal, 20)
                        .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 140)

            // Page dots
            HStack(spacing: 6) {
                ForEach(existingList.indices, id: \.self) { idx in
                    Capsule()
                        .fill(idx == existingPage ? Color.blueMain700 : Color.neutral300Border)
                        .frame(width: idx == existingPage ? 20 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.25), value: existingPage)
                }
            }
        }
    }

    // MARK: - Action buttons
    @ViewBuilder
    private func actionButtons(for item: DuplicateDataInfo) -> some View {
        VStack(spacing: 12) {
            // 1. Save new subscription as existing (filled blue)
            CustomButton(
                title: "Save new subscription as existing",
                height: 52, 
                buttonImage: "settingsicon",
                action: {
                    print("Save as existing pressed")
                    guard !isProcessing else { return }
                    saveAsExisting(item: item)
                }
            )

            // 2. Save as Separate Subscription (gradient-border)
            GradientBorderButton(
                title: "Save as Separate Subscription",
                isBtn: true,
                buttonImage: "keepIcon",
                action: {
                    guard !isProcessing else { return }
                    saveAsSeparate(item: item)
                },
                backgroundColor: .whiteBlack,
                buttonHeight: 52
            )

            // 3. Skip For Now (text link)
            Button(action: skipForNow) {
                Text("Skip For Now")
                    .font(.appBold(16))
                    .foregroundColor(Color.navyBlueCTA700)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
        }
    }

    // MARK: - Button logic

    /// action = 1, existingSubscription = selected existing's id  →  merge
    private func saveAsExisting(item: DuplicateDataInfo) {
        guard var newItem = item.newSubscriptions?.first else { return }
        let selectedExisting = existingList.indices.contains(existingPage)
            ? existingList[existingPage]
            : existingList.first

        guard let existing = selectedExisting, let existingId = existing.id else {
            ToastManager.shared.showToast(message: "No existing subscription selected", style: .error)
            return
        }

        newItem = enriched(newItem, from: existing)
        if isFromAdd == true { newItem.id = "" }

        isProcessing = true
        makeApiCall(action: 1, existingSubscription: existingId, newSubscriptions: [newItem])
    }

    /// action = 2, existingSubscription = ""  →  keep as separate
    private func saveAsSeparate(item: DuplicateDataInfo) {
        guard var newItem = item.newSubscriptions?.first else { return }
        let referenceOld = existingList.first
        newItem = enriched(newItem, from: referenceOld)
        if isFromAdd == true { newItem.id = "" }

        isProcessing = true
        makeApiCall(action: 2, existingSubscription: "", newSubscriptions: [newItem])
    }

    /// Skip with no API call — just move to next
    private func skipForNow() {
        advanceOrFinish()
    }

    /// Move to next duplicate, or navigate away when all done
    private func advanceOrFinish() {
        if currentIndex + 1 < totalCount {
            withAnimation {
                currentIndex += 1
                existingPage = 0
            }
        } else {
            navigateAway()
        }
    }

    private func navigateAway() {
        if fromFamily {
            AppIntentRouter.shared.pop(count: 2)
        } else if isFromEmail {
            NotificationCenter.default.post(name: .refreshExtractedSubs, object: nil)
            dismiss()
        } else {
            AppIntentRouter.shared.navigate(to: .subscriptionsListView())
        }
    }

    // MARK: - API call
    private func makeApiCall(action: Int, existingSubscription: String, newSubscriptions: [SubscriptionInfo]) {
        let updatedSubscriptions = newSubscriptions.map { sub -> SubscriptionInfo in
            var updatedSub = sub
            updatedSub.serviceLogo = sub.serviceLogo?.fileNameOnly
            if isFromEmail {
                updatedSub.sourceReference = sub.sourceReference
            }
            return updatedSub
        }
        let input = ResolveDuplicateSubscriptionRequest(
            userId              : Constants.getUserId(),
            action              : action,
            existingSubscription: existingSubscription,
            newSubscriptions    : updatedSubscriptions
        )
        dupSubscriptionVM.resolveDuplicateSubscription(input: input)
    }

    /// Fills backend-only fields that the server populates only on existing subscriptions.
    private func enriched(_ new: SubscriptionInfo, from old: SubscriptionInfo?) -> SubscriptionInfo {
        var sub = new
        sub.source            = new.source            ?? old?.source
        sub.sourceReference   = new.sourceReference   ?? old?.sourceReference
        sub.status            = new.status            ?? old?.status
        sub.paymentMethodName = new.paymentMethodName ?? old?.paymentMethodName
        sub.categoryName      = new.categoryName      ?? old?.categoryName
        sub.cardNumber        = new.cardNumber        ?? old?.cardNumber
        sub.cardName          = new.cardName          ?? old?.cardName
        return sub
    }
}

// MARK: - DupSubCard
/// Single subscription card shown in the duplicate resolution screen.
struct DupSubCard: View {

    var sub        : SubscriptionInfo
    var isNew      : Bool
    var statusText : String?   // e.g. "Active", "expired" — shown for existing subs

    private var fullTitle: String {
        [sub.subscriptionType, "\(sub.currencySymbol ?? Constants.shared.currencySymbol)\(sub.amount ?? 0.0)", sub.billingCycle]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " • ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Row: logo + name + status badge
            HStack(spacing: 10) {
                AvatarView(
                    serviceName : sub.serviceName ?? "",
                    serviceLogo : sub.serviceLogo,
                    size        : 40
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(sub.serviceName ?? "")
                        .font(.appMedium(16))
                        .foregroundColor(Color.neutralMain700)
//                    Text(fullTitle)
//                        .font(.appRegular(13))
//                        .foregroundColor(Color.neutral500)
                }

                Spacer()

                if !isNew, let status = statusText, !status.isEmpty {
                    HStack(spacing: 4) {
                        Text("Status :")
                            .font(.appRegular(12))
                            .foregroundColor(Color.neutral500)
                        Text(status.capitalized)
                            .font(.appRegular(12))
                            .foregroundColor(status.lowercased() == "active" ? Color.black : Color.redBadge)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            
            Text(fullTitle)
                .font(.appMedium(14))
                .foregroundColor(Color.neutralMain700)
                .padding(.horizontal, 16)
                .padding(.top, 5)

            Divider()
                .overlay(Color.neutral300Border)
//                .padding(.horizontal, 16)
                .padding(.top, 10)

            // Next charge row
            HStack(spacing: 6) {
                Text("Next charge:")
                    .font(.appRegular(12))
                    .foregroundColor(Color.neutral500)

                if isNew, let date = sub.nextPaymentDate, !date.isEmpty {
                    Text(Constants.shared.formatDate(date))
                        .font(.appRegular(12))
                        .foregroundColor(Color.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange1)
                        .cornerRadius(4)
                } else {
//                    Text(sub.nextPaymentDate ?? "—")
                    Text(Constants.shared.formatDate(sub.nextPaymentDate ?? "—"))
                        .font(.appRegular(12))
                        .foregroundColor(Color.neutral500)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.whiteNeutralCardBG)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
    }
}

// MARK: - Colour helper
private extension Color {
    /// Convenience: pull the first stop colour of linearGradient3 as a plain Color
    static var linearGradient3Start: Color { Color.amethystmain700 }
}
