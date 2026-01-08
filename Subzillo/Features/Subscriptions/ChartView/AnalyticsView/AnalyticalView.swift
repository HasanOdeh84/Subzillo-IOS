//
//  AnalyticalView.swift
//  Subzillo
//
//  Created by KSMAC-MINI-017 on 29/12/25.
//


import SwiftUI

struct AnalyticalView: View {
    
    //MARK: - Properties
    @State private var currentDate              = Date()
    @State private var tempDate                 = Date()
    @State var year                             : Int = 0
    @State var month                            : Int = 0
    @State private var monthlySubscriptions     = [SubscriptionDay]()
    @State private var isDatePickerPresented    = false
    @State private var chargeDate               : String = ""
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    
    private func dateSelection() {
        withAnimation(.easeInOut) {
            isDatePickerPresented = true
        }
    }
    
    //MARK: - body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Title + Share
                HStack {
                    Text("Subscription Spend Analytics")
                        .font(.appSemiBold(16))
                    Spacer()
                    Button {
                        // share action
                    } label: {
                        Image("share_analytics")
                    }
                }
                
                Button(action: dateSelection) {
                    FieldView(
                        text: $chargeDate,
                        textValue: "",
                        title: "",
                        image: "Calendar1",
                        placeHolder: "mm/yyyy",
                        isButton: false,
                        isText: true,
                        isDate: true
                    )
                }
                .sheet(isPresented: $isDatePickerPresented) {
                    CustomCalenderSheet(
                        isPresented   : $isDatePickerPresented,
                        selectedMonth : $month,
                        selectedYear  : $year,
                        onDone: {
                            let monthString = String(format: "%02d", month)
                            self.chargeDate = "\(monthString)/\(year)"
                            //                    getSubsByMonthApi()
                        }
                    )
                    .presentationDetents([.height(300)])
                    .presentationDragIndicator(.hidden)
                }
                
                // Member Filter
                AnalyticsMemberFilterView()
                
                // Donut Chart (Top Spending)
                SubscriptionSummaryView()
                
                // Year overview bar chart
                AnalyticsYearOverviewChartView()
            }
        }
        .padding(.bottom, 75)
    }
}
