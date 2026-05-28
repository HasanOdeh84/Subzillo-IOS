//
//  SubscriptionMatchView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 12/11/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct SubscriptionMatchView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State var confidenceStr                    : String = ""
    @State var colorValue                       : Color?
    @State var subscriptionData                 : SubscriptionData?
    @State var initials                         : String  = ""
    @StateObject var subscriptionMatchVM        = SubscriptionMatchViewModel()
    var subscriptionId                          : String?
    var fromList                                = false
    @State var fromPush                         = false
    @State private var justAppeared             : Bool = false
    @State var showDeletePopup                  : Bool = false
    @StateObject var subscriptionsVM            = SubscriptionsViewModel()
    @State var renewalReminderValue             = ""
    @State var paymentMethodDataName            = ""
    @State private var deleteSheetHeight        : CGFloat = .zero
    @State private var showRenewSheet           : Bool = false
    @State private var renewSheetHeight         : CGFloat = .zero
    @State private var imageLoadFailed          = false
    @EnvironmentObject var themeManager         : ThemeManager
    @State var paidWith                         : String = ""
    
    private var serviceLogoURL: URL? {
        guard let logo = subscriptionData?.serviceLogo,
              !logo.isEmpty else { return nil }
        
        if let url = URL(string: logo), url.scheme != nil {
            // Already absolute URL
            return url
        }
        
        let baseURL = Constants.getUserDefaultsValue(for: Constants.providerBaseUrl)
        return URL(string: baseURL + logo)
    }
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            headerView
            
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    logoView
                    titleAndSubtitleView
                    priceView
                    renewButtonView
                    gridDataBoxView
                    actionButtonsView
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }
            .padding(.top, 10)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                justAppeared = true
                if fromList {
                    self.showOfflineDetails()
                    subscriptionMatchVM.getSubscriptionDetails(input: GetSubscriptionDetailsRequest(userId: Constants.getUserId(), subscriptionId: subscriptionId ?? ""))
                } else {
                    getSubDetails()
                }
                if let serviceName = subscriptionData?.serviceName {
                    let words = serviceName
                        .split(separator: " ")
                        .filter { !$0.isEmpty }
                    
                    if words.count == 1 {
                        initials = String(words[0].prefix(1)).uppercased()
                    } else {
                        initials = words.prefix(2)
                            .map { String($0.prefix(1)).uppercased() }
                            .joined()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    justAppeared = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshScreenData"))) { notification in
                if !justAppeared {
                    if fromList {
                        self.fromPush = true
                        self.showOfflineDetails()
                        let idFromPush = notification.userInfo?["subscriptionId"] as? String
                        let finalId = (idFromPush?.isEmpty == false) ? idFromPush : subscriptionId
                        subscriptionMatchVM.getSubscriptionDetails(input: GetSubscriptionDetailsRequest(userId: Constants.getUserId(), subscriptionId: finalId ?? ""))
                    }else{
                        getSubDetails()
                    }
                }
            }
            .onChange(of: subscriptionId) { newId in
                if !justAppeared {
                    if fromList {
                        self.showOfflineDetails()
                        subscriptionMatchVM.getSubscriptionDetails(input: GetSubscriptionDetailsRequest(userId: Constants.getUserId(), subscriptionId: newId ?? ""))
                    }
                }
            }
            .onChange(of: subscriptionMatchVM.isRenewSuccess) { value in
                if value{
                    self.showOfflineDetails()
                    subscriptionMatchVM.getSubscriptionDetails(input: GetSubscriptionDetailsRequest(userId: Constants.getUserId(), subscriptionId: subscriptionId ?? ""))
                }
            }
            .onChange(of: globalSubscriptionData) { _ in updateSubDetails() }
            .onChange(of: subscriptionMatchVM.getSubsDetailsResponse) { _ in
                if fromPush{
                    showRenewSheet = true
                    self.fromPush = false
                }
                updateSubDetails()
            }
            .onChange(of: subscriptionsVM.isDeletedSubscription) { _ in
                if subscriptionsVM.isDeletedSubscription == true {
                    SubscriptionDBManager.shared.deleteSubscription(id: subscriptionData?.id ?? "")
                }
                //                AppIntentRouter.shared.pop()
                AppIntentRouter.shared.navigate(to: .subscriptionsListView())
            }
            .sheet(isPresented: $showDeletePopup) {
                InfoAlertSheet(
                    onDelegate: {
                        deleteSubscription()
                    }, title                : "Are you sure you want to delete the subscriptions?",
                    subTitle                : "Data will be permanently deleted",
                    imageName               : "del_red_new",
                    buttonIcon              : "del_red_newSmall",
                    buttonTitle             : "Delete",
                    imageSize               : 70,
                    isCancelButtonVisible   : true,
                    isImageVisible          : true
                )
                .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                    if height > 0 {
                        deleteSheetHeight = height
                    }
                }
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(deleteSheetHeight)])
            }
            .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
                showDeletePopup = false
                showRenewSheet = false
            }
            .sheet(isPresented: $showRenewSheet) {
                RenewSubscriptionBottomSheet(
                    onRenew: {
                        if let id = subscriptionData?.id {
                            let input = RenewalUpdateRequest(userId         : Constants.getUserId(),
                                                             subscriptionId : id,
                                                             type           : 1)
                            subscriptionMatchVM.renewalUpdate(input: input)
                        }
                    },
                    onRenewWithChanges: {
                        onEdit(isRenew: true)
                    },
                    onNo: {
                        showRenewSheet = false
                    }
                )
                .overlay {
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: InnerHeightPreferenceKey.self,
                                value: geo.size.height
                            )
                    }
                }
                .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                    if height > 150 {
                        renewSheetHeight = height
                    }
                }
                .presentationDetents([.height(renewSheetHeight)])
                .presentationDragIndicator(.hidden)
            }
        }
        .applyAppBackground()
    }
    
    // MARK: - Views
    private var headerView: some View {
        HStack(spacing: 8) {
            CircleBackButton(action: goBack)
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var logoView: some View {
        ZStack(alignment: .topTrailing) {
            if (subscriptionData?.serviceLogo ?? "").isEmpty {
                ZStack {
                    Color.flagBgF1F2F7F7F7F9
                    Text(initials)
                        .font(.geistSemiBold(40))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                }
                .frame(width: 80, height: 80)
                //                        .overlay(
                //                            RoundedRectangle(cornerRadius: 24)
                //                                .stroke(themeManager.textPrimaryLight6_dark62, lineWidth: 1)
                //                        )
                .cornerRadius(24)
            } else {
                if fromList {
                    if imageLoadFailed {
                        Image("profile_avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(24)
                    } else {
                        WebImage(url: URL(string: subscriptionData?.serviceLogo ?? ""))
                            .resizable()
                            .onFailure { _ in imageLoadFailed = true }
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(24)
                            .clipped()
                    }
                } else {
                    if imageLoadFailed {
                        Image("profile_avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(24)
                    } else {
                        if let url = serviceLogoURL {
                            WebImage(url: url)
                                .resizable()
                                .onFailure { _ in imageLoadFailed = true }
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(24)
                                .clipped()
                        }
                    }
                }
            }
        }
        //        AvatarView(serviceName  : subscriptionData?.serviceName ?? "",
        //                   serviceLogo  : subscriptionData?.serviceLogo ?? "",
        //                   size         : 88,
        //                   cornerRadius : 24,
        //                   fontSize     : 40,
        //                   isShadow     : true)
        .padding(.top, 20)
    }
    
    private var titleAndSubtitleView: some View {
        VStack(spacing: 4) {
            Text(subscriptionData?.serviceName ?? "")
                .font(.geistBold(28))
                .foregroundColor(.textPrimary0E101AF4F1FB)
            
            let planType = subscriptionData?.subscriptionType ?? "Premium"
            let dateStr = subscriptionData?.createdAt != nil && subscriptionData?.createdAt != "" ? subscriptionData!.createdAt!.formattedDate(from: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", to: "MMM yyyy") : "Jan 2022"
            Text("\(planType) - since \(dateStr)")
                .font(.geistMedium(13))
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
        }
    }
    
    private var priceView: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text(subscriptionData?.currencySymbol ?? "$")
                .font(.geistMedium(20))
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
            Text("\(String(format: "%.2f", subscriptionData?.amount ?? 0.0))")
                .font(.geistSemiBold(44))
                .foregroundColor(.textPrimary0E101AF4F1FB)
            
            let cycle = subscriptionData?.billingCycleShortLabel ?? (subscriptionData?.billingCycle == "yearly" || subscriptionData?.billingCycle == "annual" ? "yr" : "mo")
            Text("\(cycle)")
                .font(.jetBrainsMedium(14))
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
        }
        .padding(.top, 4)
    }
    
    @ViewBuilder
    private var renewButtonView: some View {
        if subscriptionData?.renewBtnStatus ?? true {
            GradientBgButton(
                title           : "Renew",
                isSolid         : true,
                action          : { showRenewSheet = true },
                buttonHeight    : 52
            )
            //            .padding(.top, 8)
        }
    }
    
    private var gridDataBoxView: some View {
        VStack(spacing: 24) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("NEXT RENEWAL")
                        .font(.jetBrainsMedium(10))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .kerning(1.0)
                    Text((subscriptionData?.nextPaymentDate ?? "").formattedDate(to: "MMM dd"))
                        .font(.geistSemiBold(16))
                        .foregroundColor(themeManager.accentTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PAID WITH")
                            .font(.jetBrainsMedium(10))
                            .foregroundColor(themeManager.textPrimaryLight6_dark62)
                            .kerning(1.0)
                        //                    var cardLinked = paymentMethodDataName.isEmpty ? "•••• 4829" : paymentMethodDataName
                        Text(paidWith == "" ? "-----------" : paidWith)
                            .font(.geistSemiBold(16))
                            .foregroundColor(.textPrimary0E101AF4F1FB)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CATEGORY")
                        .font(.jetBrainsMedium(10))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .kerning(1.0)
                    //
                    //                        let cycleVal = subscriptionData?.billingCycle?.lowercased() ?? "monthly"
                    //                        let amountVal = subscriptionData?.amount ?? 0.0
                    //                        let annualVal = (cycleVal == "yearly" || cycleVal == "annual") ? amountVal : (cycleVal == "weekly" ? amountVal * 52 : amountVal * 12)
                    
                    Text("\(subscriptionData?.categoryName ?? "-----------")")
                        .font(.geistSemiBold(16))
                        .foregroundColor(.textPrimary0E101AF4F1FB)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("PLAN TYPE")
                        .font(.jetBrainsMedium(10))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .kerning(1.0)
                    Text(subscriptionData?.subscriptionType ?? "Premium")
                        .font(.geistSemiBold(16))
                        .foregroundColor(.success0EA8705CE4A8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
        //        .shadow(color: Color.dropShadowColor1, radius: 2, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
        )
        .background(themeManager.white_white4)
        .cornerRadius(22)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            CustomBorderButton(
                title       : "Edit plan",
                background  : Color.clear,
                borderColor : themeManager.textPrimaryLight14_white14,
                textColor   : .textPrimary0E101AF4F1FB,
                font        : .geistBold(17),
                height      : 52,
                showIcon    : true,
                icon        : "edit_new",
                iconOnLeft  : true,
                action      : { onEdit() }
            )
            
            CustomBorderButton(
                title       : "Upgrade or Downgrade",
                background  : Color.warningAnyFFCB5C.opacity(0.1),
                borderColor : Color.warningAnyFFCB5C.opacity(0.35),
                textColor   : Color.warningAnyFFCB5C,
                height      : 52,
                showIcon    : true,
                icon        : "tag_yellow",
                iconOnLeft  : true,
                action      : { /* action? */ }
            )
            
            CustomBorderButton(
                title       : "Cancel subscription",
                background  : Color.dangerE43C5CFF5A7A.opacity(0.1),
                borderColor : Color.dangerE43C5CFF5A7A.opacity(0.3),
                textColor   : Color.dangerE43C5CFF5A7A,
                height      : 52,
                showIcon    : true,
                icon        : "del_red_newSmall",
                iconOnLeft  : true,
                action      : { showDeletePopup = true }
            )
        }
        .padding(.top, 8)
    }
    
    //MARK: - User defined methods
    func showOfflineDetails()
    {
        if fromList{
            let subDetails                  = SubscriptionDBManager.shared.getSubscriptions(value: subscriptionId ?? "", type: "byID").first
            
            guard let subData = subDetails else { return }
            
            subscriptionData =  SubscriptionData(id                     : subData.id,
                                                 serviceName            : subData.serviceName,
                                                 serviceLogo            : subData.serviceLogo,
                                                 subscriptionType       : subData.subscriptionType,
                                                 amount                 : subData.amount,
                                                 currency               : subData.currency,
                                                 currencySymbol         : subData.currencySymbol,
                                                 billingCycle           : subData.billingCycle,
                                                 nextPaymentDate        : subData.nextPaymentDate,
                                                 paymentMethodId        : subData.paymentMethod,
                                                 paymentMethod          : subData.paymentMethodName,
                                                 paymentMethodName      : subData.paymentMethodName,
                                                 category               : subData.category,
                                                 categoryName           : subData.categoryName,
                                                 isSubscription         : true,
                                                 subscriptionForName    : subData.nickName,
                                                 subscriptionFor        : subData.subscriptionFor,
                                                 paymentMethodDataId    : subData.paymentMethodDataId,
                                                 paymentMethodDataName  : subData.paymentMethodDataName,
                                                 renewalReminder        : subData.renewalReminder,
                                                 renewalReminders       : subData.renewalReminder,
                                                 notes                  : subData.notes,
                                                 status                 : subData.status,
                                                 cardName               : subData.cardName,
                                                 cardNumber             : subData.cardNumber,
                                                 nickName               : subData.nickName,
                                                 color                  : subData.color)
            
            let renewalReminder = subscriptionData?.renewalReminders ?? []
            if let first = renewalReminder.first {
                let stripped = first.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "d", with: "")
                if let days = Int(stripped), days > 0 {
                    renewalReminderValue = "\(days) days before renewal"
                } else {
                    renewalReminderValue = "Off"
                }
            } else {
                renewalReminderValue = "Off"
            }
            if subscriptionData?.cardName != "" && subscriptionData?.cardNumber != ""{
                paymentMethodDataName = "\(subscriptionData?.cardName ?? "")****\(subscriptionData?.cardNumber ?? "")"
                paidWith = "••••  \(subscriptionData?.cardNumber ?? "")"
            }
            else{
                paidWith = subscriptionData?.paymentMethodName ?? ""
            }
            getSubDetails()
        }
    }
    
    func updateSubDetails()
    {
        if fromList{
            subscriptionData                        = subscriptionMatchVM.getSubsDetailsResponse
            subscriptionData?.categoryId            = subscriptionMatchVM.getSubsDetailsResponse?.category
            subscriptionData?.renewalReminder       = subscriptionMatchVM.getSubsDetailsResponse?.renewalReminders
            subscriptionData?.paymentMethodId       = subscriptionMatchVM.getSubsDetailsResponse?.paymentMethod
            let renewalReminder = subscriptionData?.renewalReminders ?? []
            if let first = renewalReminder.first {
                let stripped = first.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "d", with: "")
                if let days = Int(stripped), days > 0 {
                    renewalReminderValue = "\(days) days before renewal"
                } else {
                    renewalReminderValue = "Off"
                }
            } else {
                renewalReminderValue = "Off"
            }
            if subscriptionData?.cardName != "" && subscriptionData?.cardNumber != ""{
                paymentMethodDataName = "\(subscriptionData?.cardName ?? "")****\(subscriptionData?.cardNumber ?? "")"
            }
            getSubDetails()
        }else{
            if globalSubscriptionData != nil {
                subscriptionData = globalSubscriptionData!
                getSubDetails()
            }
        }
    }
    
    func getSubDetails()
    {
        let (confidenceStr1, colorValue1, fillRatio) =
        Constants.confidenceInfo(isAssumed: false, confidence: subscriptionData?.confidenceOverall ?? 0.0)
        confidenceStr = confidenceStr1
        colorValue = colorValue1
        
        let serviceName = subscriptionData?.serviceName ?? ""
        let words = serviceName
            .split(separator: " ")
            .filter { !$0.isEmpty }
        
        if words.count == 1 {
            initials = String(words[0].prefix(1)).uppercased()
            print("initial is \(initials)")
        } else {
            initials = words.prefix(2)
                .map { String($0.prefix(1)).uppercased() }
                .joined()
            print("initial is else\(initials)")
        }
    }
    
    //MARK: - Button actions
    private func goBack() {
        AppIntentRouter.shared.pop()
    }
    
    func onEdit(isRenew: Bool = false) {
        globalSubscriptionData = subscriptionData!
        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: true, isFromListEdit:fromList, isRenew: isRenew, subscriptionId: subscriptionData?.id ?? ""))
    }
    
    func deleteSubscription() {
        subscriptionsVM.deleteSubscription(input: DeleteSubscriptionRequest(userId: Constants.getUserId(), subscriptionIds: [subscriptionData?.id ?? ""]))
    }
}

//MARK: - SubscriptionDetailsPlainItem
struct SubscriptionDetailsPlainItem: View {
    var title                   : String
    var value                   : String?
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.appRegular(14))
                .foregroundColor(.neutral500)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            DashedHorizontalDivider()
                .layoutPriority(0)
            Text(value ?? "")
                .font(.appBold(14))
                .foregroundColor(.blueMain700)
                .multilineTextAlignment(.trailing)
                .lineLimit(nil)
                .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
