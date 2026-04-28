//
//  FontExtension.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 02/09/25.
//

import SwiftUI

extension Font {
    // MARK: - Inter Fonts
    static func appThin(_ size: CGFloat) -> Font {
        .custom("Roboto-Thin", size: size)
    }
    static func appExtraLight(_ size: CGFloat) -> Font {
        .custom("Roboto-ExtraLight", size: size)
    }
    static func appLight(_ size: CGFloat) -> Font {
        .custom("Roboto-Light", size: size)
    }
    static func appRegular(_ size: CGFloat) -> Font {
        .custom("Roboto-Regular", size: size)
    }
    static func appMedium(_ size: CGFloat) -> Font {
        .custom("Roboto-Medium", size: size)
    }
    static func appSemiBold(_ size: CGFloat) -> Font {
        .custom("Roboto-SemiBold", size: size)
    }
    static func appBold(_ size: CGFloat) -> Font {
        .custom("Roboto-Bold", size: size)
    }
    static func appExtraBold(_ size: CGFloat) -> Font {
        .custom("Roboto-ExtraBold", size: size)
    }
    static func appBlack(_ size: CGFloat) -> Font {
        .custom("Roboto-Black", size: size)
    }
    static func appThinItalic(_ size: CGFloat) -> Font {
        .custom("Roboto-ThinItalic", size: size)
    }
    static func appExtraLightItalic(_ size: CGFloat) -> Font {
        .custom("Roboto-ExtraLightItalic", size: size)
    }
    static func appLightItalic(_ size: CGFloat) -> Font {
        .custom("Roboto-LightItalic", size: size)
    }
    static func appItalic(_ size: CGFloat) -> Font {
        .custom("Roboto-Italic", size: size)
    }
    static func appMediumItalic(_ size: CGFloat) -> Font {
        .custom("Roboto-MediumItalic", size: size)
    }
    static func appSemiBoldItalic(_ size: CGFloat) -> Font {
        .custom("Roboto-SemiBoldItalic", size: size)
    }
    static func appBoldItalic(_ size: CGFloat) -> Font {
        .custom("Roboto-BoldItalic", size: size)
    }
    static func appExtraBoldItalic(_ size: CGFloat) -> Font {
        .custom("Roboto-ExtraBoldItalic", size: size)
    }
    static func appBlackItalic(_ size: CGFloat) -> Font {
        .custom("Roboto-BlackItalic", size: size)
    }
}
