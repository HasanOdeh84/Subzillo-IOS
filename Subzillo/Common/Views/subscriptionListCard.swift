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
    var onRenew             : (() -> Void)? = nil
    @State var isExpired    = false
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    private var friendlyDateText: String {
        let rawDateStr = subscriptionData.nextPaymentDate ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let targetDate = formatter.date(from: rawDateStr) else {
            return Constants.shared.dateConversion(rawDateStr)
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        
        let days = calendar.dateComponents([.day], from: today, to: target).day ?? 0
        
        if days < 0 {
            return "Expired"
        } else if days == 0 {
            return "Today"
        } else if days > 30 {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy"
            return outputFormatter.string(from: targetDate)
        } else {
            return "In \(days)d"
        }
    }
    
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
                
                AvatarView(serviceName: subscriptionData.serviceName ?? "", serviceLogo: subscriptionData.serviceLogo ?? "", size: 42, isShadow: false)
                
                VStack(alignment: .leading,spacing: 4){
                   // Text(isActive ? "Next renewal" : "\(subscriptionData.serviceName ?? "") | \(subscriptionData.subscriptionType ?? "")")
                    HStack(spacing: 3){
                        Text(isActive ? "Next renewal" : "\(subscriptionData.serviceName ?? "")")
                            .font(.geistSemiBold(14))
                            .foregroundColor(isActive ? Color.neutral600 : Color("TextPrimary_ 0E101A_F4F1FB"))
                            .multilineTextAlignment(.leading)
                        if subscriptionData.nickName ?? "Me" != "Me" && subscriptionData.nickName ?? "Me" != "" {
                            Text(" FAMILY ")
                                .font(.jetBrainsRegular(8))
                                .foregroundColor(themeManager.selectedAccent.primaryColor)
                                .background(themeManager.selectedAccent.primaryColor.opacity(0.133))
                                .cornerRadius(4)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    HStack(spacing: 3){
                        
                        Text("\(subscriptionData.subscriptionType ?? "") . ")
                            .font(.jetBrainsRegular(12))
                            .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6))
                            .multilineTextAlignment(.leading)
                        
                        Text(friendlyDateText)
                            .font(.jetBrainsRegular(12))
                            .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6))
                            .multilineTextAlignment(.leading)
                        
                        if subscriptionData.renewBtnStatus ?? false{
                            Button(action: { onRenew?() }) {
                                Text("Renew")
                                    .font(.geistBold(14))
                                    .foregroundColor(.disCardRed)
                                    .underline()
                                    .multilineTextAlignment(.leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.leading, 5)
                        }
                        
                        /*if subscriptionData.status == "expired" && onRenew != nil {
                            Button(action: { onRenew?() }) {
                                Text("Renew")
                                    .font(.geistBold(14))
                                    .foregroundColor(.disCardRed)
                                    .underline()
                                    .multilineTextAlignment(.leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Text(subscriptionData.status == "expired" ? "Inactive" : Constants.shared.dateConversion(subscriptionData.nextPaymentDate ?? ""))
                                .font(subscriptionData.status == "expired" ? .geistBold(14) : .geistRegular(14))
                                .foregroundColor(subscriptionData.status == "expired" ? .disCardRed : (isActive ? .navyBlueCTA700White : .navyBlueCTA700))
                                .multilineTextAlignment(.leading)
                        }*/
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing,spacing: 8){
                    Text("\(subscriptionData.currencySymbol ?? "")\(String(describing: subscriptionData.amount ?? 0.0))")
                        .font(.geistSemiBold(16))
                        .foregroundColor(isActive ? .navyBlueCTA700White : Color("TextPrimary_ 0E101A_F4F1FB"))
                    
                    Text("/\((subscriptionData.billingCycle ?? "").billingCycleShortForm)")
                        .font(.jetBrainsRegular(10))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.36))
                    
                    /*if !isActive{
                        if subscriptionData.nickName == "" && subscriptionData.color == ""{
                            RelationView(isMore: false, name: "Me", color: "#619BEE")
                        }else{
                            RelationView(isMore: false, name: subscriptionData.nickName ?? "Me", color: subscriptionData.color ?? "#619BEE")
                        }
                    }*/
                }
            }
            .padding(12)
            .blur(radius: subscriptionData.viewStatus == false ? 4 : 0)
            .opacity(subscriptionData.viewStatus == false ? 0.35 : 1.0)
            
            if subscriptionData.viewStatus == false {
                
                // MARK: - Overlay Button
                HStack(spacing: 8) {
                    
                    // Lock Icon
                    Image("lock")
                        .resizable()
                        .frame(width: 14, height: 16)
                    
                    // Gradient Text
                    themeManager.accentGradient
                    .mask(
                        Text("Upgrade to Access")
                            .font(.geistBold(13))
                    )
                }
                .frame(width:160, height:20)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    themeManager.accentGradient.opacity(0.13)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            themeManager.selectedAccent.primaryColor.opacity(0.33),
                            lineWidth: 1
                        )
                )
                .clipShape(Capsule())
                
                /*HStack(spacing: 8) {
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
                }*/
            }
        }
        .frame(height: 74)
        .background(colorScheme == .dark ? Color(hex: "#181126") : themeManager.white_white4)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.textPrimary0E101AF4F1FB.opacity(0.08), lineWidth: 1)
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
