//
//  ScanningImageLoaderView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 20/05/26.
//
import SwiftUI

struct ScanningImageLoaderView: View {
    
    var selectedImage                   : UIImage? = nil
    @State private var parseP           : CGFloat = 0
    @EnvironmentObject var themeManager : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack{
            // MARK: - Header
            HStack {
                CircleBackButton {
                    AppIntentRouter.shared.pop()
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
            .padding(.top, 10)
            .padding(.bottom, 100)
            
            ScrollView{
                ZStack {
                    VStack(spacing: 0) {
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
                                    Image(uiImage: selectedImage!)
                                        .resizable()
                                        .frame(width: 260,
                                               height: 325)
                                }
                                
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
                        .padding(.top, 10)
                        Spacer()
                    }
                }
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
        .applyAppBackground()
    }
}
