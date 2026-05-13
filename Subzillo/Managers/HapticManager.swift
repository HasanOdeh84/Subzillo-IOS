//
//  HapticManager.swift
//  Subzillo
//
//  Created by Antigravity on 11/05/26.
//

import UIKit

/// A global manager to handle all haptic feedback in the application.
/// Usage: HapticManager.shared.trigger(.impact(.light))
final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    enum HapticType {
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        case selection
    }
    
    func trigger(_ type: HapticType) {
        DispatchQueue.main.async {
            switch type {
            case .impact(let style):
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.prepare()
                generator.impactOccurred()
                
            case .notification(let type):
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(type)
                
            case .selection:
                let generator = UISelectionFeedbackGenerator()
                generator.prepare()
                generator.selectionChanged()
            }
        }
    }
}
