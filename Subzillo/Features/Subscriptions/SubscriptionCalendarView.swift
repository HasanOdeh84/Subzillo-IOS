//
//  SubscriptionCalendarView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 18/05/26.
//

import SwiftUI


// MARK: - Calendar View
struct SubscriptionCalendarView: View {
    
    @Binding var currentDate: Date
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedDate: Int?
    @Binding var highlights: [CalendarHighlight]
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 7
    )
    
    private let weekDays = ["S","M","T","W","T","F","S"]
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            // MARK: - Header
            HStack {
                
                Text(monthYearString())
                    .font(.geistSemiBold(16))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                
                Spacer()
                
                HStack(spacing: 6) {
                    
                    navButton(
                        image: "backGrayleft"
                    ) {
                        changeMonth(by: -1)
                    }
                    
                    navButton(
                        image: "backGrayright"
                    ) {
                        changeMonth(by: 1)
                    }
                }
            }
            .padding(.bottom, 14)
            
            // MARK: - Week Names
            LazyVGrid(columns: columns, spacing: 4) {
                
                ForEach(weekDays.indices, id: \.self) { index in
                    
                    Text(weekDays[index])
                        .font(.jetBrainsMedium(10))
                        .foregroundColor(
                            Color.textPrimary0E101AF4F1FB.opacity(0.36)
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 12)
                }
            }
            .padding(.bottom, 8)
            
            // MARK: - Dates
            LazyVGrid(columns: columns, spacing: 4) {
                
                ForEach(calendarDays(), id: \.id) { day in
                    
                    if let value = day.day {
                        
                        Button {
                            
                            print("Tapped:", value)
                            selectedDate = value
                            
                        } label: {
                            
                            calendarCell(
                                day: value,
                                isToday: day.isToday,
                                isHighlighted: day.isHighlighted,
                                dots: day.dotCount,
                                isPast: day.isPast,
                                isSelected: selectedDate == value
                            )
                        }
                        
                    } else {
                        
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(18)
        .background(themeManager.white_white4)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    Color.textPrimary0E101AF4F1FB.opacity(0.08),
                    lineWidth: 1
                )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }
}

// MARK: - Components
extension SubscriptionCalendarView {
    
    @ViewBuilder
    private func navButton(
        image: String,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            
            Image(image)
                .renderingMode(.template)
                .foregroundColor(
                    (Color.textPrimary0E101AF4F1FB).opacity(0.6)
                )
                .frame(width: 28, height: 28)
                .background(
                    themeManager.white_white4
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            themeManager.black_white.opacity(0.08),
                            lineWidth: 1
                        )
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func calendarCell(
        day: Int,
        isToday: Bool,
        isHighlighted: Bool,
        dots: Int,
        isPast: Bool,
        isSelected: Bool
    ) -> some View {
        
        VStack(spacing: 1) {
            
            Text("\(day)")
                .font(
                    isSelected || isToday || isHighlighted
                    ? .geistSemiBold(11)
                    : .geistRegular(11)
                )
                .foregroundColor(
                    (isSelected || isToday)
                    ? .white
                    : Color.textPrimary0E101AF4F1FB
                )
            
            if dots > 0 {
                
                HStack(spacing: 1.5) {
                    
                    ForEach(0..<dots, id: \.self) { _ in
                        
                        Circle()
                            .fill(
                                themeManager.selectedAccent.primaryColor
                            )
                            .frame(width: 3, height: 3)
                    }
                }
            }
        }
        .frame(width: 41, height: 41)
        .background(
            Group {
                    
                    if isSelected {
                        
                        themeManager.accentGradient.opacity(0.8)
                        
                    } else if isToday {
                        
                        themeManager.accentGradient
                        
                    } else if isHighlighted {
                        
                        themeManager.white_white4
                        
                    } else {
                        
                        Color.clear
                    }
                }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isHighlighted
                    ? themeManager.selectedAccent.primaryColor.opacity(0.25)
                    : .clear,
                    lineWidth: 1
                )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .opacity(isPast ? 0.35 : 1)
        .shadow(
            color: isToday
            ? themeManager.selectedAccent.primaryColor.opacity(0.45)
            : .clear,
            radius: 12,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Helpers
extension SubscriptionCalendarView {
    
    private func monthYearString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private func changeMonth(by value: Int) {
        
        if let date = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: currentDate
        ) {
            currentDate = date
        }
    }
    
    private func calendarDays() -> [CalendarDay] {
        
        let calendar = Calendar.current
        
        guard
            let monthInterval = calendar.dateInterval(
                of: .month,
                for: currentDate
            ),
            let monthFirstWeek = calendar.dateInterval(
                of: .weekOfMonth,
                for: monthInterval.start
            )
        else {
            return []
        }
        
        var days: [CalendarDay] = []
        
        let startDate = monthFirstWeek.start
        
        for index in 0..<42 {
            
            guard
                let date = calendar.date(
                    byAdding: .day,
                    value: index,
                    to: startDate
                )
            else {
                continue
            }
            
            let isCurrentMonth = calendar.isDate(
                date,
                equalTo: currentDate,
                toGranularity: .month
            )
            
            if !isCurrentMonth {
                
                days.append(
                    CalendarDay(
                        day: nil,
                        isToday: false,
                        isHighlighted: false,
                        dotCount: 0,
                        isPast: false
                    )
                )
                
                continue
            }
            
            let day = calendar.component(.day, from: date)
            
            let today = calendar.isDateInToday(date)
            
            let highlightItem = highlights.first(where: {
                $0.day == day
            })

            days.append(
                CalendarDay(
                    day: day,
                    isToday: today,
                    isHighlighted: highlightItem != nil,
                    dotCount: highlightItem?.dots ?? 0,
                    isPast: calendar.startOfDay(for: date)
                        < calendar.startOfDay(for: Date())
                )
            )
        }
        
        return days
    }
}

// MARK: - Model
struct CalendarDay: Identifiable {
    
    let id = UUID()
    
    let day: Int?
    let isToday: Bool
    let isHighlighted: Bool
    let dotCount: Int
    let isPast: Bool
}
