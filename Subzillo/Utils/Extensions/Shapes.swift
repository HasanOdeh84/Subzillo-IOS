//
//  Shapes.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 12/11/25.
//

import Foundation
import SwiftUI

struct Line:Shape{
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

/*
 //                    Line()
 //                        .stroke(style: .init(dash: [2,2]))
 //                        .foregroundStyle(.neutralDisabled200)
 //                        .frame(height: 1)
 */
