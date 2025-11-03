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
    static let neutral2_500             = Color(hex: "#8C8C8C")
    static let neutral500               = Color(hex: "#76869E")
    static let neutral900               = Color(hex: "#0F192E")
    static let neutral400               = Color(hex: "#AAB9CC")
    static let neutral2_200             = Color(hex: "#D1D1D1")
    static let neutralMain700           = Color(hex: "#353F54")
    static let gradientPurple           = Color(hex: "#EA85E0")
    static let gradientBlue             = Color(hex: "#8FCBF2")
    static let gray                     = Color(hex: "#4B5563")
    static let neutralDisabled200       = Color(hex: "#E9EFF4")
    static let neutralBg100             = Color(hex: "#F6F9FB")
    static let underlineGray            = Color(hex: "#111827")
    static let neutral100               = Color(hex: "#E3E3E3")
    static let neutral300Border         = Color(hex: "#DAE2ED")
    static let blue500                  = Color(hex: "#028DB4")
    static let grayCapsule              = Color(hex: "#DFDFDF")
    
    static let purple500                = Color(hex: "#8766CE")
    static let green                    = Color(hex: "#9AC473")
    static let orange                   = Color(hex: "#E9D2A1")
    static let red                      = Color(hex: "#FF5959")
    
    static let neutral_2_500            = Color("appNeutral2_500")
    static let neutral_2_200            = Color("appNeutral2_200")
    static let appBg                    = Color("AppBackground")
    static let black_white              = Color("appBlack_white")

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
