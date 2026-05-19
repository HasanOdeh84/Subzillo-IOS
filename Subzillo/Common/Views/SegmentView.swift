//
//  segmentView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 06/11/25.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct SegmentView: View {
    @Binding var selectedSegment: Segment?
    var leftImage: String
    var rightImage: String
    var leftText: String
    var rightText: String
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    private let cornerRadius: CGFloat = 12
    private let internalPadding: CGFloat = 6
    
    var body: some View {
        ZStack {
            // Background Container
            RoundedRectangle(cornerRadius: cornerRadius)
            //                .fill(colorScheme == .dark ? Color.surfaceLightFFFFFF.opacity(0.2) : Color.surfaceLightFFFFFF)
                .fill(Color.cardBgLoginFFFFFFFFFFFF)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.cardBorderE2E8F0E2E8F0, lineWidth: 1)
                )
            
            GeometryReader { geometry in
                let segmentWidth = geometry.size.width / 2
                
                // Selected Indicator
                RoundedRectangle(cornerRadius: cornerRadius - 2)
                    .fill(themeManager.accentGradient)
                    .frame(width: segmentWidth - (internalPadding * 2), height: geometry.size.height - (internalPadding * 2))
                    .offset(x: selectedSegment == .first ? internalPadding : segmentWidth + internalPadding, y: internalPadding)
                    .shadow(color: themeManager.accentShadowColor, radius: 4, x: 0, y: 2)
            }
            
            HStack(spacing: 0) {
                // First Segment
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedSegment = .first
                    }
                } label: {
                    Text(LocalizedStringKey(leftText))
                        .font(.geistSemiBold(13))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(selectedSegment == .first ? .white : themeManager.textPrimaryLight6_dark62)
                        .contentShape(Rectangle())
                }
                
                // Second Segment
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedSegment = .second
                    }
                } label: {
                    Text(LocalizedStringKey(rightText))
                        .font(.geistSemiBold(13))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(selectedSegment == .second ? .white : themeManager.textPrimaryLight6_dark62)
                        .contentShape(Rectangle())
                }
            }
        }
        .frame(height: 54)
    }
}
struct SegmentViewNew: View {
    
    @Binding var selectedSegment: Segment?
    
    var leftText: String
    var rightText: String
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            segmentButton(
                title: leftText,
                isSelected: selectedSegment == .first
            ) {
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedSegment = .first
                }
            }
            
            segmentButton(
                title: rightText,
                isSelected: selectedSegment == .second
            ) {
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedSegment = .second
                }
            }
        }
        .padding(3)
        .background(Color.whiteBlack)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    Color.black.opacity(0.08),
                    lineWidth: 1
                )
        )
    }
    
    
    // MARK: - Segment Button
    
    @ViewBuilder
    private func segmentButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            
            Text(title)
                .font(.geistSemiBold(11))
                .foregroundColor(
                    isSelected ?
                    .white :
                    Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                )
                .padding(.horizontal, 14)
                .frame(height: 30)
                .background(
                    Group {
                        if isSelected {
                            themeManager.accentGradient
                        } else {
                            Color.clear
                        }
                    }
                )
                .clipShape(Capsule())
                .shadow(
                    color: isSelected ?
                    themeManager.selectedAccent.senColor.opacity(0.55) :
                    .clear,
                    radius: 10,
                    x: 0,
                    y: 2
                )
        }
    }
}
