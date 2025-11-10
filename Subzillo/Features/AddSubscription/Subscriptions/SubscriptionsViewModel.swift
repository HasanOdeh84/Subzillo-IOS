//
//  SubscriptionsViewModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 06/11/25.
//

import SwiftUI

struct SubscriptionRow: View {
    let subscriptionData: SubscriptionInfo
    var body: some View {
        HStack(spacing: 0) {
            Text(getDay(from: subscriptionData.createdAt ?? ""))
                .font(.appSemiBold(24))
                .foregroundColor(.navyBlueCTA700)
                .multilineTextAlignment(.center)
                .frame(width: 60, alignment: .center)
                .frame(height: calculatedHeight(for: subscriptionData))
                .background(Color.primeryBlue100)
            
            DashedVerticalDivider()
            
            HStack(spacing: 0) {
                
                VStack(spacing: 8) {
                    
                    let isOpen = subscriptionData.isOpen ?? false
                    
                    HStack(spacing: 0) {
                        Text("\(subscriptionData.currency ?? "") \(String(describing: subscriptionData.amount ?? 0.0))")
                            .font(.appSemiBold(24))
                            .foregroundColor(.navyBlueCTA700)
                        
                        Spacer()
                        HStack(spacing: 8) {
                            if isOpen == false {
                                if subscriptionData.relations!.count < 3
                                {
                                    ForEach(Array(subscriptionData.relations!.enumerated()), id: \.offset) { index, card in
                                        RelationView(name: card.name ?? "", color: card.color ?? "")
                                    }
                                }
                                else{
                                    ForEach(Array(subscriptionData.relations!.prefix(3).enumerated()), id: \.offset) { index, card in
                                        RelationView(name: card.name ?? "", color: card.color ?? "")
                                    }
                                    
                                    RelationView(isMore: true)
                                }
                            }
                        }
                    }
                    
                    
                    if isOpen == true {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(subscriptionData.relations!.enumerated()), id: \.offset) { index, relation in
                                
                                RelationView(name: relation.name ?? "", color: relation.color ?? "")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ForEach(Array(relation.plans!.enumerated()), id: \.offset) { index, plan in
                                    PlanDetailsView(
                                        image: plan.image ?? "",
                                        amount: "\(plan.amount ?? 0.0)",
                                        currency: plan.currency ?? "",
                                        card: plan.card ?? ""
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    else {
                        HStack(spacing: 0) {
                            if subscriptionData.plans!.count < 5
                            {
                                ForEach(Array(subscriptionData.plans!.enumerated()), id: \.offset) { index, card in
                                    PlanView(image: card.image ?? "")
                                        .offset(x: CGFloat(-10 * index), y: 0)
                                }
                            }
                            else{
                                ForEach(Array(subscriptionData.plans!.prefix(5).enumerated()), id: \.offset) { index, card in
                                    PlanView(image: card.image ?? "")
                                        .offset(x: CGFloat(-10 * index), y: 0)
                                }
                                
                                PlanView(isMore: true)
                                    .offset(x: CGFloat(-10 * 5), y: 0)
                            }
                            
                            Spacer()
                            
                            if subscriptionData.cardsCount == 1
                            {
                                Text("\(subscriptionData.cardsCount ?? 0) card")
                                    .font(.appRegular(12))
                                    .foregroundColor(.neutral900)
                                    .frame(minWidth: 60, alignment: .trailing)
                            }
                            else{
                                Text("\(subscriptionData.cardsCount ?? 0) cards")
                                    .font(.appRegular(12))
                                    .foregroundColor(.neutral900)
                                    .frame(minWidth: 60, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.leading, 16)
            .padding(.trailing, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: calculatedHeight(for: subscriptionData))
        .background(.fieldBG)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .cornerRadius(8)
        .padding(.bottom, 8)
    }
    func calculatedHeight(for subscriptionData: SubscriptionInfo) -> Double {
        guard subscriptionData.isOpen ?? false else {
            return 76
        }
        
        var heightValue = 0.0
        if let relations = subscriptionData.relations {
            for relation in relations {
                let plansCount = relation.plans?.count ?? 0
                heightValue += Double(32 + (32 * plansCount))
            }
        }
        
        return 52 + heightValue
    }
    func getDay(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let day = Calendar.current.component(.day, from: date)
        return String(day)
    }
}
struct DashedVerticalDivider: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
            }
            .stroke(Color.cardBorder, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
        }
        .frame(width: 1)
    }
}
struct DashedHorizontalDivider: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
            }
            .stroke(Color.cardBorder, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
        }
        .frame(height: 1)
    }
}
struct PlanView: View {
    var isMore          : Bool = false
    var image           : String?
    
    var body: some View {
        VStack
        {
            if isMore == true {
                Image("arrow-right-01")
            }
            else{
                Image(image!)
            }
        }
        .frame(width: 24, height: 24, alignment: .center)
        .background(Color.fieldBG)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .shadow(color: Color.dropShadowColor, radius: 2, x: 0, y: 2)
        .cornerRadius(12)
    }
}
struct RelationView: View {
    var isMore          : Bool = false
    var name            : String?
    var color           : String?
    
    var body: some View {
        VStack
        {
            if isMore == true {
                Text("...")
                    .font(.appRegular(24))
                    .foregroundColor(.primaryText)
            }
            else{
                Text(name!)
                    .font(.appRegular(12))
                    .foregroundColor(.fieldBG)
            }
        }
        .padding(.horizontal, isMore ? 0 : 8)
        .frame(height: 24)
        .background(isMore ? Color.clear : Color(hex: color!))
        .cornerRadius(4)
        
    }
}
struct PlanDetailsView: View {
    var image           : String?
    var amount          : String?
    var currency        : String?
    var card            : String?
    
    var body: some View {
        VStack
        {
            HStack(spacing: 8) {
                
                HStack
                {
                    Image(image!)
                }
                .frame(width: 24, height: 24, alignment: .center)
                .background(Color.fieldBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neutral300Border, lineWidth: 1)
                )
                .shadow(color: Color.dropShadowColor, radius: 2, x: 0, y: 2)
                .cornerRadius(12)
                Text("\(amount ?? "") \(currency ?? "")")
                    .font(.appRegular(12))
                    .foregroundColor(.neutralMain700)
                DashedHorizontalDivider()
                Text("on")
                    .font(.appRegular(12))
                    .foregroundColor(.neutral500)
                    .multilineTextAlignment(.trailing)
                Text(card ?? "")
                    .font(.appRegular(12))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.trailing)
            }
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 24)
        .background(Color.clear)
    }
}
