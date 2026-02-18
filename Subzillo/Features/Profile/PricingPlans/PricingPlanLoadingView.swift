//
//  PricingPlanLoadingView.swift
//  Subzillo
//
//  Created by Antigravity on 18/02/26.
//

import SwiftUI

enum PricingPlanProcessingType {
    case loading
    case failed
}

struct PricingPlanLoadingView: View {
    
    var type: PricingPlanProcessingType
    var onTryAgain: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Semi-transparent background to dim the underlying view
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
                .background(
                    BlurView(style: .systemUltraThinMaterialLight)
                        .opacity(0.8)
                )
            
            VStack(spacing: 24) {
                if type == .loading {
                    loadingContent
                } else {
                    failedContent
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
            .frame(maxWidth: 340)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        }
    }
    
    // MARK: - Loading Content
    private var loadingContent: some View {
        VStack(spacing: 12) {
            Text("Loading...")
                .font(.appBold(24))
                .foregroundColor(Color.primaryBlue800)
            
            Text("Please wait we load the screen for you.")
                .font(.appRegular(16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Failed Content
    private var failedContent: some View {
        VStack(spacing: 20) {
            // Red circle with X
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "xmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("Payment Failed")
                    .font(.appBold(24))
                    .foregroundColor(Color.primaryBlue800)
                
                Text("Oops! Something went wrong, please try again or use a different payment method")
                    .font(.appRegular(16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 10)
            }
            
            CustomButton(title: "Try Again",
                         background: Color.primaryBlue800,
                         textColor: .white,
                         height: 52,
                         action: {
                onTryAgain?()
            })
            .padding(.top, 8)
        }
    }
}

// Helper for blur effect if not already defined
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all)
        PricingPlanLoadingView(type: .failed)
    }
}
