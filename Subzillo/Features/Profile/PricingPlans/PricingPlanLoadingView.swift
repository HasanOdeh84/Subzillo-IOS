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
            // Full screen blurred background covering everything
            BlurView(style: .systemUltraThinMaterialLight)
                .ignoresSafeArea()
            
//            Color.white.opacity(0.8)
//                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                if type == .loading {
                    loadingContent
                } else {
                    failedContent
                }
            }
            .padding(.horizontal, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Loading Content
    private var loadingContent: some View {
        VStack(spacing: 12) {
            Text("Loading...")
                .font(.appBold(20))
                .foregroundColor(Color.primaryBlue800)
            
            Text("Please wait")
                .font(.appMedium(16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Failed Content
    private var failedContent: some View {
        VStack(spacing: 20) {
            LottieView(name: "payment_failure")
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                .padding(.bottom, -10)
            
            VStack(spacing: 12) {
                Text("Payment Failed")
                    .font(.appBold(20))
                    .foregroundColor(Color.primaryBlue800)
                
                Text("Oops! Something went wrong, please try again or use a different payment method")
                    .font(.appMedium(16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 10)
            }
            
            CustomButton(title      : "Try Again",
                         background : Color.primaryBlue800,
                         textColor  : .white,
                         height     : 52,
                         action     : {
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
