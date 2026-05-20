//
//  InboxScanningView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 20/05/26.
//

import SwiftUI

struct InboxScanningView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var activeIndex = 2
    @State private var animateTags = false
    
    let emails = [
        ("Notion", "Invoice — Plus workspace"),
        ("Google", "Security alert"),
        ("HBO Max", "Your receipt · Ad-free"),
        ("Figma", "Professional plan renewed"),
        ("The New York Times", "All Access · April")
    ]
    
    let tags = ["Spotify", "OpenAI", "Adobe", "Apple"]
    
    var body: some View {
        
        ZStack {
            
            backgroundView
            
            VStack(spacing: 0) {
                
                // MARK: Header
                
                HStack {
                    
                    Button {
                        
                    } label: {
                        
                        ZStack {
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                            
                            Circle()
                                .stroke(
                                    Color.black.opacity(0.08),
                                    lineWidth: 1
                                )
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                            .shadow(color: .green.opacity(0.8), radius: 6)
                        
                        Text("GMAIL · READ-ONLY")
                            .font(
                                .system(
                                    size: 11,
                                    weight: .medium,
                                    design: .monospaced
                                )
                            )
                            .tracking(1.5)
                            .foregroundColor(Color.green.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                
                // MARK: Title
                
                VStack(spacing: 6) {
                    
                    HStack(spacing: 0) {
                        Text("Scanning your ")
                            .foregroundColor(.black)
                        
                        Text("inbox")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#A719DD"),
                                        Color(hex: "#7C5CFF"),
                                        Color(hex: "#4489EB")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .italic()
                    }
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    
                    Text(emails[activeIndex].0 + " — " + emails[activeIndex].1)
                        .font(
                            .system(
                                size: 12,
                                weight: .medium,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            Color.black.opacity(0.6)
                        )
                        .lineLimit(1)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                
                
                // MARK: Scanner
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    VStack(spacing: 6) {
                        
                        ForEach(Array(emails.enumerated()), id: \.offset) { index, item in
                            
                            emailCard(
                                title: item.0,
                                subtitle: item.1,
                                isActive: index == activeIndex
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    
                    // Scanner Glow
                    
                    VStack {
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color(hex: "#7C5CFF").opacity(0.2),
                                        Color(hex: "#7C5CFF").opacity(0.45),
                                        Color(hex: "#7C5CFF").opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 60)
                            .overlay {
                                
                                Rectangle()
                                    .fill(Color(hex: "#7C5CFF"))
                                    .frame(height: 1)
                                    .shadow(
                                        color: Color(hex: "#7C5CFF"),
                                        radius: 14
                                    )
                            }
                        
                        Spacer()
                    }
                    
                    
                    // Corner Marks
                    
                    scannerCorners
                    
                    
                    // Flying Tags
                    
                    VStack {
                        
                        HStack {
                            
                            Spacer()
                            
                            VStack(spacing: 8) {
                                
                                ForEach(Array(tags.enumerated()), id: \.offset) { index, item in
                                    
                                    tagView(title: item)
                                        .offset(
                                            x: animateTags ? -12 : 0,
                                            y: animateTags ? CGFloat(-20 - (index * 12)) : 0
                                        )
                                        .opacity(animateTags ? 0 : 1)
                                        .animation(
                                            .easeOut(duration: 1.4)
                                            .repeatForever(autoreverses: false)
                                            .delay(Double(index) * 0.15),
                                            value: animateTags
                                        )
                                }
                            }
                            .padding(.top, 18)
                            .padding(.trailing, 12)
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: 240)
                .padding(.horizontal, 24)
                .padding(.top, 18)
                
                
                // MARK: Stats
                
                HStack(spacing: 12) {
                    
                    statCard(
                        title: "FOUND",
                        value: "5",
                        gradient: true
                    )
                    
                    statCard(
                        title: "MONTHLY",
                        value: "$123",
                        gradient: false
                    )
                    
                    statCard(
                        title: "SCANNED",
                        value: "10",
                        gradient: false
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                
               // Spacer()
                Color.clear
                    .frame(width: 40, height: 40)
                
                // MARK: Progress
                
                VStack(spacing: 10) {
                    
                    GeometryReader { geo in
                        
                        ZStack(alignment: .leading) {
                            
                            Capsule()
                                .fill(
                                    Color.black.opacity(0.14)
                                )
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#A719DD"),
                                            Color(hex: "#7C5CFF"),
                                            Color(hex: "#4489EB")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width)
                                .shadow(
                                    color: Color(hex: "#7C5CFF").opacity(0.5),
                                    radius: 10
                                )
                        }
                    }
                    .frame(height: 4)
                    
                    
                    HStack {
                        
                        Text("END-TO-END ENCRYPTED")
                        
                        Spacer()
                        
                        Text("100%")
                    }
                    .font(
                        .system(
                            size: 10,
                            weight: .medium,
                            design: .monospaced
                        )
                    )
                    .tracking(1)
                    .foregroundColor(
                        Color.black.opacity(0.35)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
                Spacer()
            }
        }
        .applyAppBackground()
        .ignoresSafeArea()
        .onAppear {
            
            animateTags = true
            
            Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { _ in
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    
                    activeIndex =
                    (activeIndex + 1) % emails.count
                }
            }
        }
    }
}


// MARK: - Email Card

extension InboxScanningView {
    
    func emailCard(
        title: String,
        subtitle: String,
        isActive: Bool
    ) -> some View {
        
        HStack(spacing: 10) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        isActive
                        ? LinearGradient(
                            colors: [
                                Color(hex: "#A719DD"),
                                Color(hex: "#7C5CFF"),
                                Color(hex: "#4489EB")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [
                                Color(hex: "#F1F2F7")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 22, height: 22)
                
                Image(systemName: "envelope")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(
                        isActive ? .white : .black.opacity(0.6)
                    )
            }
            
            VStack(alignment: .leading, spacing: 1) {
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(
                        Color.black.opacity(0.6)
                    )
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isActive {
                
                Text("MATCH")
                    .font(
                        .system(
                            size: 9,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Color.green.opacity(0.13)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 5)
                    )
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(
            isActive
            ? Color(hex: "#F1F2F7")
            : Color.white
        )
        .overlay {
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isActive
                    ? Color(hex: "#7C5CFF")
                    : Color.black.opacity(0.08),
                    lineWidth: 1
                )
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .scaleEffect(isActive ? 1 : 0.95)
        .opacity(isActive ? 1 : 0.45)
        .shadow(
            color: isActive
            ? Color(hex: "#7C5CFF").opacity(0.4)
            : .clear,
            radius: 12
        )
    }
}


// MARK: - Tag

extension InboxScanningView {
    
    func tagView(title: String) -> some View {
        
        HStack(spacing: 4) {
            
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
            
            Text(title)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#A719DD"),
                    Color(hex: "#7C5CFF"),
                    Color(hex: "#4489EB")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .shadow(
            color: Color(hex: "#7C5CFF").opacity(0.5),
            radius: 10
        )
    }
}


// MARK: - Stats

extension InboxScanningView {
    
    func statCard(
        title: String,
        value: String,
        gradient: Bool
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(title)
                .font(
                    .system(
                        size: 9,
                        weight: .medium,
                        design: .monospaced
                    )
                )
                .tracking(1)
                .foregroundColor(
                    Color.black.opacity(0.6)
                )
            
            if gradient {
                
                Text(value)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "#A719DD"),
                                Color(hex: "#7C5CFF"),
                                Color(hex: "#4489EB")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                
                Text(value)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.black)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .overlay {
            
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.black.opacity(0.08),
                    lineWidth: 1
                )
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}


// MARK: - Scanner Corners

extension InboxScanningView {
    
    var scannerCorners: some View {
        
        ZStack {
            
            VStack {
                
                HStack {
                    scannerCorner(top: true, left: true)
                    Spacer()
                    scannerCorner(top: true, left: false)
                }
                
                Spacer()
                
                HStack {
                    scannerCorner(top: false, left: true)
                    Spacer()
                    scannerCorner(top: false, left: false)
                }
            }
            .padding(16)
        }
    }
    
    func scannerCorner(
        top: Bool,
        left: Bool
    ) -> some View {
        
        VStack(spacing: 0) {
            
            if top {
                
                Rectangle()
                    .fill(Color(hex: "#7C5CFF"))
                    .frame(width: 14, height: 2)
                
                HStack(spacing: 0) {
                    
                    Rectangle()
                        .fill(Color(hex: "#7C5CFF"))
                        .frame(width: 2, height: 12)
                    
                    Spacer()
                }
            } else {
                
                HStack(spacing: 0) {
                    
                    Rectangle()
                        .fill(Color(hex: "#7C5CFF"))
                        .frame(width: 2, height: 12)
                    
                    Spacer()
                }
                
                Rectangle()
                    .fill(Color(hex: "#7C5CFF"))
                    .frame(width: 14, height: 2)
            }
        }
        .frame(width: 14, height: 14)
        .scaleEffect(x: left ? 1 : -1)
    }
}


// MARK: - Background

extension InboxScanningView {
    
    var backgroundView: some View {
        
        ZStack {
            
            Color(hex: "#F7F7F9")
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#A719DD").opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: 500)
                .offset(x: -120, y: -260)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#4489EB").opacity(0.04),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: 450)
                .offset(x: 160, y: 340)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#7C5CFF").opacity(0.03),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .offset(x: 120, y: 0)
                .blur(radius: 50)
        }
    }
}


// MARK: - HEX

extension Color {
    
    init(hex: String) {
        
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        
        switch hex.count {
            
        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
            
        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
            
        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
            
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
