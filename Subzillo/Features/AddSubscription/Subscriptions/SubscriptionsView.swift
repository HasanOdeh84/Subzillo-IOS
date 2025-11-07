//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI

struct SubscriptionsView: View {
    enum Segment {
        case list, calendar
    }
    @State private var selectedSegment: Segment = .list
    @State private var currentDate = Date()
    
    // Date Formatter Helpers
    private var currentYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL" // Full month name
        return formatter.string(from: currentDate)
    }
    
    let subscriptions = [
        SubscriptionInfo(id: "1", amount: 18.0, currency: "$", createdAt: "2025-10-06", plans:[PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google")], relations: [RelationsInfo(id: "1", name: "Mon", color: "#AF0000"),RelationsInfo(id: "1", name: "Son", color: "#20368A"),RelationsInfo(id: "1", name: "Me", color: "#619BEE"),RelationsInfo(id: "1", name: "Father", color: "#619BEE")], cardsCount: 1),
        SubscriptionInfo(id: "2", amount: 48.0, currency: "$", createdAt: "2025-10-14", plans:[PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google")], relations: [RelationsInfo(id: "1", name: "Me", color: "#619BEE")], cardsCount: 3),
        SubscriptionInfo(id: "3", amount: 8.0, currency: "$", createdAt: "2025-10-20", plans:[PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google"),PlanInfo(id: "1", image: "google")], relations: [RelationsInfo(id: "1", name: "Son", color: "#20368A")], cardsCount: 4)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // MARK: - Header
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        // MARK: - Title
                        Text("Your subscriptions")
                            .font(.appRegular(24))
                            .foregroundColor(Color.neutralMain700)
                            .padding(.top, 20)
                        
                        // MARK: - SubTitle
                        Text("Here's your subscription overview")
                            .font(.appRegular(18))
                            .foregroundColor(Color.neutral500)
                    }
                    Spacer()
                    
                    ZStack(alignment: .topTrailing) {
                        Button(action: goToNotifications) {
                            
                            Image("notification-03")
                                .frame(width: 32, height: 32)
                        }
                        
                        Text("3")
                            .font(.appBold(11))
                            .foregroundColor(Color.white)
                            .frame(width: 16, height: 16)
                            .background(Color.redBadge)
                            .cornerRadius(4)
                            .offset(x: 0, y: -5)
                        
                    }
                    .offset(x: 0, y: -5)
                    
                }
                .padding(.top, 0)
                
                // MARK: - Segment
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // MARK: - List View Button
                        Button {
                            selectedSegment = .list
                            clickOnListView()
                        } label: {
                            HStack(spacing: 5) {
                                Image("left-to-right-list-bullet")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(selectedSegment == .list ? .neutralDisabled200 : .navyBlueCTA700)
                                
                                Text("List View")
                                    .font(.appSemiBold(14))
                                    .foregroundColor(selectedSegment == .list ? .neutralDisabled200 : .neutralMain700)
                            }
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                selectedSegment == .list
                                ? Color.navyBlueCTA700
                                : Color.clear
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: selectedSegment == .list ? 0 : 2
                                    )
                            )
                            //.cornerRadius(8)
                            .clipShape(RoundedCorner(radius: 8, corners: [.topLeft, .bottomLeft]))
                        }
                        
                        // MARK: - Calendar View Button
                        Button {
                            selectedSegment = .calendar
                            clickOnCalendarView()
                        } label: {
                            HStack(spacing: 5) {
                                Image("calendar-04")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(selectedSegment == .calendar ? .neutralDisabled200 : .navyBlueCTA700)
                                
                                Text("Calendar")
                                    .font(.appSemiBold(14))
                                    .foregroundColor(selectedSegment == .calendar ? .neutralDisabled200 : .neutralMain700)
                            }
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                selectedSegment == .calendar
                                ? Color.navyBlueCTA700
                                : Color.clear
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: selectedSegment == .calendar ? 0 : 2
                                    )
                            )
                            //.cornerRadius(8)
                            .clipShape(RoundedCorner(radius: 8, corners: [.topRight, .bottomRight]))
                        }
                        
                        
                        
                    }
                    .frame(minWidth: 240, alignment: .topLeading)
                    .padding(.trailing, 8)
                    .padding(.leading, 0)
                    
                    HStack(spacing: 8) {
                        Button(action: clickOnChat) {
                            
                            Image("chart-line-data-02")
                                .frame(width: 20, height: 20)
                        }
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .cornerRadius(8)
                        
                        Button(action: clickOnFilter) {
                            
                            Image("filter")
                                .frame(width: 20, height: 20)
                        }
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(.top, 16)
                
                // MARK: - year and Month
                HStack(spacing: 8) {
                    HStack(spacing: 0) {
                        Button(action: clickOnYearLeft) {
                            Image("arrow-left-01-round")
                                .frame(width: 20, height: 20)
                                .padding(.horizontal, 10)
                        }
                        .frame(width: 40, height: 36, alignment: .leading)
                        
                        Text(String(format: "%d", currentYear))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .font(.appRegular(14))
                            .foregroundColor(.neutralMain700)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.neutral300Border, lineWidth: 1)
                            )
                        
                        Button(action: clickOnYearRight) {
                            Image("arrow-right-01-round")
                                .frame(width: 20, height: 20)
                                .padding(.horizontal, 10)
                        }
                        .frame(width: 40, height: 36, alignment: .trailing)
                    }
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    .cornerRadius(28)
                    
                    HStack(spacing: 0) {
                        Button(action: clickOnMonthLeft) {
                            Image("arrow-left-01-round")
                                .frame(width: 20, height: 20)
                                .padding(.horizontal, 10)
                        }
                        .frame(width: 40, height: 36, alignment: .leading)
                        
                        Text(currentMonthName)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .font(.appRegular(14))
                            .foregroundColor(.neutralMain700)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.neutral300Border, lineWidth: 1)
                            )
                        
                        Button(action: clickOnMonthRight) {
                            Image("arrow-right-01-round")
                                .frame(width: 20, height: 20)
                                .padding(.horizontal, 10)
                        }
                        .frame(width: 40, height: 36, alignment: .trailing)
                    }
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    .cornerRadius(28)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .padding(.top, 24)
            }
            .padding(.bottom, 24)
            
            List(subscriptions) { subscription in
                SubscriptionRow(subscriptionData: subscription)
                    .onTapGesture {
                        print("Tapped on: \(subscription)")
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .frame(maxWidth: .infinity)
            .scrollContentBackground(.hidden)
            .background(Color.neutralBg100)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .background(Color.neutralBg100)
        
    }
    
    //MARK: - Button actions
    private func goToNotifications() {
    }
    private func clickOnListView() {
    }
    private func clickOnCalendarView() {
    }
    private func clickOnChat() {
    }
    private func clickOnFilter() {
    }
    private func clickOnYearLeft() {
        if let newDate = Calendar.current.date(byAdding: .year, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    private func clickOnYearRight() {
        if let newDate = Calendar.current.date(byAdding: .year, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
    private func clickOnMonthLeft() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    private func clickOnMonthRight() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
}

#Preview {
    SubscriptionsView()
}
