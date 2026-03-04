//
//  NotificationRowView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/01/26.
//

import SwiftUI

struct NotificationRowView: View {
    
    var notification    : NotificationData
    var selectionMode   : Bool
    var onSelect        : () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if selectionMode {
                Button(action: onSelect) {
                    Image(notification.isSelected ?? false == true ? "Checkmark" : "UnCheckmark")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
//                .padding(.top, 2)
            }
            
            Image("notification_blue")
                .resizable()
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(LocalizedStringKey(notification.title ?? ""))
                        .font(.appSemiBold(16))
                        .foregroundColor(.navyBlueCTA700)
                    
                    Spacer()
                    
                    //                    Text(notification.date ?? "")
                    //                        .font(.appRegular(12))
                    //                        .foregroundColor(.neutral500)
                }
                
                Text(LocalizedStringKey(notification.message ?? ""))
                    .font(.appRegular(14))
                    .foregroundColor(.neutral500)
                //                    .lineLimit(3)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .opacity(notification.readStatus ?? false ? 0.6 : 1.0)
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
    }
}
