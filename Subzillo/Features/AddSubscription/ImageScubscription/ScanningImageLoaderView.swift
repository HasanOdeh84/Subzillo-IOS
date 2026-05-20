//
//  ScanningImageLoaderView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 20/05/26.
//
import SwiftUI

struct ScanningImageLoaderView: View {
    
    @State private var parseP: CGFloat = 0
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Header
                HStack {
                    
                    Button {
                        
                    } label: {
                        HStack {
                            
                            if colorScheme == .dark
                            {
                                Image("back_gray")
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                            }
                            else{
                                Image("back_gray")
                            }
                        }
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(themeManager.white_white4)
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    themeManager.black_white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                    }
                    
                    Spacer()
                    
                    Text("Upload screenshot")
                        .font(.geistBold(16))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                        .tracking(-0.3)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 40,
                               height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 100)
                
                // MARK: - Scanner Card
                VStack(spacing: 30) {
                    
                    ZStack(alignment: .top) {
                        
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                themeManager.white_white4
                            )
                            .overlay {
                                
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        themeManager.black_white.opacity(0.08),
                                        lineWidth: 1
                                    )
                            }
                        
                        
                        VStack(alignment: .leading,
                               spacing: 10) {
                            
                            Text("SMS · Your Bank")
                                .font(
                                    .system(size: 10,
                                            weight: .medium,
                                            design: .monospaced)
                                )
                                .foregroundColor(
                                    Color.black.opacity(0.45)
                                )
                            
                            
                            HStack(spacing: 0) {
                                Text("Payment of ")
                                
                                Text("$22.99")
                                    .padding(.horizontal, 4)
                                    .background(
                                        Color.purple.opacity(0.15)
                                    )
                                
                                Text(" to ")
                                
                                Text("NETFLIX")
                                    .padding(.horizontal, 4)
                                    .background(
                                        Color.purple.opacity(0.15)
                                    )
                                
                                Text(" on Visa ••4829")
                            }
                            .font(.system(size: 13))
                            .foregroundColor(
                                Color.black
                            )
                            .lineSpacing(4)
                            
                            
                            Text("Card ending 4829 · 09:41")
                                .font(
                                    .system(size: 11,
                                            weight: .medium,
                                            design: .monospaced)
                                )
                                .foregroundColor(
                                    Color.black.opacity(0.55)
                                )
                        }
                        .padding(16)
                        
                        
                        // MARK: - Laser
                        LinearGradient(
                            colors: [
                                .clear,
                                themeManager.selectedAccent.primaryColor,
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 3)
                        .shadow(color: themeManager.selectedAccent.primaryColor,
                                radius: 12)
                        .offset(y: parseP)
                        .animation(
                            .linear(duration: 2)
                                .repeatForever(autoreverses: false),
                            value: parseP
                        )
                        
                        
                        // MARK: - Highlight Boxes
                        if parseP > 70 {
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    themeManager.selectedAccent.primaryColor.opacity(0.12)
                                )
                                .overlay {
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(
                                            themeManager.selectedAccent.primaryColor,
                                            lineWidth: 1.5
                                        )
                                }
                                .frame(width: 62,
                                       height: 20)
                                .offset(x: -28,
                                        y: 68)
                        }
                        
                        
                        if parseP > 120 {
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    themeManager.selectedAccent.primaryColor.opacity(0.12)
                                )
                                .overlay {
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(
                                            themeManager.selectedAccent.primaryColor,
                                            lineWidth: 1.5
                                        )
                                }
                                .frame(width: 70,
                                       height: 20)
                                .offset(x: 58,
                                        y: 68)
                        }
                    }
                    .frame(width: 260,
                           height: 325)
                    
                    
                    // MARK: - Texts
                    VStack(spacing: 6) {
                        
                        Text("Reading the image")
                            .font(.geistBold(22))
                            .foregroundColor(
                                themeManager.black_white
                            )
                            .tracking(-0.8)
                        
                        
                        Text(
                            parseP < 70
                            ? "OCR analysis…"
                            : parseP < 140
                            ? "Extracting amount & vendor…"
                            : "Matching provider…"
                        )
                        .font(.jetBrainsMedium(12))
                        .foregroundColor(
                            themeManager.black_white.opacity(0.55)
                        )
                    }
                    
                    
                    // MARK: - Progress
                    ZStack(alignment: .leading) {
                        
                        Capsule()
                            .fill(
                                themeManager.black_white.opacity(0.08)
                            )
                            .frame(height: 3)
                        
                        
                        themeManager.accentGradient
                        .frame(
                            width: max(parseP * 1.2, 10),
                            height: 3
                        )
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                }
                
                
                Spacer()
            }
        }
        .applyAppBackground()
        .onAppear {
            
            withAnimation(
                .linear(duration: 3)
                .repeatForever(autoreverses: true)
            ) {
                parseP = 260
            }
        }
    }
}
