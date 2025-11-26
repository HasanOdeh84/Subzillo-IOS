//
//  BottomToast.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 11/11/25.
//

import SwiftUI

struct BottomToastView: View {
    let message: String
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        Text(message)
            .font(.footnote)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(10)
            .transition(.opacity)
    }
}

class BottomToastManager: ObservableObject {
    @Published var currentToast     : Toast?
    @Published var isShowingToast   : Bool = false
    static let shared = BottomToastManager()
    private var hideTimer: Timer? // <- Timer for dismissal
    
    struct Toast: Identifiable {
        let id = UUID()
        let message: String
        let backgroundColor: Color
        let textColor: Color
        let duration: TimeInterval
        
        init(message: String, backgroundColor: Color = .black.opacity(0.7), textColor: Color = .white, duration: TimeInterval = 3) {
            self.message = message
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.duration = duration
        }
    }
    
    func showToast(message: String, backgroundColor: Color = .black.opacity(0.7), textColor: Color = .white, duration: TimeInterval = 2) {
        hideTimer?.invalidate()
        currentToast = Toast(message: message, backgroundColor: backgroundColor, textColor: textColor, duration: duration)
        isShowingToast = true
        
        hideTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.isShowingToast = false
            self?.currentToast = nil
        }
    }
}

struct BottomToastModifier: ViewModifier {
    @ObservedObject var toast = BottomToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if toast.isShowingToast, let msg = toast.currentToast?.message {
                VStack {
                    Spacer()
                    BottomToastView(message: msg, backgroundColor: toast.currentToast!.backgroundColor, textColor: toast.currentToast!.textColor)
                        .padding(.bottom, 20)
                }
                .zIndex(1)
            }
        }
    }
}
