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
}
