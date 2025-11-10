//
//  KeyboardManager.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 08/11/25.
//

import SwiftUI
import Combine

final class KeyboardManager: ObservableObject {
    @Published var height: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat.zero }
        
        Publishers.Merge(willShow, willHide)
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.height = $0 }
            .store(in: &cancellables)
    }
}

struct KeyboardAdaptive: ViewModifier {
    @StateObject private var keyboard = KeyboardManager()
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboard.height)
            .animation(.easeOut(duration: 0.25), value: keyboard.height)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
    }
}
