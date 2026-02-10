//
//  YouSavedBottomSheet.swift
//  Subzillo
//
//  Created by Antigravity on 02/02/26.
//

import SwiftUI

struct YouSavedBottomSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    var title           : String = "You saved $24.99"
    var subTitle        : String = "this month"
    var lastMonth       : String = "139.98"
    var thisMonth       : String = "$105.99"
    var isSave          = false
    var action          : () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Drag Indicator
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .frame(alignment: .center)
                .padding(.top, 24)
            
            VStack(spacing: 32) {
                // MARK: - Badge Icon
                Image("youSaved") 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                // MARK: - Title & Subtitle
                VStack(spacing: 12) {
                    Text(title)
                        .font(.appSemiBold(28))
                        .foregroundColor(Color.amethystmain700)
                    
                    Text(subTitle)
                        .font(.appSemiBold(18))
                        .foregroundColor(Color.neutralMain700)
                }
                
                if !isSave{
                    // MARK: - Comparison Cards
                    HStack(spacing: 24) {
                        comparisonCard(title: "Last Month", amount: lastMonth)
                        comparisonCard(title: "This Month", amount: thisMonth)
                    }
                    .padding(.horizontal, 17)
                    
                    // MARK: - Analytics Button
                    GradientBorderButton(
                        title       : "Check analytics",
                        isBtn       : true,
                        buttonImage : "chart-line-data-02",
                        action      : {
                            dismiss()
                            action()
                        }
                    )
                    .padding(.horizontal, 24)
                }
                
                if isSave{
                    VStack(spacing: 12) {
                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            Text("Pay")
                            
                            Text("$6.30")
                                .font(.appSemiBold(28))
                                .foregroundColor(Color.blueMain700)
                            
                            Text("instead of")
                            
                            Text("$14.99")
                                .font(.appSemiBold(28))
                                .foregroundColor(Color.blueMain700)
                            
                            Text("next month")
                        }
                        .font(.appRegular(14))
                        .foregroundColor(Color.neutral500)
                        
                        HStack(spacing: 4) {
                            Text("Expires in")
                            Text("13")
                                .font(.appRegular(14))
                                .foregroundColor(Color.disCardRed)
                            Text("days")
                        }
                        .font(.appRegular(14))
                        .foregroundColor(Color.neutral500)
                        
                        Text("Standard & Premium plans; same-country billing only")
                            .font(.appRegular(14))
                            .foregroundColor(Color.neutral500)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private func comparisonCard(title: String, amount: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.appRegular(14))
                .foregroundColor(Color.neutral500)
            
            Text(amount)
                .font(.appSemiBold(28))
                .foregroundColor(Color.navyBlueCTA700)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
