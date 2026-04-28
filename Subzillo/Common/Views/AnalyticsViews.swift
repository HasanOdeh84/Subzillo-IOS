//
//  AnalyticsViews.swift
//  Subzillo
//
//  Created by Antigravity on 07/04/26.
//

import SwiftUI

//MARK: - SubscriptionSummaryView
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
                           subsCount        : pieData.totals?.totalSubscriptions ?? 0,
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

//MARK: - DonutChartView
struct DonutChartView: View {
    
    var data                     : [AnalyticsCategoryData]
    var subsCount                : Int?
    var currencySymbol           : String
    @State private var progresses: [CGFloat]
    
    init(data: [AnalyticsCategoryData], subsCount:Int? , currencySymbol: String) {
        self.data = data
        self.subsCount = subsCount
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
                        .glossyFill(color: Color(hex: item.categoryColor ?? "#619BEE"))
                    }
                }
            }
            
            VStack(spacing: 4) {
                Text("\(subsCount ?? 0)")
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

//MARK: - DonutSlice
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

//MARK: - LegendItemView
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

//MARK: - Extensions
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
