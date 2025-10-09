//
//  LoaderManager.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop
    
    private let animationView = LottieAnimationView()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()
        
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}


// MARK: - Global Loader Store (Singleton)

final class LoaderManager: ObservableObject {
    
    static let shared           = LoaderManager()
    @Published var isShowing    = false
    @Published var text         : String? = nil
    var animationName           = "splash"
    // Prevents flicker when multiple parts of the app show/hide quickly
    private var counter         = 0
    
    func showLoader(text: String? = nil) {
        counter += 1
        self.text = text
        self.isShowing = true
    }
    
    func hideLoader() {
        counter = max(0, counter - 1)
        if counter == 0 {
            self.text = nil
            self.isShowing = false
        }
    }
    
    // Use carefully to immediately clear the loader regardless of counter.
    func forceHideLoader() {
        counter = 0
        text = nil
        isShowing = false
    }
}

// MARK: - Overlay UI
private struct LoaderOverlay: View {
    @ObservedObject private var loader = LoaderManager.shared
    
    var body: some View {
        Group {
            if loader.isShowing {
                ZStack {
                    // Transparent background
                    ColorConstants.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    VStack() {
                        // Lottie Animation
                        LottieView(name: loader.animationName, loopMode: .loop)
                            .frame(width: 200, height: 200)
                        
                        // Optional label
                        if let message = loader.text, !message.isEmpty {
                            Text(message)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(ColorConstants.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                //                .animation(.easeInOut(duration: 0.2), value: loader.isShowing)
            }
        }
        // Ensures this overlay always sits above content
        //        .allowsHitTesting(loader.isShowing) // blocks touches when showing
    }
}

// MARK: - View Modifier + Convenience
struct LoaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            LoaderOverlay()
        }
    }
}
