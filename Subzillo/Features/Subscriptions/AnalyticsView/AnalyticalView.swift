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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                HStack {
                    Text("Subscription Spend Analytics")
                        .font(.appRegular(18))
                    Spacer()
                    Button {
                    } label: {
                        Image("share_analytics")
                    }
                    .frame(width: 40, height: 40)
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
                AnalyticsMemberFilterView()
                
                // Donut Chart (Top Spending)
                SubscriptionSummaryView()
                
                // Year overview bar chart
                AnalyticsYearOverviewChartView(onDone: { year in
                    
                })
                .padding(.bottom, 75)
            }
        }
    }
}

//MARK: - Support views

//MARK: AnalyticsMemberFilterView
struct AnalyticsMemberFilterView: View {
    let members = ["All", "Me", "Wife", "Fatemah", "Son", "Harry"]
    @State private var selectedMember = "All"
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(members, id: \.self) { member in
                    Button {
                        withAnimation {
                            selectedMember = member
                        }
                    } label: {
                        Text(member)
                            .font(.appRegular(14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .foregroundColor(selectedMember == member ? .white : .navyBlueCTA700)
                            .background(
                                selectedMember == member ? Color.blueMain700 : Color.white
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.neutral300Border,
                                            lineWidth: selectedMember == member ? 0 : 1
                                           )
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.top, 5)
        }
    }
}

//MARK: SubscriptionSummaryView
struct SubscriptionSummaryView: View {
    
    let subscriptions = [
        SubscriptionData(amount: 10.00, color: "red", title: "Netflix"),
        SubscriptionData(amount: 20.00, color: "blue", title: "Prime"),
        SubscriptionData(amount: 5.32, color: "purple", title: "iCloud"),
        SubscriptionData(amount: 21.99, color: "indigo", title: "Spotify"),
        SubscriptionData(amount: 66.68, color: "cyan", title: "YouTube")
    ]
    
    @State private var showAll                  = false
    @State private var currentDate              = Date()
    @State private var tempDate                 = Date()
    @State var year                             : Int = 0
    @State var month                            : Int = 0
    @State private var isDatePickerPresented    = false
    @State private var chargeDate               : String = "mm/yyyy"
    
    private var visibleSubscriptions: [SubscriptionData] {
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
                            //                    getSubsByMonthApi()
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
            DonutChartView(data: subscriptions)
                .padding(.vertical, 24)
                .padding(.horizontal, 29)
            
            VStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("Active - 10")
                        .font(.appBold(14))
                        .foregroundColor(Color.green)
                    Text("|")
                        .font(.appBold(14))
                        .foregroundColor(.neutralMain700)
                    Text("Inactive - 06")
                        .font(.appBold(14))
                        .foregroundColor(Color.red)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                VStack(spacing: 8) {
                    ForEach(visibleSubscriptions.indices, id: \.self) { index in
                        LegendItemView(item: visibleSubscriptions[index])
                    }
                }
                .padding(.horizontal, 24)
                
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
        .background(Color.white)
        .cornerRadius(8)
        // .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct DonutChartView: View {
    
    var data: [SubscriptionData]
    @State private var progresses: [CGFloat]
    
    init(data: [SubscriptionData]) {
        self.data = data
        _progresses = State(initialValue: Array(repeating: 0, count: data.count))
    }
    
    private var totalAmount: Double {
        data.compactMap { $0.amount }.reduce(0, +)
    }
    
    private var sliceAngles: [(start: Angle, end: Angle, sweep: Double)] {
        var result: [(Angle, Angle, Double)] = []
        var current = Angle(degrees: -90)
        
        for item in data {
            let value = item.amount ?? 0
            let percent = totalAmount == 0 ? 0 : value / totalAmount
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
                
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let s = sliceAngles[index]
                    let animatedEnd = s.start + .degrees(s.sweep * progresses[index])
                    
                    DonutSlice(
                        startAngle: s.start,
                        endAngle: animatedEnd,
                        thickness: thickness
                    )
                    //                    .glossyFill(color: item.color)
                    .glossyFill(color: item.uiColor)
                }
            }
            
            VStack(spacing: 4) {
                Text("\(data.count)")
                    .font(.appSemiBold(40))
                    .foregroundColor(.navyBlueCTA700)
                
                Text("Subscriptions")
                    .foregroundColor(.neutral500)
                    .font(.appSemiBold(18))
                
                Text("$\(String(format: "%.2f", totalAmount))")
                    .font(.appSemiBold(28))
                    .foregroundColor(.navyBlueCTA700)
            }
        }
        .frame(height: 278)
        .onAppear { animateSequentially() }
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
    let item: SubscriptionData
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Circle()
                .fill(item.uiColor)
                .frame(width: 15, height: 15)
            
            Text(item.title ?? "")
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
                .lineLimit(1)
            
            
            DashedHorizontalDivider()
            
            Text("$\(String(format: "%.2f", item.amount ?? 0.00))")
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
                endRadius: 200     // adjust based on frame
            )
        )
    }
}

extension SubscriptionData {
    var uiColor: Color {
        // Map colors to design system or standard colors
        // Mockup uses a specific palette
        switch color?.lowercased() {
        case "red": return Color(hex: "FF5C5C") // Estimate
        case "blue": return Color(hex: "2E5BFF")
        case "purple": return .purple
        case "indigo": return .indigo
        case "cyan": return .cyan
        default: return .gray
        }
    }
}

//MARK: - AnalyticsYearOverviewChartView
struct AnalyticsYearOverviewChartView: View {
    
    @State var year                 : Int = 2025
    let years                       = ["2023", "2024", "2025"]
    @State private var selectedYear = "2024"
    let monthlyData: [Double]       = [80, 60, 200, 80, 60, 40, 80, 120, 80, 80, 80, 90]
    let months                      = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    @State var openYearSheet        = false
    let onDone                      : (Int) -> Void
    
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
                            Text("100")
                            Spacer()
                            Text("200")
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
                                let barWidth = (value / 200.0) * maxWidth
                                
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
        .background(Color.white)
        .cornerRadius(12)
    }
}
