//
//  Untitled.swift
//  Subzillo
//
//  Created by Ratna Kavya on 15/05/26.
//

import SwiftUI

// MARK: - Stat Card

struct StatCardNew: View {
    
    let title: String
    let value: String
    var suffix: String? = nil
    @EnvironmentObject var themeManager     : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(title)
                .font(.jetBrainsRegular(9))
                .tracking(1.2)
                .foregroundColor(
                    Color("TextPrimary_ 0E101A_F4F1FB")
                        .opacity(0.6)
                )
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                
                Text(value)
                    .font(.geistSemiBold(18))
                    .tracking(-0.5)
                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                
                if let suffix {
                    Text(suffix)
                        .font(.jetBrainsRegular(10))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                                .opacity(0.6)
                        )
                }
            }
            .padding(.top, 4)
            
            Text(" ")
                .foregroundColor(
                    Color("TextPrimary_ 0E101A_F4F1FB")
                        .opacity(0.36)
                )
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
        .background(colorScheme == .dark ? themeManager.white_white4 : Color.surfaceHiLightF1F2F7)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color("TextPrimary_ 0E101A_F4F1FB")
                        .opacity(0.08),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Cheapest Card

struct HighestStatCard: View {
    var data : highestActiveSubscription?
    @EnvironmentObject var themeManager     : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let formattedAmount = String(format: "%.2f", data?.amount ?? 0.0)
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("HIGHEST")
                .font(.jetBrainsRegular(9))
                .tracking(1.2)
                .foregroundColor(
                    Color("TextPrimary_ 0E101A_F4F1FB")
                        .opacity(0.6)
                )
            
            Text("\(data?.currencySymbol ?? "") \(formattedAmount)")
                .font(.geistSemiBold(18))
                .tracking(-0.5)
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                .padding(.top, 4)
            
            Text(data?.serviceName ?? "")
                .font(.jetBrainsRegular(9))
                .foregroundColor(
                    Color("TextPrimary_ 0E101A_F4F1FB")
                        .opacity(0.36)
                )
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
        .background(colorScheme == .dark ? themeManager.white_white4 : Color.surfaceHiLightF1F2F7)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color("TextPrimary_ 0E101A_F4F1FB")
                        .opacity(0.08),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
struct DonutChartViewNew: View {
    
    let items: [CategoryItem]
    
    private var total: Double {
        items.reduce(0) { $0 + Double($1.amount) }
    }
    
    var body: some View {
        
        ZStack {
            
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                
                Circle()
                    .trim(
                        from: startTrim(for: index),
                        to: endTrim(for: index)
                    )
                    .stroke(
                        Color(hex: item.color),
                        style: StrokeStyle(
                            lineWidth: 16,
                            lineCap: .butt
                        )
                    )
            }
        }
        .rotationEffect(.degrees(-90))
        .frame(width: 106, height: 106)
    }
    
    // MARK: - Helpers
    
    private func startTrim(for index: Int) -> CGFloat {
        
        let previous = items
            .prefix(index)
            .reduce(0) { $0 + Double($1.amount) }
        
        return CGFloat(previous / total)
    }
    
    private func endTrim(for index: Int) -> CGFloat {
        
        let current = items
            .prefix(index + 1)
            .reduce(0) { $0 + Double($1.amount) }
        
        return CGFloat(current / total)
    }
}

// MARK: - Row

struct SubscriptionRowNew: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager     : ThemeManager
    let item: SubscriptionItemNew
    let delay: Double
    
    @State private var animateBar = false
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            // MARK: - Icon
            
            ZStack {
                
               /* RoundedRectangle(cornerRadius: 8.4)
                    .fill()
                
                Text(item.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(item.iconColor)*/
                
                AvatarView(
                    serviceName: item.name,
                    serviceLogo: item.serviceLogo,
                    size: 30,
                    cornerRadius: 8.4,
                    fromPreview: false,
                    isShadow: false
                )
                
            }
            .frame(width: 30, height: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 8.4)
                    .stroke(
                        themeManager.black_white.opacity(0.06),
                        lineWidth: 0.5
                    )
            )
            
            
            // MARK: - Content
            
            VStack(spacing: 5) {
                
                HStack {
                    
                    Text(item.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    
                    Spacer()
                    
                    Text("\(item.currencySymbol)\(item.amountStr)")
                        .font(.jetBrainsRegular(12))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                                .opacity(0.6)
                        )
                }
                
                
                // MARK: - Progress
                
                GeometryReader { geo in
                    
                    ZStack(alignment: .leading) {
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(colorScheme == .dark ? themeManager.white_white4 : Color.surfaceHiLightF1F2F7)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                themeManager.accentGradient
                            )
                            .frame(
                                width: animateBar
                                ? geo.size.width * CGFloat(item.progress)
                                : 0
                            )
                    }
                }
                .frame(height: 6)
            }
        }
        .onAppear {
            
            withAnimation(
                .interpolatingSpring(
                    stiffness: 120,
                    damping: 14
                )
                .delay(delay)
            ) {
                animateBar = true
            }
        }
    }
    
    private func amountText(_ value: Double) -> String {
        
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "$\(Int(value))"
        } else {
            return String(format: "$%.2f", value)
        }
    }
}

// MARK: - Row

struct UpcomingRow: View {
    @EnvironmentObject var themeManager     : ThemeManager
    let item: UpcomingCharge
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            AvatarView(
                serviceName: item.name,
                serviceLogo: item.icon,
                size: 32,
                cornerRadius: 8.4,
                fromPreview: false,
                isShadow: false
            )
            
            VStack(alignment: .leading, spacing: 1) {
                
                Text(item.name)
                    .font(.geistSemiBold(13))
                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                
                Text(item.subtitle)
                    .font(.jetBrainsRegular(10))
                    .foregroundColor(
                        Color("TextPrimary_ 0E101A_F4F1FB")
                            .opacity(0.6)
                    )
            }
            
            Spacer()
            
            Text("\(item.currencySymbol)\(item.amount)")
                .font(.geistSemiBold(13))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(themeManager.white_white4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color("TextPrimary_ 0E101A_F4F1FB")
                        .opacity(0.08),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.04),
            radius: 1,
            x: 0,
            y: 1
        )
        .shadow(
            color: Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.04),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Model

struct UpcomingCharge: Identifiable {
    
    let id = UUID()
    
    let subscriptionId: String
    let name: String
    let subtitle: String
    let amount: String
    
    var iconBackground: Color? = nil
    var gradient: LinearGradient? = nil
    
    let icon: String
    let planName: String
    let billingCycleShortLabel: String
    let currencySymbol: String
}
