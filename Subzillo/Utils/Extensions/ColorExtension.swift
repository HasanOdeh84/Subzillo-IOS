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
//    static let black                    = Color(hex: "#000000")
//    static let white                    = Color(hex: "#FFFFFF")
//    
//    static let neutral100               = Color(hex: "#E3E3E3")
//    static let neutralBg100             = Color(hex: "#F6F9FB")
//    static let neutral2_200             = Color(hex: "#D1D1D1")
//    static let neutralDisabled200       = Color(hex: "#E9EFF4")
//    static let neutral300Border         = Color(hex: "#DAE2ED")
//    static let neutral400               = Color(hex: "#AAB9CC")
//    static let neutral2_500             = Color(hex: "#8C8C8C")
//    static let neutral500               = Color(hex: "#76869E")
//    static let neutral600               = Color(hex: "#6C757D")
//    static let neutral_600              = Color(hex: "#556075")
//    static let neutralMain700           = Color(hex: "#353F54")
//    static let neutral800               = Color(hex: "#222C40")
//    static let neutral900               = Color(hex: "#0F192E")

//    static let gray                     = Color(hex: "#4B5563")
//    static let underlineGray            = Color(hex: "#111827")
//    static let grayCapsule              = Color(hex: "#DFDFDF")
//    static let lineGray                 = Color(hex: "#BDBDBD")
//    static let borderColor              = Color(hex: "#E5E7EB")
//    static let dropShadowColor          = Color(hex: "#212529", alpha: 0.08)
//    static let linearGradient1          = Color(hex: "#F842E6")
//    static let linearGradient2          = Color(hex: "#005C9D")
//    static let linearGradient3          = Color(hex: "#A719DD")
//    static let linearGradient4          = Color(hex: "#623BD8")
//    static let green                    = Color(hex: "#9AC473")
//    static let orange                   = Color(hex: "#E9D2A1")
//    static let red                      = Color(hex: "#FF5959")
//    static let success                  = Color(hex: "#E1F4CB")
//    static let deepTerracotta400        = Color(hex: "#FF858E")
//    static let blue300                  = Color(hex: "#B8D2F8")
//    static let blue500                  = Color(hex: "#028DB4")
//    static let blue600                  = Color(hex: "#619BEE")
//    static let blueMain700              = Color(hex: "#4489EB")
//    static let gradientBlue             = Color(hex: "#8FCBF2")
//    static let navyBlueCTA700           = Color(hex: "#3260BB")
//    static let secondaryNavyBlue400     = Color(hex: "#70A3C4")
//    static let primeryBlue900           = Color(hex: "#20368A")
//    static let primeryBlue100           = Color(hex: "#F2F7FF")
//    static let redBadge                 = Color(hex: "#FF0000")
//    static let gradientPurple           = Color(hex: "#EA85E0")
//    static let secondaryPurple700       = Color(hex: "#5532A1")
//    static let purple501                = Color(hex: "#212529", alpha: 0.18)
//    static let purple500                = Color(hex: "#8766CE")
//    static let secondaryPurple500       = Color(hex: "#658B61")
//    static let secondaryPurple400       = Color(hex: "#A890DC")
//    static let secondaryPurple300       = Color(hex: "#B78BFF")
//    static let secondaryPurple600       = Color(hex: "#6B47B8")
//    static let cardBorder               = Color(hex: "#E8E8E8")
//    static let navyBlueCTA700               = Color(hex: "#3260BB")
//    static let systemInfoBlue               = Color(hex: "#0B5997")
        
//    static let neutral_2_500            = Color("appNeutral2_500")
//    static let neutral_2_200            = Color("appNeutral2_200")
//    static let appBg                    = Color("AppBackground")
//    static let black_white              = Color("appBlack_white")
    
    
    init(hex: String, alpha: CGFloat = 1.0) {
        let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(
            .sRGB,
            red: red,
            green: green,
            blue: blue,
            opacity: alpha
        )
        
    }

//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let alpha, red, green, blue: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (alpha, red, green, blue) = (1, 1, 1, 0)
//        }
//        
//        self.init(
//            .sRGB,
//            red: Double(red) / 255,
//            green: Double(green) / 255,
//            blue: Double(blue) / 255,
//            opacity: Double(alpha) / 255
//        )
//    }
}
