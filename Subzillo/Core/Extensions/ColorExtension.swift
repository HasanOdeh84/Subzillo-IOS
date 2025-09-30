//
//  ColorExtensions.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 01/09/25.
//

import SwiftUI

public extension Color {
    init(hex: String) {
        // Trim spaces and newlines
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        
        // Skip "#" if present
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let mask = 0x000000FF
        let red = Double((color >> 16) & UInt64(mask)) / 255.0
        let green = Double((color >> 8) & UInt64(mask)) / 255.0
        let blue = Double(color & UInt64(mask)) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
