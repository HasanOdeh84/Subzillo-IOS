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
                SubscriptionSummaryView(pieData         : viewModel.analyticsResponse?.pie ?? PieData(month: 0, year: 0, monthYear: "", totals: nil, totalAmount: 0.0, categories: []),
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
                        Text(member.title ?? "")
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

//MARK: SubscriptionSummaryView
struct SubscriptionSummaryView: View {
    
    var pieData         : PieData
    let subscriptions   : [AnalyticsCategoryData]
    var currencySymbol  : String
    @State private var showAll                  = false
    @State private var currentDate              = Date()
    @State private var tempDate                 = Date()
    @State var year                             : Int = 0
    @State var month                            : Int = 0
    @State private var isDatePickerPresented    = false
    @State private var chargeDate               : String = "mm/yyyy"
    @Binding var monthYear                      : String
    var done                                    : () -> Void
    
    private var visibleSubscriptions: [AnalyticsCategoryData] {
        if showAll {
            return subscriptions
        } else {
            return Array(subscriptions.prefix(2))
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Top spending subscriptions")
                    .font(.appRegular(16))
                    .foregroundColor(.neutralMain700)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(chargeDate)
                        .font(.appRegular(16))
                        .foregroundStyle(chargeDate == "mm/yyyy" ? Color.grayText : Color.grayLG)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(chargeDate == "mm/yyyy" ? Color.grayText : Color.grayLG)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.neutral300Border)
                )
                .onTapGesture {
                    isDatePickerPresented = true
                }
                .sheet(isPresented: $isDatePickerPresented) {
                    CustomCalenderSheet(
                        isPresented   : $isDatePickerPresented,
                        selectedMonth : $month,
                        selectedYear  : $year,
                        onDone: {
                            let monthString = String(format: "%02d", month)
                            self.chargeDate = "\(monthString)/\(year)"
                            monthYear = "\(year)-\(monthString)"
                            done()
                        }
                    )
                    .presentationDetents([.height(300)])
                    .presentationDragIndicator(.hidden)
                }
                .onAppear{
                    let now = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/yyyy"
                    year    = Calendar.current.component(.year, from: now)
                    month   = Calendar.current.component(.month, from: now)
                    self.chargeDate = formatter.string(from: now)
                }
            }
            .padding(16)
            
            Divider()
                .overlay(Color.neutral300Border)
            
            // Chart
            DonutChartView(data             : subscriptions,
                           currencySymbol   : currencySymbol)
            .padding(.vertical, 24)
            .padding(.horizontal, 29)
            
            VStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("Active - \(pieData.totals?.activeSubscriptions ?? 0)")
                        .font(.appBold(14))
                        .foregroundColor(Color.green)
                    Text("|")
                        .font(.appBold(14))
                        .foregroundColor(.neutralMain700)
                    Text("Inactive - \(pieData.totals?.inactiveSubscriptions ?? 0)")
                        .font(.appBold(14))
                        .foregroundColor(Color.red)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, visibleSubscriptions.count == 0 ? -16 : 0)
                
                VStack(spacing: 8) {
                    ForEach(visibleSubscriptions.indices, id: \.self) { index in
                        LegendItemView(item             : visibleSubscriptions[index],
                                       currencySymbol   : currencySymbol)
                    }
                }
                .padding(.horizontal, 24)
                //                .padding(.bottom, 21)
                .padding(.bottom, subscriptions.count < 2 ? 22 : 0)
                
                if subscriptions.count > 2 {
                    Divider()
                        .overlay(Color.neutral300Border)
                    
                    Button {
                    } label: {
                        HStack(spacing: 4) {
                            Text(showAll ? "Show Less" : "Show More")
                                .font(.appRegular(16))
                                .foregroundColor(.blueMain700)
                            Image("dropDown_blue")
                                .frame(width: 24,height: 24, alignment: .trailing)
                                .rotationEffect(.degrees(showAll ? 0 : 180))
                                .animation(.easeInOut, value: showAll)
                        }
                        .padding(.vertical, 12)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showAll.toggle()
                            }
                        }
                    }
                    .padding(.top, -12)
                }
            }
            .background(Color.neutralBg100.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.neutralDisabled200, lineWidth: 1)
            )
            .cornerRadius(8)
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.neutral300Border, lineWidth: 1)
        )
        .background(.whiteBlackBG)
        .cornerRadius(8)
    }
}

struct DonutChartView: View {
    
    var data                     : [AnalyticsCategoryData]
    var currencySymbol           : String
    @State private var progresses: [CGFloat]
    
    init(data: [AnalyticsCategoryData], currencySymbol: String) {
        self.data = data
        self.currencySymbol = currencySymbol
        _progresses = State(initialValue: Array(repeating: 0, count: data.count))
    }
    
    private var totalAmount: Double {
        data.compactMap { $0.totalAmount }.reduce(0, +)
    }
    
    private var sliceAngles: [(start: Angle, end: Angle, sweep: Double)] {
        var result: [(Angle, Angle, Double)] = []
        var current = Angle(degrees: -90)
        
        for item in data {
            let value = item.totalAmount ?? 0
            let percent = totalAmount == 0 ? (1.0 / Double(max(1, data.count))) : (value / totalAmount)
            let sweep = 360 * percent
            let end = current + .degrees(sweep)
            result.append((current, end, sweep))
            current = end
        }
        return result
    }
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                let thickness: CGFloat = 37
                
                // Background circle for empty state
                DonutSlice(
                    startAngle: .degrees(0),
                    endAngle: .degrees(360),
                    thickness: thickness
                )
                .foregroundColor(.neutralDisabled200)
                
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    if index < progresses.count {
                        let s = sliceAngles[index]
                        let animatedEnd = s.start + .degrees(s.sweep * progresses[index])
                        
                        DonutSlice(
                            startAngle: s.start,
                            endAngle: animatedEnd,
                            thickness: thickness
                        )
                        //                    .glossyFill(color: item.color)
                        .glossyFill(color: Color(hex: item.categoryColor ?? "#619BEE"))
                    }
                }
            }
            
            VStack(spacing: 4) {
                Text("\(data.count)")
                    .font(.appSemiBold(40))
                    .foregroundColor(.navyBlueCTA700)
                
                Text("Subscriptions")
                    .foregroundColor(.neutral500)
                    .font(.appSemiBold(18))
                
                Text("\(currencySymbol)\(String(format: "%.2f", totalAmount))")
                    .font(.appSemiBold(28))
                    .foregroundColor(.navyBlueCTA700)
            }
        }
        .frame(height: 278)
        .onAppear { animateSequentially() }
        .onChange(of: data) { newData in
            progresses = Array(repeating: 0, count: newData.count)
            animateSequentially()
        }
    }
    
    private func animateSequentially() {
        for i in progresses.indices {
            let delay = Double(i) * 0.25  // 0.25 sec between slices
            withAnimation(.easeOut(duration: 1).delay(delay)) {
                progresses[i] = 1
            }
        }
    }
}

struct DonutSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var thickness: CGFloat
    
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.degrees, endAngle.degrees) }
        set {
            startAngle = .degrees(newValue.first)
            endAngle = .degrees(newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius - thickness
        
        var p = Path()
        
        p.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        p.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )
        
        p.closeSubpath()
        return p
    }
}

struct LegendItemView: View {
    let item            : AnalyticsCategoryData
    let currencySymbol  : String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Circle()
                .fill(Color(hex: item.categoryColor ?? "#619BEE"))
                .frame(width: 15, height: 15)
            
            Text(item.categoryName ?? "")
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
            
            DashedHorizontalDivider()
            
            Text("\(currencySymbol)\(String(format: "%.2f", item.totalAmount ?? 0.00))")
                .font(.appSemiBold(16))
                .foregroundColor(.neutralMain700)
        }
        .padding(.vertical, 4)
    }
}

extension Shape {
    func glossyFill(color: Color) -> some View {
        self.fill(
            RadialGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.95),
                    color.opacity(0.70),
                    color.opacity(0.95)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
        )
    }
}

//extension SubscriptionData {
//    var uiColor: Color {
//        // Map colors to design system or standard colors
//        // Mockup uses a specific palette
//        switch color?.lowercased() {
//        case "red": return Color(hex: "FF5C5C") // Estimate
//        case "blue": return Color(hex: "2E5BFF")
//        case "purple": return .purple
//        case "indigo": return .indigo
//        case "cyan": return .cyan
//        default: return .gray
//        }
//    }
//}

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
                            Text(months[index])
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
