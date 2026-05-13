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
    
    private let cornerRadius: CGFloat = 12
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: - First Segment Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedSegment = .first
                }
            } label: {
                segmentLabel(text: leftText, image: leftImage, isSelected: selectedSegment == .first, corners: [.topLeft, .bottomLeft])
            }
            
            // MARK: - Second Segment Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedSegment = .second
                }
            } label: {
                segmentLabel(text: rightText, image: rightImage, isSelected: selectedSegment == .second, corners: [.topRight, .bottomRight])
            }
        }
        .frame(height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(themeManager.accentTextColor, lineWidth: 1)
        )
//        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    @ViewBuilder
    private func segmentLabel(text: String, image: String, isSelected: Bool, corners: UIRectCorner) -> some View {
        HStack(spacing: 8) {
            Image(image)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
            
            Text(LocalizedStringKey(text))
                .font(.appSemiBold(15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(isSelected ? .white : themeManager.accentTextColor)
        .background(
            Group {
                if isSelected {
                    themeManager.accentGradient
                        .clipShape(RoundedCorner(radius: cornerRadius, corners: corners))
                } else {
                    Color.clear
                }
            }
        )
    }
}
