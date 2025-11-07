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
    
    @Binding var selectedSegment    : Segment
    var leftImage                   : String
    var rightImage                  : String
    var leftText                    : String
    var rightText                   : String
    
    var body: some View {
        HStack(spacing: 0) {
            
            // MARK: - List View Button
            Button {
                selectedSegment = .first
            } label: {
                HStack(spacing: 5) {
                    Image(leftImage)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 17, height: 17)
                        .foregroundColor(selectedSegment == .first ? .neutralDisabled200 : .navyBlueCTA700)
                    
                    Text(LocalizedStringKey(leftText))
                        .font(.appSemiBold(14))
                        .foregroundColor(selectedSegment == .first ? Color.black_white : .navyBlueCTA700)
                }
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(
                    Group {
                        if selectedSegment == .first {
                            Color.navyBlueCTA700
                                .clipShape(RoundedCorner(radius: 8, corners: [.topLeft, .bottomLeft]))
                        } else {
                            Color.clear
                        }
                    }
                )
                .overlay(
                    // keep the stroke visually inside by padding the shape inward
                    RoundedCorner(radius: 8, corners: [.topLeft, .bottomLeft])
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .padding(1)                  // <- keeps stroke inside bounds
                        .opacity(selectedSegment == .first ? 0 : 1) // <- hide border when selected (without changing layout)
                )
            }
            
            // MARK: - Calendar View Button
            Button {
                selectedSegment = .second
            } label: {
                HStack(spacing: 5) {
                    Image(rightImage)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 17, height: 17)
                        .foregroundColor(selectedSegment == .second ? .neutralDisabled200 : .navyBlueCTA700)
                    
                    Text(LocalizedStringKey(rightText))
                        .font(.appSemiBold(14))
                        .foregroundColor(selectedSegment == .second ? Color.black_white : .navyBlueCTA700)
                }
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(
                    Group {
                        if selectedSegment == .second {
                            Color.navyBlueCTA700
                                .clipShape(RoundedCorner(radius: 8, corners: [.topRight, .bottomRight]))
                        } else {
                            Color.clear
                        }
                    }
                )
                .overlay(
                    // keep the stroke visually inside by padding the shape inward
                    RoundedCorner(radius: 8, corners: [.topRight, .bottomRight])
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .padding(1)                  // <- keeps stroke inside bounds
                        .opacity(selectedSegment == .second ? 0 : 1) // <- hide border when selected (without changing layout)
                )
            }
        }
        .frame(height: 40)
    }
}
