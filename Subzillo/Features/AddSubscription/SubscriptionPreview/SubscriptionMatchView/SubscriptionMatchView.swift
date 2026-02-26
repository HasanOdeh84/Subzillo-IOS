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
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: goBack) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                Text(fromList ? "Subscription Details" : "Subscription Match Details")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            ScrollView {
                VStack(alignment: .leading,spacing: 16) {
                    ZStack(alignment: .topTrailing) {
                        if (subscriptionData?.serviceLogo ?? "").isEmpty {
                            ZStack {
                                Color.whiteBlackBG
                                Text(initials)
                                    .font(.appSemiBold(50))
                                    .foregroundColor(.secondaryNavyBlue400)
                            }
                            .frame(width: 128, height: 128)
                            .overlay(
                                RoundedRectangle(cornerRadius: 64)
                                    .stroke(.neutral300Border, lineWidth: 1)
                            )
                            .cornerRadius(64)
                        } else {
                            if fromList{
                                WebImage(url: URL(string: subscriptionData?.serviceLogo ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 128, height: 128)
                                    .cornerRadius(64)
                                    .clipped()
                            }else{
                                //                                WebImage(url: URL(string: "\(Constants.getUserDefaultsValue(for: Constants.providerBaseUrl))\(subscriptionData?.serviceLogo ?? "")"))
                                //                                    .resizable()
                                //                                    .scaledToFill()
                                //                                    .frame(width: 128, height: 128)
                                //                                    .cornerRadius(64)
                                //                                    .clipped()
                                
                                if let url = serviceLogoURL {
                                    WebImage(url: url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                        .clipped()
                                }
                            }
                        }
                        
                        if !fromList{
                            Image("matchIcon")
                                .frame(width: 33, height: 33)
                                .offset(x: 2, y: 0)
                                .background(colorValue)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16.5)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(color: Color.dropShadowColor1, radius: 2, x: 0, y: 2)
                                .cornerRadius(16.5)
                        }
                    }
                    .frame(width: 140, height: 128, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top,20)
                    
                    VStack(alignment: .leading,spacing: 8) {
                        
                        SubscriptionDetailsPlainItem(title: "Service Name", value: subscriptionData?.serviceName ?? "")
                        SubscriptionDetailsPlainItem(title: "Category", value: subscriptionData?.categoryName ?? "")
                        SubscriptionDetailsPlainItem(title: "Plan Type", value: subscriptionData?.subscriptionType ?? "")
                        SubscriptionDetailsPlainItem(title: "Price", value: "\(subscriptionData?.currencySymbol ?? "")\(subscriptionData?.amount ?? 0.0)")
                        SubscriptionDetailsPlainItem(title: "Currency", value: subscriptionData?.currency ?? Constants.shared.currencyCode)
                        SubscriptionDetailsPlainItem(title: "Billing Cycle", value: subscriptionData?.billingCycle ?? "")
                        //                        SubscriptionDetailsPlainItem(title: "Subscription Start  Date", value: (subscriptionData?.lastPaymentDate ?? "").formattedDate())
                        SubscriptionDetailsPlainItem(title: "Next Charge Date", value: (subscriptionData?.nextPaymentDate ?? "").formattedDate(to: "d MMM yyyy"))
                        SubscriptionDetailsPlainItem(title: "Payment Method", value: subscriptionData?.paymentMethodName ?? "")
                        if fromList{
                            if subscriptionData?.paymentMethodStatus == true{
                                SubscriptionDetailsPlainItem(title: "Card Linked", value: paymentMethodDataName)
                            }
                            //subscriptionFor Need to change with nickName
                            if subscriptionData?.subscriptionFor ?? "" == "" || subscriptionData?.subscriptionFor ?? "" == Constants.getUserId(){
                                SubscriptionDetailsPlainItem(title: "Benefit From", value: "Me")
                            }else{
                                SubscriptionDetailsPlainItem(title: "Benefit From", value: subscriptionData?.nickName)
                            }
                            //                            SubscriptionDetailsPlainItem(title: "Benefit From", value: subscriptionData?.subscriptionFor ?? "" == "" ? "Me" : subscriptionData?.subscriptionFor ?? "")
                            SubscriptionDetailsPlainItem(title: "Renewal Reminders", value: renewalReminderValue)
                        }else{
                            if subscriptionData?.paymentMethodName ?? "" != ""{
                                SubscriptionDetailsPlainItem(title: "Card Linked", value: subscriptionData?.paymentMethodDataName ?? "")
                            }
                            SubscriptionDetailsPlainItem(title: "Benefit From", value: subscriptionData?.subscriptionForName ?? "")
                            SubscriptionDetailsPlainItem(title: "Renewal Reminders", value: subscriptionData?.renewalReminderValue ?? "")
                        }
                        SubscriptionDetailsPlainItem(title: "Status", value: fromList ? subscriptionData?.status : "Active")
                        SubscriptionDetailsPlainItem(title: "Note", value: subscriptionData?.notes ?? "")
                    }
                    .padding(24)
                    .background(.whiteNeutralCardBG)
                    .cornerRadius(12)
                    .shadow(color: Color.dropShadowColor1, radius: 2, x: 0, y: 2)
                }
                .padding(.vertical, 16)
                .padding(.horizontal,20)
                
                if fromList{
                    VStack(spacing: 12) {
                        
                        HStack(spacing: 12){
                            
                            // MARK: - Delete Button
                            Button() {
                                showDeletePopup = true
                            } label: {
                                HStack(spacing: 5) {
                                    Image("delete_red")
                                        .resizable()
                                        .frame(width: 17, height: 19)
                                    
                                    Text(LocalizedStringKey("Delete"))
                                        .font(.appSemiBold(14))
                                        .foregroundColor(Color.disCardRed)
                                }
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(Color.whiteBlack)
                                .cornerRadius(8)
                                .overlay(
                                    // keep the stroke visually inside by padding the shape inward
                                    RoundedCorner(radius: 8)
                                        .stroke(
                                            Color.disCardRed,
                                            lineWidth: 1
                                        )
                                )
                            }
                            
                            //MARK: Edit button
                            GradientBorderButton(title: "Edit", isBtn: true, buttonImage: "EditIcon", action: { onEdit()
                            }, backgroundColor: .whiteBlack, buttonHeight: 56)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom,20)
                }else{
                    VStack(spacing: 12) {
                        //                        if subscriptionData?.status == "expired" {
                        //                            CustomButton(
                        //                                title   : "Renew",
                        //                                height  : 56,
                        //                                action  : {
                        //                                    showRenewSheet = true
                        //                                }
                        //                            )
                        //                            //                            GradientBorderButton(title: "Renew", isBtn: true, buttonImage: "update", action: { showRenewSheet = true }, backgroundColor: .whiteBlack, buttonHeight: 56)
                        //                            //                                .padding(.horizontal)
                        //                        }
                        
                        //MARK: Edit button
                        GradientBorderButton(title: "Edit", isBtn: true, buttonImage: "EditIcon", action: { onEdit()
                        }, backgroundColor: .whiteBlack, buttonHeight: 56)
                        .padding(.horizontal)
                    }
                    .padding(.bottom,20)
                }
                
                if subscriptionData?.renewBtnStatus ?? false {
                    CustomButton(
                        title   : "Renew",
                        height  : 56,
                        action  : {
                            showRenewSheet = true
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.top, 10)
            .background(.neutralBg100)
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
                dismiss()
            }
            .sheet(isPresented: $showDeletePopup) {
                InfoAlertSheet(
                    onDelegate: {
                        deleteSubscription()
                    }, title    : "Are you sure you want to delete the subscriptions?\nData will be permanently deleted",
                    subTitle    :"",
                    imageName   : "del_red_big",
                    buttonIcon  : "deleteIcon",
                    buttonTitle : "Delete",
                    imageSize   : 70
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
                //                .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                //                    if height > 0 {
                //                        renewSheetHeight = height
                //                    }
                //                }
                //                .presentationDragIndicator(.hidden)
                //                .presentationDetents([.height(renewSheetHeight)])
            }
        }
        .background(.neutralBg100)
    }
    
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
            
            var remindersData = [
                ManualDataInfo(id: "1", title: "3 days before renewal", value: "-3d"),
                ManualDataInfo(id: "2", title: "1 day before renewal", value: "-1d"),
                ManualDataInfo(id: "3", title: "On renewal day", value:"0d")
            ]
            var renewalReminder = subscriptionData?.renewalReminders ?? []
            for i in remindersData.indices {
                remindersData[i].isSelected = renewalReminder.contains(remindersData[i].value ?? "")
            }
            renewalReminderValue = ""
            for item in remindersData        {
                if item.isSelected ?? false == true
                {
                    renewalReminder.append(item.value!)
                    if renewalReminderValue != "" {
                        renewalReminderValue = "\(renewalReminderValue)\n\(item.title ?? "")"
                    }
                    else{
                        renewalReminderValue = item.title ?? ""
                    }
                }
            }
            if subscriptionData?.cardName != "" && subscriptionData?.cardNumber != ""{
                paymentMethodDataName = "\(subscriptionData?.cardName ?? "")****\(subscriptionData?.cardNumber ?? "")"
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
            var remindersData = [
                ManualDataInfo(id: "1", title: "3 days before renewal", value: "-3d"),
                ManualDataInfo(id: "2", title: "1 day before renewal", value: "-1d"),
                ManualDataInfo(id: "3", title: "On renewal day", value:"0d")
            ]
            var renewalReminder = subscriptionData?.renewalReminders ?? []
            for i in remindersData.indices {
                remindersData[i].isSelected = renewalReminder.contains(remindersData[i].value ?? "")
            }
            renewalReminderValue = ""
            for item in remindersData        {
                if item.isSelected ?? false == true
                {
                    renewalReminder.append(item.value!)
                    if renewalReminderValue != "" {
                        renewalReminderValue = "\(renewalReminderValue)\n\(item.title ?? "")"
                    }
                    else{
                        renewalReminderValue = item.title ?? ""
                    }
                }
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
        dismiss()
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
