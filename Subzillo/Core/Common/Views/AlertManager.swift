//
//  AlertManager.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import SwiftUI

class AlertManager: ObservableObject {
    static let shared = AlertManager()
    
    @Published var isPresented      : Bool = false
    @Published var title            : String = ""
    @Published var message          : String = ""
    @Published var primaryButton    : Alert.Button = .default(Text("OK"))
    @Published var secondaryButton  : Alert.Button? = nil
    
    private init() {}
    
    func showAlert(
        title           : String,
        message         : String,
        okText          : String = "OK",
        cancelText      : String? = nil,   // if nil → only OK button
        isDestructive   : Bool = false,
        okAction        : (() -> Void)? = nil,
        cancelAction    : (() -> Void)? = nil
    ) {
        self.title      = title
        self.message    = message
        
        // primary button (OK)
        if isDestructive {
            self.primaryButton = .destructive(Text(okText)) {
                okAction?()
            }
        } else {
            self.primaryButton = .default(Text(okText)) {
                okAction?()
            }
        }
        
        // secondary button (Cancel)
        if let cancelText = cancelText {
            self.secondaryButton = .cancel(Text(cancelText)) {
                cancelAction?()
            }
        } else {
            self.secondaryButton = nil
        }
        
        self.isPresented = true
    }
}

struct AlertModifier: ViewModifier {
    @ObservedObject var alertManager = AlertManager.shared
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $alertManager.isPresented) {
                if let secondary = alertManager.secondaryButton {
                    return Alert(
                        title           : Text(alertManager.title),
                        message         : Text(alertManager.message),
                        primaryButton   : alertManager.primaryButton,
                        secondaryButton : secondary
                    )
                } else {
                    return Alert(
                        title           : Text(alertManager.title),
                        message         : Text(alertManager.message),
                        dismissButton   : alertManager.primaryButton
                    )
                }
            }
    }
}
