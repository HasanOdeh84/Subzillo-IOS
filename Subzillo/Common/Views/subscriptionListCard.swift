//
//  subscriptionListCard.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 05/11/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct subscriptionListCard: View {
    
    //MARK: - Properties
    var subscriptionData    : SubscriptionListData
    var isActive            : Bool = false
    @State var title        = ""
    @State var subTitle     = ""
    @State var nextPayment  = ""
    @State var relation     = ""
    @State var colour       = ""
    var selectionMode       : Bool = false
    var onSelect            : () -> Void = {}
    var onLongPress         : () -> Void = {}
    @State var isExpired    = false
    
    //MARK: - body
    var body: some View {
        ZStack {
            HStack{
                if selectionMode {
                    Button(action: onSelect) {
                        Image(subscriptionData.isSelected == true ? "Checkmark" : "UnCheckmark")
                            .font(.system(size: 24))
                    }
                    .padding(.horizontal,12)
                }
                
                AvatarView(serviceName: subscriptionData.serviceName ?? "", serviceLogo: subscriptionData.serviceLogo ?? "", size: 48)
                
                VStack(alignment: .leading,spacing: 4){
                    Text(isActive ? "Next renewal" : "\(subscriptionData.serviceName ?? "") | \(subscriptionData.subscriptionType ?? "")")
                        .font(.appRegular(12))
                        .foregroundColor(isActive ? Color.neutral600 : Color.neutral600White)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 3){
                        Text("\(isActive ? subscriptionData.serviceName ?? "" : subscriptionData.billingCycle ?? "") •")
                            .font(.appRegular(14))
                            .foregroundColor(isActive ? .navyBlueCTA700White : .navyBlueCTA700)
                            .multilineTextAlignment(.leading)
                        Text(subscriptionData.status == "expired" ? "Inactive" : Constants.shared.dateConversion(subscriptionData.nextPaymentDate ?? ""))
                            .font(subscriptionData.status == "expired" ? .appBold(14) : .appRegular(14))
                            .foregroundColor(subscriptionData.status == "expired" ? .disCardRed : (isActive ? .navyBlueCTA700White : .navyBlueCTA700))
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing,spacing: 8){
                    Text("\(subscriptionData.currencySymbol ?? "")\(String(describing: subscriptionData.amount ?? 0.0))")
                        .font(.appSemiBold(16))
                        .foregroundColor(isActive ? .navyBlueCTA700White : .navyBlueCTA700)
                    if !isActive{
                        if subscriptionData.nickName == "" && subscriptionData.color == ""{
                            RelationView(isMore: false, name: "Me", color: "#619BEE")
                        }else{
                            RelationView(isMore: false, name: subscriptionData.nickName ?? "Me", color: subscriptionData.color ?? "#619BEE")
                        }
                    }
                }
            }
            .padding(12)
            .opacity(subscriptionData.viewStatus == false ? 0.1 : 1.0)
            
            if subscriptionData.viewStatus == false {
                HStack(spacing: 8) {
                    Image("lock")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("Upgrade to Access")
                        .font(.appSemiBold(18))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
        }
        .frame(height: 74)
        .background(.whiteBlackBG)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .onLongPressGesture {
            if subscriptionData.viewStatus != false {
                onLongPress()
            }
        }
    }
    
    //MARK: - User defined methods
    func updateData(){
        if subscriptionData.nickName == "" && subscriptionData.color == ""{
            relation    = "Me"
            colour      = "#619BEE"
        }else{
            relation = subscriptionData.nickName ?? "Me"
            colour   = subscriptionData.color ?? "#619BEE"
        }
        nextPayment = Constants.shared.dateConversion(subscriptionData.nextPaymentDate ?? "")
        if subscriptionData.status == "expired"{
            nextPayment = "Inactive"
            isExpired   = true
        }
        if isActive{
            title       = "Next renewal"
            subTitle    = "\(subscriptionData.serviceName ?? "") •"
        }else{
            title       = "\(subscriptionData.serviceName ?? "") | \(subscriptionData.subscriptionType ?? "")"
            subTitle    = "\(subscriptionData.billingCycle ?? "") •"
        }
    }
}


struct subscriptionListCardInFamilyMember: View {
    
    //MARK: - Properties
    var subscriptionData    : SubscriptionListData
    var isActive            : Bool = false
    @State var title        = ""
    @State var subTitle     = ""
    @State var nextPayment  = ""
    @State var relation     = ""
    @State var colour       = ""
    var selectionMode       : Bool = false
    var onSelect            : () -> Void = {}
    var onLongPress         : () -> Void = {}
    @State var isExpired    = false
    
    //MARK: - body
    var body: some View {
        ZStack {
            HStack{
                if selectionMode {
                    Button(action: onSelect) {
                        Image(subscriptionData.isSelected == true ? "Checkmark" : "UnCheckmark")
                            .font(.system(size: 24))
                    }
                    .padding(.horizontal,12)
                }
                
                AvatarView(serviceName: subscriptionData.serviceName ?? "", serviceLogo: subscriptionData.serviceLogo ?? "", size: 48)
                
                VStack(alignment: .leading,spacing: 4){
                    Text(isActive ? "Next renewal" : "\(subscriptionData.serviceName ?? "") | \(subscriptionData.subscriptionType ?? "")")
                        .font(.appRegular(12))
                        .foregroundColor(isActive ? Color.neutral600 : Color.neutral600White)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 3){
                        Text("\(isActive ? subscriptionData.serviceName ?? "" : subscriptionData.billingCycle ?? "") •")
                            .font(.appRegular(14))
                            .foregroundColor(isActive ? .navyBlueCTA700White : .navyBlueCTA700)
                            .multilineTextAlignment(.leading)
                        Text(subscriptionData.status == "expired" ? "Inactive" : Constants.shared.dateConversion(subscriptionData.nextPaymentDate ?? ""))
                            .font(subscriptionData.status == "expired" ? .appBold(14) : .appRegular(14))
                            .foregroundColor(subscriptionData.status == "expired" ? .disCardRed : (isActive ? .navyBlueCTA700White : .navyBlueCTA700))
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing,spacing: 8){
                    Text("\(subscriptionData.currencySymbol ?? "")\(String(describing: subscriptionData.amount ?? 0.0))")
                        .font(.appSemiBold(16))
                        .foregroundColor(isActive ? .navyBlueCTA700White : .navyBlueCTA700)
                }
            }
            .padding(16)
            .opacity(subscriptionData.viewStatus == false ? 0.1 : 1.0)
            
            if subscriptionData.viewStatus == false {
                HStack(spacing: 8) {
                    Image("lock")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("Upgrade to Access")
                        .font(.appSemiBold(18))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
        }
        .frame(height: 74)
        .background(.neutralBg100)
        .onLongPressGesture {
            if subscriptionData.viewStatus != false {
                onLongPress()
            }
        }
    }
    
    //MARK: - User defined methods
    func updateData(){
        if subscriptionData.nickName == "" && subscriptionData.color == ""{
            relation    = "Me"
            colour      = "#619BEE"
        }else{
            relation = subscriptionData.nickName ?? "Me"
            colour   = subscriptionData.color ?? "#619BEE"
        }
        nextPayment = Constants.shared.dateConversion(subscriptionData.nextPaymentDate ?? "")
        if subscriptionData.status == "expired"{
            nextPayment = "Inactive"
            isExpired   = true
        }
        title       = "\(subscriptionData.serviceName ?? "") | \(subscriptionData.subscriptionType ?? "")"
        subTitle    = "\(subscriptionData.billingCycle ?? "") •"
    }
}
