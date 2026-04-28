
//ToastManager.swift
//SwiftUI_project_setup
//
//Created by KSMACMINI-019 on 03/09/25.


import SwiftUI

enum ToastStyle {
  case error
  case success
  case info
}

extension ToastStyle {
    var themeColor: Color {
        switch self {
        case .error: return Color.deepTerracotta400
        case .info: return Color.neutral600
        case .success: return Color.success
        }
    }
    
    var iconFileName: String {
        switch self {
        case .info: return "info"
        case .success: return "check"
        case .error: return "warning"
        }
    }
    
    var textColor: Color {
        switch self {
        case .error: return Color.white
        case .info: return Color.white
        case .success: return Color.secondaryPurple500
        }
    }
}

struct ToastView: View {
    let message: String
    var style: ToastStyle
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(style.iconFileName)
                .padding(.leading,20)
            Text(message)
                .foregroundColor(style.textColor)
            Spacer()
        }
        .padding(.vertical,12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(style.themeColor)
        .cornerRadius(8)
        .padding(.horizontal, 20)
    }
}

class ToastManager: ObservableObject {
    @Published var currentToast     : Toast?
    @Published var isShowingToast   : Bool = false
    static let shared = ToastManager()
    private var hideTimer: Timer? // <- Timer for dismissal
    
    struct Toast: Identifiable {
        let id = UUID()
        let message: String
        var style: ToastStyle
        let duration: TimeInterval
        
        init(message: String,style: ToastStyle, duration: TimeInterval = 3) {
            self.message = message
            self.duration = duration
            self.style = style
        }
    }
    
    func showToast(message: String, style:ToastStyle = .success , duration: TimeInterval = 2) {
        hideTimer?.invalidate()
        currentToast = Toast(message: message,style: style, duration: duration)
        isShowingToast = true
        
        hideTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.isShowingToast = false
            self?.currentToast = nil
        }
    }
}

struct ToastModifier: ViewModifier {
    @ObservedObject var toast = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if toast.isShowingToast, let msg = toast.currentToast?.message, let style = toast.currentToast?.style {
                VStack {
                    ToastView(message: msg, style: style)
                        .padding(.top, 20)
                    Spacer()
                }
                .zIndex(1)
            }
        }
    }
}
