//
//  ColorExtensions.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 01/09/25.
//

import Foundation
import SwiftUI

extension Color {
    
    static let transparentColor         = Color(hex: "#00000000")
    static let black                    = Color(hex: "#000000")
    static let white                    = Color(hex: "#FFFFFF")
    
    static let blueMain700              = Color(hex: "#4489EB")
    static let navyBlueCTA700           = Color(hex: "#3260BB")
    static let neutral500               = Color(hex: "#76869E")
    static let neutral400               = Color(hex: "#AAB9CC")
    static let neutral200               = Color(hex: "#D1D1D1")
    static let neutralMain700           = Color(hex: "#353F54")
    static let gradientPurple           = Color(hex: "#EA85E0")
    static let gradientBlue             = Color(hex: "#8FCBF2")
    static let gray                     = Color(hex: "#4B5563")
    static let neutralDisabled200       = Color(hex: "#E9EFF4")
    static let neutralBg100             = Color(hex: "#F6F9FB")
    static let underlineGray            = Color(hex: "#111827")
    static let neutral100               = Color(hex: "#E3E3E3")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}


//import SwiftUI
//
//public extension Color {
//    init(hex: String) {
//        // Trim spaces and newlines
//        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        let scanner = Scanner(string: hex)
//        
//        // Skip "#" if present
//        if hex.hasPrefix("#") {
//            scanner.currentIndex = hex.index(after: hex.startIndex)
//        }
//        
//        var color: UInt64 = 0
//        scanner.scanHexInt64(&color)
//        
//        let mask = 0x000000FF
//        let red = Double((color >> 16) & UInt64(mask)) / 255.0
//        let green = Double((color >> 8) & UInt64(mask)) / 255.0
//        let blue = Double(color & UInt64(mask)) / 255.0
//        
//        self.init(red: red, green: green, blue: blue)
//    }
//}
