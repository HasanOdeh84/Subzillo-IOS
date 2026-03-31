//
//  LoaderManager.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var name            : String
    var loopMode        : LottieLoopMode = .loop
    var isAspectFit     = true
    
    private let animationView = LottieAnimationView()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = isAspectFit ? .scaleAspectFit : .scaleAspectFill
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
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

//struct LottieViewPlayPause: UIViewRepresentable {
//    var name            : String
//    var loopMode        : LottieLoopMode = .loop
//    var isAspectFit     = true
//    @Binding var play   : Bool
//    
//    private let animationView = LottieAnimationView()
//    
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: .zero)
//        
//        animationView.animation = LottieAnimation.named(name)
//        animationView.contentMode = isAspectFit ? .scaleAspectFit : .scaleAspectFill
//        animationView.loopMode = loopMode
////        animationView.play()
//        
//        view.addSubview(animationView)
//        animationView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
//            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
//            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        if play {
//            animationView.play()
//        } else {
//            animationView.stop()
//        }
//    }
//}

struct LottieViewPlayPause: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop
    var isAspectFit: Bool = true
    @Binding var play: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = isAspectFit ? .scaleAspectFit : .scaleAspectFill
        animationView.loopMode = loopMode
        
        context.coordinator.animationView = animationView
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if play {
            uiView.play()
        } else {
            uiView.pause()   // ⬅ stop() resets to frame 0; pause keeps last frame
        }
    }
    
    class Coordinator {
        var animationView: LottieAnimationView?
    }
}

// MARK: - Global Loader Store (Singleton)

final class LoaderManager: ObservableObject {
    
    static let shared           = LoaderManager()
    @Published var isShowing    = false
    @Published var text         : String? = nil
    var animationName           = "subzillo_loader"
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
    @ObservedObject private var loader  = LoaderManager.shared
    
    var body: some View {
        ZStack {
            // Invisible shield to block interactions while loader is active
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .opacity(loader.isShowing ? 1 : 0)
            
            VStack(spacing: 12) {
                // Lottie Animation
                LottieView(name: loader.animationName, loopMode: .loop)
                    .frame(width: 100, height: 100)
                
                // Optional label
                if let message = loader.text, !message.isEmpty {
                    Text(message)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .opacity(loader.isShowing ? 1 : 0)
            .scaleEffect(loader.isShowing ? 1.0 : 0.8)
        }
//        .animation(.easeInOut(duration: 0.3), value: loader.isShowing)
        .allowsHitTesting(loader.isShowing)
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
