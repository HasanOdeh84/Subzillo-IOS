import SwiftUI
import UIKit

var modifiedDuplicateDataInfo  : ModifiedDuplicateDataInfo?
var duplicateDataCount         : Int?
var isFromAdd                  : Bool?

// MARK: - DuplicateSubscriptionsView
struct DuplicateSubscriptionsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State var duplicateSubsList        : [DuplicateDataInfo]
    @StateObject var dupSubscriptionVM  = DuplicateSubscriptionsViewModel()
    @State var fromFamily               : Bool = false
    @State var isFromEmail              : Bool = false
    @EnvironmentObject var themeManager : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    // Index of the duplicate we are currently resolving (0-based)
    @State private var currentIndex     : Int = 0
    // Which existing subscription page is visible in the pager
    @State private var existingPage     : Int = 0
    // Tracks whether an API call is in flight for the current card
    @State private var isProcessing     : Bool = false
    
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
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // Info Box
                        infoBox
                        
                        // Title
                        HStack(spacing: 6) {
                            
                            titleView(title: "Which \(newSub?.serviceName ?? "service") to keep?", styledPart: "\(newSub?.serviceName ?? "service")")
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        
                        // New Subscription section
                        sectionLabel("NEW SUBSCRIPTION")
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 8)
                        
                        if let sub = newSub {
                            DupSubCard(sub: sub, isNew: true, statusText: nil)
                                .padding(.horizontal, 20)
                        }
                        
                        // Existing Subscription section
                        sectionLabel("EXISTING SUBSCRIPTION")
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 8)
                        
                        if existingList.isEmpty {
                            EmptyView()
                        } else if existingList.count == 1 {
                            DupSubCard(sub: existingList[0], isNew: false, statusText: existingList[0].status)
                                .padding(.horizontal, 20)
                        } else {
                            existingPager
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // MARK: - Action buttons (pinned at bottom)
                VStack(spacing: 16) {
                    actionButtons(for: item)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
                
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
        .applyAppBackground()
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
            
            CircleBackButton {
                AppIntentRouter.shared.pop()
            }
            
            Spacer()
            
            Text("Duplicate detected")
                .font(.geistSemiBold(16))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
            
            Spacer()
            
            HStack(spacing: 0) {
                Text("\(currentIndex + 1)")
                    .font(.geistSemiBold(22))
                    .foregroundStyle(themeManager.gradient(style: .vertical))
                Text("/\(totalCount)")
                    .font(.geistSemiBold(22))
                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
            }
            .frame(width: 40, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Info Box
    private var infoBox: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("yellow_E0A218_FFCB5C").opacity(0.2))
                    .frame(width: 32, height: 32)
                Image("bulb_new")
                    .frame(width: 16, height: 16)
            }
            
            let serviceName = newSub?.serviceName ?? "the service"
            Text("Same subscription added again. ")
                .font(.geistBold(12))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
            + Text("Our engine matched both entries to ")
                .font(.geistRegular(12))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
            + Text("\(serviceName). ")
                .font(.geistBold(12))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
            + Text("Keep one to avoid double-counting.")
                .font(.geistRegular(12))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color("yellow_E0A218_FFCB5C").opacity(0.133))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("yellow_E0A218_FFCB5C").opacity(0.333), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
    
    // MARK: - Section label
    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.jetBrainsMedium(10))
            .tracking(1.5)
            .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
            .frame(maxWidth: .infinity, alignment: .leading)
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
            HStack(spacing: 8) {
                ForEach(existingList.indices, id: \.self) { index in
                    Capsule()
                        .fill(index <= existingPage ? themeManager.accentGradient : LinearGradient(
                            colors: [Color.grayCBD5E1475569],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: index == existingPage ? 24 : 8, height: 8)
                        .animation(.spring(), value: existingPage)
                }
            }
        }
    }
    
    @ViewBuilder
    private func titleView(title: String, styledPart: String) -> some View {
        if !styledPart.isEmpty && title.contains(styledPart) {
            buildLine(line: title, styledPart: styledPart, isMask: false)
                .multilineTextAlignment(.center)
                .overlay(
                    themeManager.gradient(style: .vertical)
                        .mask(
                            buildLine(line: title, styledPart: styledPart, isMask: true)
                                .multilineTextAlignment(.center)
                        )
                )
                .foregroundColor(.clear)
        } else {
            Text(title)
                .font(.geistSemiBold(24))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                .multilineTextAlignment(.center)
        }
    }
    
    private func buildLine(line: String, styledPart: String, isMask: Bool) -> Text {
        let parts = line.components(separatedBy: styledPart)
        var result = Text("")
        for (index, part) in parts.enumerated() {
            result = result + Text(part)
                .font(.geistSemiBold(24))
                .foregroundColor(isMask ? .clear : Color("TextPrimary_ 0E101A_F4F1FB"))
            
            if index < parts.count - 1 {
                result = result + Text(styledPart)
                    .font(.jetBrainsSemiBoldItalic(24))
                    .italic()
                    .foregroundColor(isMask ? .black : .clear)
            }
        }
        return result
    }
    
    // MARK: - Action buttons
    @ViewBuilder
    private func actionButtons(for item: DuplicateDataInfo) -> some View {
        HStack(spacing: 12) {
            // Save as separate
            
            CustomBorderButton(
                title       : "Save as separate",
                background  : Color.clear,
                action      : {
                    guard !isProcessing else { return }
                    saveAsSeparate(item: item)
                }
            )
            
            // Save as existing
            GradientBgButton(
                title       : "Save as existing",
                isSolid     : true,
                showChevron : false
            ) {
                guard !isProcessing else { return }
                saveAsExisting(item: item)
            }
        }
        
        Button(action: skipForNow) {
            Text("Skip for now")
                .font(.jetBrainsBold(15))
                .tracking(1)
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
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
            AppIntentRouter.shared.pop()
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
    var statusText : String?
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager : ThemeManager
    
    private func getShortCycle(_ cycle: String?) -> String {
        guard let cycle = cycle else { return "" }
        let lower = cycle.lowercased()
        if lower.contains("year") || lower.contains("annual") { return "/yr" }
        if lower.contains("month") { return "/mo" }
        if lower.contains("week") { return "/wk" }
        if lower.contains("quarter") { return "/qtr" }
        return "/\(lower.prefix(3))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Row: logo + name + status badge
            HStack(alignment: .top, spacing: 12) {
                AvatarView(
                    serviceName : sub.serviceName ?? "",
                    serviceLogo : sub.serviceLogo,
                    size        : 44,
                    isShadow    : false
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sub.serviceName ?? "")
                        .font(.geistSemiBold(14))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    
                    let planText = [sub.subscriptionType, sub.billingCycle]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                        .joined(separator: "  •  ")
                    Text(planText)
                        .font(.jetBrainsMedium(11))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(sub.currencySymbol ?? Constants.shared.currencySymbol)\(String(format: "%.2f", sub.amount ?? 0.0))")
                        .font(.geistSemiBold(14))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    
                    if let cycle = sub.billingCycle {
                        Text(getShortCycle(cycle))
                            .font(.jetBrainsMedium(11))
                            .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Divider()
                .background(themeManager.textPrimaryLight6_dark62)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            
            // Next charge row
            HStack(spacing: 6) {
                Text("Next charge :")
                    .font(.geistMedium(11))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                
                Text(Constants.shared.formatDate(sub.nextPaymentDate ?? "—"))
                    .font(.geistMedium(11))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(!isNew ? (themeManager.selectedAccent == .violet ? LinearGradient.brandFromDark0133_brandToDark0133 : themeManager.selectedAccent == .sunset ? LinearGradient.sunsetFrom0133_sunsetTo0133 : LinearGradient.auroraFrom0133_auroraTo0133 ) : LinearGradient(colors: [themeManager.white_white4], startPoint: .leading, endPoint: .trailing))
        //        .background(themeManager.white_white4)
        .cornerRadius(13)
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(
                    !isNew ? themeManager.accentLastColor : themeManager.textPrimaryLight8_white8,
                    lineWidth: !isNew ? 1.5 : 1
                )
        )
        .shadow(color: !isNew ? themeManager.accentLastColor.opacity(0.55) : .clear, radius: 12, x: 0, y: 6)
    }
}
