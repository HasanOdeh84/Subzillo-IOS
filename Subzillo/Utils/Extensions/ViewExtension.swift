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
    
    //scroll issue when keyboard is open
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptive())
    }
    
    //Done button for textfields
    func addDoneButtonToKeyboard() -> some View {
        self.modifier(DoneButtonToolbar())
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
                    }
                }
            }
    }
}
