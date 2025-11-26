//
//  ViewExtensions.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 01/09/25.
//

import SwiftUI

extension View {
    func withAlert() -> some View {
        modifier(AlertModifier())
    }
    
    // Add this once at the root of your app UI.
    func withLoader() -> some View {
        modifier(LoaderModifier())
    }
    
    func withToast() -> some View {
        self.modifier(ToastModifier())
    }
    
    func withBottomToast() -> some View {
        self.modifier(BottomToastModifier())
    }
    
    //scroll issue when keyboard is open
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptive())
    }
    
    func dismissKeyboardOnBackgroundTap() -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
        )
    }
    
    //Done button for textfields
    func addDoneButtonToKeyboard() -> some View {
        self.modifier(DoneButtonToolbar())
    }
    
    func addDoneButton() -> some View {
        self.modifier(DoneButtonToolbar1())
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool,
                                          transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct DoneButtonToolbar: ViewModifier {
    @FocusState private var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
    }
}

struct DoneButtonToolbar1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                }
            }
    }
}
