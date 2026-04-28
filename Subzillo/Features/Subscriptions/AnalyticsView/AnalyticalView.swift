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
    @State private var monthlySubscriptions     = [AnalyticsCategoryData]()
    @State private var isDatePickerPresented    = false
    @State private var chargeDate               : String = ""
    @StateObject var viewModel                  = SubscriptionsViewModel()
    @StateObject var manualVM                   = ManualEntryViewModel()
    @State var monthYear                        : String =  ""
    @State var selectedFamilyMembers            : [String] = ["all"]
    @State private var relationsData            = [
        ManualDataInfo(id: "all", title: "All"),
        ManualDataInfo(id: "me", title: "Me")
    ]
    
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                HStack {
                    Text("Subscription Spend Analytics")
                        .font(.appRegular(18))
                    Spacer()
//                    Button {
//                    } label: {
//                        Image("share_analytics")
//                    }
//                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.neutral2200,
                                    lineWidth: 2
                                   )
                    )
                    .cornerRadius(8)
                }
                
                /*
                 
                 //                Button(action: dateSelection) {
                 //                    FieldView(
                 //                        text: $chargeDate,
                 //                        textValue: "",
                 //                        title: "",
                 //                        image: "Calendar1",
                 //                        placeHolder: "mm/yyyy",
                 //                        isButton: false,
                 //                        isText: true,
                 //                        isDate: true
                 //                    )
                 //                    .padding(.top, -24)
                 //                    .padding(.horizontal, -5)
                 //                }
                 //                .sheet(isPresented: $isDatePickerPresented) {
                 //                    CustomCalenderSheet(
                 //                        isPresented   : $isDatePickerPresented,
                 //                        selectedMonth : $month,
                 //                        selectedYear  : $year,
                 //                        onDone: {
                 //                            let monthString = String(format: "%02d", month)
                 //                            self.chargeDate = "\(monthString)/\(year)"
                 //                            //                    getSubsByMonthApi()
                 //                        }
                 //                    )
                 //                    .presentationDetents([.height(300)])
                 //                    .presentationDragIndicator(.hidden)
                 //                }
                 */
                
                // Member Filter
                //                AnalyticsMemberFilterView(members: relationsData)
                AnalyticsMemberFilterView(members: relationsData, selectedIds: $selectedFamilyMembers) {
                    analyticsApi()
                }
                
                // Donut Chart (Top Spending)
                SubscriptionSummaryView(pieData         : viewModel.analyticsResponse?.pie ?? PieData(month: 0, year: 0, monthYear: "", totals: nil, totalAmount: 0.0, currency: "", currencySymbol: "", categories: []),
                                        subscriptions   : viewModel.analyticsResponse?.pie?.categories ?? [],
                                        currencySymbol  : viewModel.analyticsResponse?.currencySymbol ?? Constants.shared.currencySymbol,
                                        monthYear       : $monthYear,
                                        done: {
                    analyticsApi()
                })
                
                // Year overview bar chart
                AnalyticsYearOverviewChartView(barData: viewModel.analyticsResponse?.bar, onDone: { year in
                    self.year = year
                    analyticsApi()
                })
                .padding(.bottom, 75)
            }
            .onAppear{
                let now = Date()
                let formatter = DateFormatter()
                year = Calendar.current.component(.year, from: now)
                formatter.dateFormat = "yyyy-MM"
                monthYear = formatter.string(from: now)
                analyticsApi()
                listFamilyMembersApi()
            }
            .onChange(of: manualVM.listFamilyMembersResponse?.familyMembers) { _ in updateRelationInfo() }
        }
    }
    
    //MARK: - User defined methods
    func analyticsApi(){
        viewModel.analytics(input: AnalyticsRequest(userId          : Constants.getUserId(),
                                                    monthYear       : monthYear,
                                                    year            : year,
                                                    familyMembers   : selectedFamilyMembers))
    }
    
    func listFamilyMembersApi(){
        manualVM.listFamilyMembers(input: ListFamilyMembersRequest(userId: Constants.getUserId()))
    }
    
    func updateRelationInfo()
    {
        relationsData.removeAll()
        relationsData.append(ManualDataInfo(id: "all", title: "All"))
        relationsData.append(ManualDataInfo(id: "me", title: "Me"))
        if let familyCards = manualVM.listFamilyMembersResponse?.familyMembers {
            for family in familyCards {
                relationsData.append(
                    ManualDataInfo(
                        id      : family.id ?? "",
                        title   : family.nickName
                    )
                )
            }
        }
    }
}

//MARK: - Support views

//MARK: AnalyticsMemberFilterView
struct AnalyticsMemberFilterView: View {
    let members                 : [ManualDataInfo]
    @Binding var selectedIds    : [String]
    var onSelectionChange       : () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(members, id: \.id) { member in
                    Button {
                        handleSelection(member.id)
                    } label: {
                        Text(LocalizedStringKey(member.title ?? ""))
                            .font(.appRegular(14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .foregroundColor(isSelected(member.id) ? .white : .navyBlueCTA700)
                            .background(
                                isSelected(member.id) ? Color.blueMain700 : Color.white
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.neutral300Border,
                                            lineWidth: isSelected(member.id) ? 0 : 1
                                           )
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.top, 5)
        }
    }
    
    private func isSelected(_ id: String) -> Bool {
        selectedIds.contains(id)
    }
    
    private func handleSelection(_ id: String) {
        withAnimation {
            if id == "all" {
                selectedIds = ["all"]
            } else {
                if selectedIds.contains("all") {
                    selectedIds.removeAll { $0 == "all" }
                }
                
                if selectedIds.contains(id) {
                    selectedIds.removeAll { $0 == id }
                    if selectedIds.isEmpty {
                        selectedIds = ["all"]
                    }
                } else {
                    selectedIds.append(id)
                }
            }
        }
        onSelectionChange()
    }
}


// Note: SubscriptionSummaryView and related views have been moved to Common/Views/AnalyticsViews.swift

//MARK: - AnalyticsYearOverviewChartView
struct AnalyticsYearOverviewChartView: View {
    
    let barData                     : BarData?
    @State var year                 : Int = 2025
    let months                      = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    @State var openYearSheet        = false
    let onDone                      : (Int) -> Void
    
    private var monthlyData: [Double] {
        var data = Array(repeating: 0.0, count: 12)
        if let apiMonths = barData?.months {
            for item in apiMonths {
                if let m = item.month, m >= 1 && m <= 12 {
                    data[m-1] = item.totalAmount ?? 0.0
                }
            }
        }
        return data
    }
    
    private var maxAmount: Double {
        let maxVal = monthlyData.max() ?? 0
        if maxVal == 0 { return 200 }
        // Round up to the nearest 10
        return ceil(maxVal / 10.0) * 10.0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Year Overview")
                    .font(.appRegular(16))
                    .foregroundStyle(Color.neutralMain700)
                Spacer()
                HStack(spacing: 4) {
                    Text(String(year))
                        .font(.appRegular(16))
                        .foregroundStyle(Color.grayLG)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.neutral300Border)
                )
                .onTapGesture {
                    openYearSheet = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .sheet(isPresented: $openYearSheet) {
                CustomYearBottomSheet(isPresented   : $openYearSheet,
                                      selectedYear  : $year,
                                      onDone        : { year in
                    self.year = year
                    onDone(year)
                })
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.hidden)
            }
            
            Divider()
                .overlay(Color.neutral300Border)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.neutral300Border)
                    .frame(width: 1)
                    .padding(.leading, 16 + 30 + 12) // 16 (outer pad) + 30 (text) + 12 (spacing)
                    .padding(.top, 41)
                    .padding(.bottom, 12)
                
                VStack(alignment: .leading, spacing: 12) {
                    GeometryReader { geo in
                        HStack {
                            Text("0")
                            Spacer()
                            Text("\(Int(maxAmount / 2))")
                            Spacer()
                            Text("\(Int(maxAmount))")
                        }
                        .font(.appRegular(12))
                        .foregroundColor(.neutralMain700)
                        .padding(.leading, 53)
                        .padding(.trailing, 16)
                    }
                    .frame(height: 20)
                    
                    Divider()
                        .overlay(Color.neutral300Border)
                        .padding(.horizontal, 16)
                    
                    ForEach(0..<12, id: \.self) { index in
                        HStack(spacing: 12) {
                            Text(LocalizedStringKey(months[index]))
                                .font(.appRegular(14))
                                .foregroundColor(.neutralMain700)
                                .frame(width: 30, alignment: .leading)
                            
                            GeometryReader { geo in
                                let maxWidth = geo.size.width
                                let value = monthlyData[index]
                                let barWidth = maxAmount == 0 ? 0 : (value / maxAmount) * maxWidth
                                
                                RoundedCorner(radius: 4, corners: [.topRight, .bottomRight])
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.purpleG, Color.blueG, Color.blueMain700]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: barWidth, height: 16)
                            }
                            .frame(height: 16)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .onAppear{
            let now = Date()
            year    = Calendar.current.component(.year, from: now)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.neutral300Border, lineWidth: 1)
        )
        .background(.whiteBlackBG)
        .cornerRadius(12)
    }
}
