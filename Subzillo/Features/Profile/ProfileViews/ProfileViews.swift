//
//  ProfileViews.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 13/11/25.
//

import SwiftUI

struct ProfileHeaderView: View {
    
    //MARK: - Properties
    var title           : String
    var trailingTitle   : String? = nil
    var onBack          : (() -> Void)? = nil
    var onTrailingAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Button(action: {
                onBack?()
            }) {
                Image("back_gray")
                    .frame(width: 24,height: 24)
            }
            
            Text(title)
                .font(.appRegular(24))
                .foregroundColor(.neutralMain700)
            
            Spacer()
            
            if let trailingTitle = trailingTitle {
                Button(action: {
                    onTrailingAction?()
                }) {
                    Text(trailingTitle)
                        .font(.appRegular(14))
                        .foregroundColor(.blueMain700)
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 32)
    }
}
