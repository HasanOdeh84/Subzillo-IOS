//
//  NotificationRowView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/01/26.
//  Redesigned by Antigravity on 27/05/26.
//

import SwiftUI

struct NotificationTheme {
    var iconName: String
    var containerBackground: AnyView
    var shadowColor: Color
}

struct NotificationRowView: View {
    
    var notification    : NotificationData
    var selectionMode   : Bool
    var isSwiped        : Bool = false
    var onSelect        : () -> Void
    
    @EnvironmentObject var themeManager     : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isUnread = !(notification.readStatus ?? false)
        let theme = getNotificationTheme(type: notification.type ?? 0)
        
        HStack(alignment: .top, spacing: 14) {
            if selectionMode {
                Button(action: onSelect) {
                    Image(notification.isSelected ?? false == true ? "Checkmark" : "UnCheckmark")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.top, 10)
            }
            
            // MARK: - Left Icon Container with Unread Dot
            ZStack(alignment: .center) {
                theme.containerBackground
                    .frame(width: 38, height: 38)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 4)
                
                Image("\(theme.iconName)")
                //                    .font(.system(size: 18, weight: .semibold))
                //                    .foregroundColor(theme.iconColor)
                    .frame(width: 18, height: 18)
                    .frame(alignment: .center)
                
                if isUnread {
                    Circle()
                        .fill(themeManager.accentTextColor)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.calenderF1F2F7FFFFFF, lineWidth: 2)
                        )
                        .shadow(color: themeManager.currentAccent.senColor, radius: 4, x: 0, y: 0 )
                        .offset(x: 16, y: -17)
                }
            }
            .frame(width: 38, height: 38)
            
            // MARK: - Text Content & Timestamp
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(LocalizedStringKey(notification.title ?? ""))
                        .font(.geistSemiBold(13))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(getFormattedTime(notification.createdAt))
                        .font(.geistRegular(12))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                }
                
                Text(LocalizedStringKey(notification.message ?? ""))
                    .font(.geistRegular(11))
                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.36))
                    .lineLimit(2)
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSwiped ? .bgPrimaryF7F7F90A0612 : (isUnread ?
                      Color.calenderF1F2F7FFFFFF : themeManager.white_white4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isUnread ?
                    (colorScheme == .light ? .textPrimaryLight0E101A.opacity(0.14) : .white.opacity(0.14)) :
                    Color.calenderF1F2F7FFFFFF,
                    lineWidth: 1
                )
        )
//        .shadow(
//            color: isUnread ? theme.shadowColor.opacity(colorScheme == .dark ? 0.35 : 0.15) : Color.black.opacity(colorScheme == .dark ? 0.15 : 0.02),
//            radius: isUnread ? 12 : 6,
//            x: 0,
//            y: isUnread ? 6 : 3
//        )
    }
    
    // MARK: - Helper Methods
    
    private func getNotificationTheme(type:Int) -> NotificationTheme {
        if type == 1 {
            return NotificationTheme(
                iconName    : "msgBox_green",
                containerBackground: AnyView(
                    Color.success0EA8705CE4A8.opacity(0.13)
                ),
                shadowColor: .clear
            )
        } else if type == 2 {
            return NotificationTheme(
                iconName            : "clock",
                containerBackground : AnyView(Color.yellowE0A218FFCB5C.opacity(0.13)),
                shadowColor         : .clear
            )
        } else if type == 4 {
            let color = themeManager.accentGradient
            return NotificationTheme(
                iconName: "giftwhite",
                containerBackground: AnyView(color),
                shadowColor: .clear
            )
        } else if type == 5 {
            let color = Color.brandMidDark7C5CFF
            return NotificationTheme(
                iconName: "profile_blue",
                containerBackground: AnyView(color.opacity(0.13)),
                shadowColor: .clear
            )
        } else if type == 6{
            let color = themeManager.accentGradient
            return NotificationTheme(
                iconName: "chart1",
                containerBackground: AnyView(
                    color
                ),
                shadowColor: themeManager.accentTextColor.opacity(0.40)
            )
        } else if type == 7 {
            return NotificationTheme(
                iconName: "piece_yellow",
                containerBackground: AnyView(Color.yellowE0A218FFCB5C.opacity(0.13)),
                shadowColor: .clear
            )
        }else {
            let color = Color.dangerE43C5CFF5A7A
            return NotificationTheme(
                iconName: "mike_red",
                containerBackground: AnyView(color.opacity(0.10)),
                shadowColor: .clear
            )
        }
    }
    
    private func getFormattedTime(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let now = Date()
        let diffComponents = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = diffComponents.day {
            if day == 0 {
                if let hour = diffComponents.hour {
                    if hour == 0 {
                        if let minute = diffComponents.minute {
                            return "\(max(1, minute))m"
                        }
                        return "now"
                    }
                    return "\(hour)h"
                }
            } else if day == 1 {
                return "yest"
            } else {
                return "\(day)d"
            }
        }
        return dateString
    }
}
