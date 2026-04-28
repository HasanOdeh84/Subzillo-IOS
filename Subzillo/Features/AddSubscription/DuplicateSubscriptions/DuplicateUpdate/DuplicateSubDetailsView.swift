//
//  DuplicateSubDetailsView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 20/11/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct DuplicateSubDetailsView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State var subscriptionData                 : SubscriptionInfo?
    @State var initials                         : String  = ""
    @State var renewalReminderValue             = ""
    @State private var imageLoadFailed          = false
    
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
                
                Text("Subscription Details")
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
                            if imageLoadFailed {
                                Image("profile_avatar")
                                    .resizable()
                                    .scaledToFill()
                            }else{
                                WebImage(url: URL(string: subscriptionData?.serviceLogo ?? ""))
                                    .resizable()
                                    .onFailure { _ in
                                        imageLoadFailed = true
                                    }
                                    .scaledToFill()
                                    .frame(width: 128, height: 128)
                                    .cornerRadius(64)
                                    .clipped()
                            }
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
                        //SubscriptionDetailsPlainItem(title: "Subscription start", value: (subscriptionData?.lastPaymentDate ?? "").formattedDate())
                        SubscriptionDetailsPlainItem(title: "Next Payment Date", value: (subscriptionData?.nextPaymentDate ?? "").formattedDate(to: "d MMM yyyy"))
                        SubscriptionDetailsPlainItem(title: "Payment Method", value: subscriptionData?.paymentMethodName ?? "")
                        if subscriptionData?.paymentMethodName ?? "" != ""{
                            SubscriptionDetailsPlainItem(title: "Card Linked", value: "\(subscriptionData?.cardName ?? "")****\(subscriptionData?.cardNumber ?? "")")
                        }
                        //subscriptionFor Need to change with nickName
                        if subscriptionData?.subscriptionFor ?? "" == "" || subscriptionData?.subscriptionFor ?? "" == Constants.getUserId(){
                            //                            SubscriptionDetailsPlainItem(title: "Benefit From", value: subscriptionData?.subscriptionFor ?? "" == "" ? "Me" : subscriptionData?.subscriptionFor ?? "")
                            SubscriptionDetailsPlainItem(title: "Benefit From", value: "Me")
                        }else{
                            SubscriptionDetailsPlainItem(title: "Benefit From", value: "")
                        }
                        SubscriptionDetailsPlainItem(title: "Renewal Reminders", value: renewalReminderValue)
                        //                        SubscriptionDetailsPlainItem(title: "Status", value: subscriptionData?.status ?? "Active")
                        SubscriptionDetailsPlainItem(title: "Status", value: subscriptionData?.status ?? "")
                        SubscriptionDetailsPlainItem(title: "Note", value: subscriptionData?.notes ?? "")
                    }
                    .padding(24)
                    .background(.whiteNeutralCardBG)
                    .cornerRadius(12)
                    .shadow(color: Color.dropShadowColor1, radius: 2, x: 0, y: 2)
                }
                .padding(.vertical, 16)
                .padding(.horizontal,20)
                
            }
            .padding(.top, 10)
            .background(.neutralBg100)
            .navigationBarBackButtonHidden(true)
        }
        .background(.neutralBg100)
        .onAppear{
            updateSubDetails()
        }
    }
    
    func updateSubDetails()
    {
        let serviceName = subscriptionData?.serviceName ?? ""
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
        
        var remindersData = [
            ManualDataInfo(id: "1", title: "3 days before renewal", value: "-3d"),
            ManualDataInfo(id: "2", title: "1 day before renewal", value: "-1d"),
            ManualDataInfo(id: "3", title: "On renewal day", value:"0d")
        ]
        var renewalReminder = subscriptionData?.renewalReminder ?? []
        for i in remindersData.indices {
            remindersData[i].isSelected = renewalReminder.contains(remindersData[i].value ?? "")
        }
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
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
}

