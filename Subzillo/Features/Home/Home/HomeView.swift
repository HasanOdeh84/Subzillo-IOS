//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//
import SwiftUI
import SDWebImageSwiftUI
import Charts

struct HomeView: View {
    
    //MARK: - Properties
    @State var monthlySpend                 = "$127.94"
    @State var activeSubs                   = 8
    @State var savePercent                  = "Save 58%"
    @State var saveExpiry                   = "on the next Netflix renewal"
    @State var youSaved                     = "You saved $24.99 "
    @State var youSavedExpiry               = "this month"
    @State var activeSubsList               = [SubscriptionListData]()
    @State var subscriptionsList            = [SubscriptionListData]()
    @State var topCategoriesList            = [TopCategoriesData]()
    @State private var showAll              = false
    @Binding var tabSelected                : Tab
    @StateObject var homeVM                 = HomeViewModel()
    @State var homeResponse                 : HomeResponseData?
    @State var fullName                     = ""
    @State private var isHome               : Bool? = nil
    @State var selectedYear                 = 2025
    @State private var showYouSavedSheet    = false
    @State private var showSaveSheet        = false
    @EnvironmentObject var commonApiVM      : CommonAPIViewModel
    @State var currentPlan                  : Int = 0
    @State var monthYear                    : String =  ""
    @State var selectedFamilyMembers        : [String] = ["all"]
    
    @EnvironmentObject var themeManager     : ThemeManager
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    //MARK: - New Properties
    @State private var isOnTrack            : Bool = false
    @State var msCurrency                   = "$"
    @State var msAmmount                    = "120"
    @State var msAmmountD                   = ".95"
    @State var msDeltaValue                 = "↓ $8.20 vs last month"
    @State var pnsAmount                    = "$1522"
    @State var pnsDeltaValue                = "↑ $13 peak in Dec"
    @State var cuentmonth                   = "APR"
    @State var months = [
        ("APR", 42.0),
        ("MAY", 47.0),
        ("JUN", 52.0),
        ("JUL", 49.0),
        ("AUG", 39.0),
        ("SEP", 55.0),
        ("OCT", 57.0),
        ("NOV", 58.0),
        ("DEC", 70.0),
        ("JAN", 64.0),
        ("FEB", 60.0),
        ("MAR", 62.0)
    ]
    @State var wigAmount                   = "$121"
    @State var items: [CategoryItem]       = []
    @State var subscriptions: [SubscriptionItemNew] = []
    @State var upcomingFirstItem: UpcomingCharge?
    @State var upcomingItems: [UpcomingCharge] = []
//    @State private var selectedMonth: String = cuentmonth
    
    private var currentSubscriptions: [SubscriptionListData] {
        showAll ? activeSubsList : Array(activeSubsList.prefix(1))
    }
    
    private var calculatedHeight: CGFloat {
        let cardHeight  : CGFloat = 70  // height of each subscription card
        let spacing     : CGFloat = 14  // spacing between cards
        let totalHeight = CGFloat(activeSubsList.count) * (cardHeight + spacing)
        if !showAll { return cardHeight }
        return min(totalHeight, 300)
    }
    
    //MARK: - body
    var body: some View {
        Group {
            if isHome == nil{
                ZStack {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .opacity(1)
                }
                .allowsHitTesting(true)
            }else if isHome == true{
                VStack(spacing: 0){
                    // MARK: - Header
                    HeaderViewWithProfile(title: "Overview", username: fullName, action: {
                        goToNotifications()
                    }, actionProfile: {
                        goToProfile()
                    })
                    .padding(.top, 60)
                    .padding(.bottom, 10)
                    .frame(alignment: .leading)
                    
                    //MARK: Scroll view
                    ScrollView(showsIndicators: false){
                        
                        // MARK: - Monthly spend
                        VStack(spacing: 0) {
                            
                            VStack(spacing: 0) {
                                
                                // MARK: - Top Section
                                
                                HStack(alignment: .top) {
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        
                                        Text("MONTHLY SPEND")
                                            .font(.jetBrainsRegular(10))
                                            .tracking(1.5)
                                            .foregroundColor(
                                                Color("TextPrimary_ 0E101A_F4F1FB")
                                                    .opacity(0.6)
                                            )
                                        
                                        // Price
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            
                                            Text(msCurrency)
                                                .font(.geistMedium(18))
                                                .foregroundColor(
                                                    Color("TextPrimary_ 0E101A_F4F1FB")
                                                        .opacity(0.6)
                                                )
                                            
                                            if colorScheme == .dark
                                            {
                                                Text(msAmmount)
                                                    .font(.geistSemiBold(46))
                                                    .tracking(-2)
                                                    .foregroundStyle(themeManager.accentGradient)
                                            }
                                            else{
                                                Text(msAmmount)
                                                    .font(.geistSemiBold(46))
                                                    .tracking(-2)
                                                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                                            }
                                            
                                            
                                            
                                            Text(msAmmountD)
                                                .font(.geistMedium(22))
                                                .tracking(-0.5)
                                                .foregroundColor(
                                                    Color("TextPrimary_ 0E101A_F4F1FB")
                                                        .opacity(0.6)
                                                )
                                        }
                                        .padding(.top, 6)
                                        
                                        
                                        // Comparison
                                        Text(msDeltaValue)
                                            .font(.jetBrainsRegular(11))
                                            .foregroundColor(Color("Success_0EA870_5CE4A8"))
                                            .padding(.top, 4)
                                    }
                                    
                                    Spacer(minLength: 12)
                                    
                                    if isOnTrack == true {
                                        // Status Pill
                                        Text("ON TRACK")
                                            .font(.jetBrainsMedium(10))
                                            .tracking(1)
                                            .foregroundColor(Color("Success_0EA870_5CE4A8"))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                Color("Success_Dark_5CE4A8")
                                                    .opacity(0.12)
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(
                                                        Color("Success_0EA870_5CE4A8")
                                                            .opacity(0.2),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .clipShape(Capsule())
                                    }else{
                                        Text("OFF TRACK")
                                            .font(.jetBrainsMedium(10))
                                            .tracking(1)
                                            .foregroundColor(colorScheme == .dark ? Color("Warning_Any_FFCB5C") : Color("orange_FFA500"))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                colorScheme == .dark ? Color("Warning_Any_FFCB5C").opacity(0.12) : Color("orange_FFA500").opacity(0.20)
                                                    
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(
                                                        colorScheme == .dark ? Color("Warning_Any_FFCB5C").opacity(0.2) : Color("orange_FFA500").opacity(0.2),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .clipShape(Capsule())
                                    }
                                }
                                
                                // MARK: - Bottom Stats
                                
                                HStack(spacing: 10) {
                                    
                                    StatCardNew(
                                        title: "ACTIVE",
                                        value: "\(homeResponse?.stats?.activeSubscriptions ?? 0)",
                                        suffix: "subs"
                                    )
                                    
                                    StatCardNew(
                                        title: "YEARLY",
                                        value: "\(homeResponse?.stats?.currencySymbol ?? "")\(homeResponse?.stats?.yearlySpend ?? 0)"
                                    )
                                    
                                    HighestStatCard(data: homeResponse?.stats?.highestActiveSubscription)
                                }
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 20)
                            }
                            .padding(20)
                            .background(
                                colorScheme == .dark
                                ? AnyShapeStyle(themeManager.accentGradient.opacity(0.13))
                                : AnyShapeStyle(themeManager.white_white4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.08),
                                        lineWidth: 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(
                                color: Color("TextPrimary_ 0E101A_F4F1FB")
                                    .opacity(0.04),
                                radius: 8,
                                y: 4
                            )
                        }
                        
                        //MARK: - 12-Month outlook
                        VStack(spacing: 0) {
                            HStack(alignment: .firstTextBaseline) {
                                
                                Text("12-MONTH OUTLOOK")
                                    .font(.jetBrainsRegular(11))
                                    .tracking(1.5)
                                    .foregroundColor(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.6)
                                    )
                                
                                Spacer()
                                
                                Text("projected")
                                    .font(.jetBrainsRegular(10))
                                    .tracking(0.5)
                                    .foregroundColor(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.36)
                                    )
                            }
                            .padding(.top, 22)
                            .padding(.bottom, 10)
                            
                            VStack(spacing: 0) {
                                
                                // MARK: - Header
                                
                                HStack(alignment: .bottom) {
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        
                                        Text("Projected annual spend")
                                            .font(.geistRegular(11))
                                            .foregroundColor(
                                                Color("TextPrimary_ 0E101A_F4F1FB")
                                                    .opacity(0.6)
                                            )
                                        
                                        Text(pnsAmount)
                                            .font(.geistSemiBold(24))
                                            .tracking(-0.8)
                                            .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                                            .padding(.top, 2)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        
                                        Text(pnsDeltaValue)
                                            .font(.jetBrainsRegular(10))
                                            .foregroundColor(Color(hex: "#E0A218"))
                                        
                                        Text("vs now")
                                            .font(.jetBrainsRegular(10))
                                            .foregroundColor(
                                                Color("TextPrimary_ 0E101A_F4F1FB")
                                                    .opacity(0.36)
                                            )
                                    }
                                }
                                .padding(.bottom, 18)
                                
                                // MARK: - Chart
//                                    Chart {
//                                        // MARK: - Bars
//                                        
//                                        ForEach(Array(months.enumerated()), id: \.offset) { index, item in
//                                            
//                                            let activeGradient = themeManager.accentGradient
//                                            
//                                            let inactiveColor = themeManager.white_white4.opacity(0.7)
//                                            
//                                            let barStyle: AnyShapeStyle = index == 0
//                                            ? AnyShapeStyle(activeGradient)
//                                            : AnyShapeStyle((colorScheme == .dark ? inactiveColor : Color.surfaceHiLightF1F2F7.opacity(0.7)))
//                                            
//                                            BarMark(
//                                                x: .value("Month", item.0),
//                                                y: .value("Spend", item.1)
//                                            )
//                                            .foregroundStyle(barStyle)
//                                            .cornerRadius(3)
//                                            .opacity(0.9)
//                                        }
//                                        
//                                        ForEach(Array(months.enumerated()), id: \.offset) { index, item in
//                                            
//                                            // Area
//                                            AreaMark(
//                                                x: .value("Month", item.0),
//                                                y: .value("Spend", item.1)
//                                            )
//                                            .foregroundStyle(
//                                                LinearGradient(
//                                                    colors: [
//                                                        themeManager.accentTextColor.opacity(0.15),
//                                                        themeManager.accentTextColor.opacity(0)
//                                                    ],
//                                                    startPoint: .top,
//                                                    endPoint: .bottom
//                                                )
//                                            )
//                                        }
//                                        
//                                        // MARK: - Line
//                                        
//                                        ForEach(Array(months.enumerated()), id: \.offset) { index, item in
//                                            
//                                            LineMark(
//                                                x: .value("Month", item.0),
//                                                y: .value("Spend", item.1)
//                                            )
//                                            .foregroundStyle(themeManager.accentTextColor)
//                                            .lineStyle(
//                                                StrokeStyle(
//                                                    lineWidth: 1.8,
//                                                    lineCap: .round,
//                                                    lineJoin: .round
//                                                )
//                                            )
//                                        }
//                                        
//                                        
//                                        // MARK: - Highlight Point
//                                        
//                                        PointMark(
//                                            x: .value("Month", months[0].0),
//                                            y: .value("Spend", months[0].1)
//                                        )
//                                        .foregroundStyle(.white)
//                                        .symbolSize(90)
//                                        
//                                        PointMark(
//                                            x: .value("Month", months[0].0),
//                                            y: .value("Spend", months[0].1)
//                                        )
//                                        .foregroundStyle(themeManager.accentTextColor)
//                                        .symbolSize(40)
//                                    }
//                                    .chartYAxis(.hidden)
//                                    .chartXAxis {
//                                        
//                                        AxisMarks(values: months.map { $0.0 }) { value in
//                                            
//                                            AxisValueLabel {
//                                                
//                                                if let month = value.as(String.self) {
//                                                    
//                                                    Text(month)
//                                                        .font(
//                                                            month == cuentmonth
//                                                            ? .jetBrainsSemiBold(8)
//                                                            : .jetBrainsRegular(8)
//                                                        )
//                                                        .tracking(0.5)
//                                                        .foregroundColor(
//                                                            month == cuentmonth
//                                                            ? themeManager.accentTextColor
//                                                            : Color("TextPrimary_ 0E101A_F4F1FB")
//                                                                .opacity(0.36)
//                                                        )
//                                                }
//                                            }
//                                            
//                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
//                                            AxisTick(stroke: StrokeStyle(lineWidth: 0))
//                                        }
//                                    }
//                                    .frame(height: 120)
//                                
//                                Rectangle()
//                                    .fill(
//                                        Color("TextPrimary_ 0E101A_F4F1FB")
//                                            .opacity(0.08)
//                                    )
//                                    .frame(height: 1)
//                                    .offset(x: 0, y: -14)
                                
                                
                                
                                /*VStack {
                                    
                                    if let selectedData = months.first(where: { $0.0 == selectedMonth }) {
                                        
                                        Text("₹\(selectedData.1, specifier: "%.2f")")
                                            .font(.jetBrainsSemiBold(12))
                                            .foregroundColor(themeManager.accentTextColor)
                                            .padding(.bottom, 4)
                                    }
                                    
                                    Chart {
                                        
                                        ForEach(Array(months.enumerated()), id: \.offset) { index, item in
                                            
                                            let isSelected = item.0 == selectedMonth
                                            
                                            let activeGradient = themeManager.accentGradient
                                            
                                            let inactiveColor = themeManager.white_white4.opacity(0.7)
                                            
                                            let barStyle: AnyShapeStyle = isSelected
                                            ? AnyShapeStyle(activeGradient)
                                            : AnyShapeStyle(
                                                colorScheme == .dark
                                                ? inactiveColor
                                                : Color.surfaceHiLightF1F2F7.opacity(0.7)
                                            )
                                            
                                            // MARK: - Bar
                                            
                                            BarMark(
                                                x: .value("Month", item.0),
                                                y: .value("Spend", item.1)
                                            )
                                            .foregroundStyle(barStyle)
                                            .cornerRadius(4)
                                            .opacity(isSelected ? 1 : 0.5)
                                            
                                            // MARK: - Line
                                            
                                            LineMark(
                                                x: .value("Month", item.0),
                                                y: .value("Spend", item.1)
                                            )
                                            .foregroundStyle(themeManager.accentTextColor)
                                            .lineStyle(
                                                StrokeStyle(
                                                    lineWidth: 2,
                                                    lineCap: .round,
                                                    lineJoin: .round
                                                )
                                            )
                                            
                                            // MARK: - Area
                                            
                                            AreaMark(
                                                x: .value("Month", item.0),
                                                y: .value("Spend", item.1)
                                            )
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [
                                                        themeManager.accentTextColor.opacity(0.15),
                                                        themeManager.accentTextColor.opacity(0)
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                        }
                                        
                                        // MARK: - Selected Point
                                        
                                        if let selectedData = months.first(where: { $0.0 == selectedMonth }) {
                                            
                                            PointMark(
                                                x: .value("Month", selectedData.0),
                                                y: .value("Spend", selectedData.1)
                                            )
                                            .foregroundStyle(.white)
                                            .symbolSize(90)
                                            
                                            PointMark(
                                                x: .value("Month", selectedData.0),
                                                y: .value("Spend", selectedData.1)
                                            )
                                            .foregroundStyle(themeManager.accentTextColor)
                                            .symbolSize(40)
                                        }
                                    }
//                                    .chartScrollableAxes(.horizontal)
//                                    .chartXVisibleDomain(length: 5)
                                    .chartYAxis(.hidden)
                                    .chartXAxis {
                                        
                                        AxisMarks(values: months.map { $0.0 }) { value in
                                            
                                            AxisValueLabel {
                                                
                                                if let month = value.as(String.self) {
                                                    
                                                    Text(month)
                                                        .font(
                                                            month == selectedMonth
                                                            ? .jetBrainsSemiBold(8)
                                                            : .jetBrainsRegular(8)
                                                        )
                                                        .foregroundColor(
                                                            month == selectedMonth
                                                            ? themeManager.accentTextColor
                                                            : Color("TextPrimary_ 0E101A_F4F1FB")
                                                                .opacity(0.36)
                                                        )
                                                }
                                            }
                                            
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                                            AxisTick(stroke: StrokeStyle(lineWidth: 0))
                                        }
                                    }
                                    .chartOverlay { proxy in
                                        
                                        GeometryReader { geometry in
                                            
                                            Rectangle()
                                                .fill(Color.clear)
                                                .contentShape(Rectangle())
                                                .gesture(
                                                    DragGesture(minimumDistance: 0)
                                                        .onChanged { value in
                                                            
                                                            let origin = geometry[proxy.plotAreaFrame].origin
                                                            
                                                            let currentX = value.location.x - origin.x
                                                            
                                                            if let month: String = proxy.value(atX: currentX) {
                                                                
                                                                selectedMonth = month
                                                            }
                                                        }
                                                )
                                        }
                                    }
                                    .frame(height: 160)
                                    
                                    Rectangle()
                                        .fill(
                                            Color("TextPrimary_ 0E101A_F4F1FB")
                                                .opacity(0.08)
                                        )
                                        .frame(height: 1)
                                        .offset(y: -14)
                                }
                                */
                                
                                
                                VStack {
                                       
                                       Chart {
                                           
                                           ForEach(Array(months.enumerated()), id: \.offset) { index, item in
                                               
                                               let isSelected = item.0 == cuentmonth
                                               
                                               let activeGradient = themeManager.accentGradient
                                               
                                               let inactiveColor = Color("gray_CBD5E1_475569").opacity(0.50)
                                               
//                                               let barStyle: AnyShapeStyle = isSelected
//                                               ? AnyShapeStyle(activeGradient)
//                                               : AnyShapeStyle(
//                                                   colorScheme == .dark
//                                                   ? inactiveColor
//                                                   : Color.surfaceHiLightF1F2F7.opacity(0.7)
//                                               )
                                               
                                               let barStyle: AnyShapeStyle = isSelected
                                               ? AnyShapeStyle(activeGradient)
                                               : AnyShapeStyle(
                                                inactiveColor
                                               )
                                               
                                               // MARK: - Bar
                                               
                                               BarMark(
                                                   x: .value("Month", item.0),
                                                   y: .value("Spend", item.1)
                                               )
                                               .foregroundStyle(barStyle)
                                               .cornerRadius(4)
                                               .opacity(isSelected ? 1 : 0.5)
                                               
                                               // MARK: - Line
                                               
                                               LineMark(
                                                   x: .value("Month", item.0),
                                                   y: .value("Spend", item.1)
                                               )
                                               .foregroundStyle(themeManager.accentTextColor)
                                               .lineStyle(
                                                   StrokeStyle(
                                                       lineWidth: 2,
                                                       lineCap: .round,
                                                       lineJoin: .round
                                                   )
                                               )
                                               
                                               // MARK: - Area
                                               
                                               AreaMark(
                                                   x: .value("Month", item.0),
                                                   y: .value("Spend", item.1)
                                               )
                                               .foregroundStyle(
                                                   LinearGradient(
                                                       colors: [
                                                           themeManager.accentTextColor.opacity(0.15),
                                                           themeManager.accentTextColor.opacity(0)
                                                       ],
                                                       startPoint: .top,
                                                       endPoint: .bottom
                                                   )
                                               )
                                           }
                                           
                                           // MARK: - Selected Point
                                           
                                           if let selectedData = months.first(where: { $0.0 == cuentmonth }) {
                                               
                                               PointMark(
                                                   x: .value("Month", selectedData.0),
                                                   y: .value("Spend", selectedData.1)
                                               )
                                               .foregroundStyle(.white)
                                               .symbolSize(90)
                                               
                                               PointMark(
                                                   x: .value("Month", selectedData.0),
                                                   y: .value("Spend", selectedData.1)
                                               )
                                               .foregroundStyle(themeManager.accentTextColor)
                                               .symbolSize(40)
                                               
                                               // MARK: - Price Annotation
                                               
                                               PointMark(
                                                   x: .value("Month", selectedData.0),
                                                   y: .value("Spend", selectedData.1)
                                               )
                                               .annotation(position: .top) {
                                                   
                                                   Text("\(homeResponse?.spendProjection?.currencySymbol ?? "")\(selectedData.1, specifier: "%.2f")")
                                                       .font(.jetBrainsSemiBold(11))
                                                       .foregroundColor(themeManager.accentTextColor)
                                                       .padding(.horizontal, 8)
                                                       .padding(.vertical, 4)
                                               }
                                           }
                                       }
//                                       .chartScrollableAxes(.horizontal)
//                                       .chartXVisibleDomain(length: 5)
                                       .chartYAxis(.hidden)
                                       .chartXAxis {
                                           
                                           AxisMarks(values: months.map { $0.0 }) { value in
                                               
                                               AxisValueLabel {
                                                   
                                                   if let month = value.as(String.self) {
                                                       
                                                       Text(month)
                                                           .font(
                                                               month == cuentmonth
                                                               ? .jetBrainsSemiBold(8)
                                                               : .jetBrainsRegular(8)
                                                           )
                                                           .tracking(0.5)
                                                           .foregroundColor(
                                                               month == cuentmonth
                                                               ? themeManager.accentTextColor
                                                               : Color("TextPrimary_ 0E101A_F4F1FB")
                                                                   .opacity(0.36)
                                                           )
                                                   }
                                               }
                                               
                                               AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                                               AxisTick(stroke: StrokeStyle(lineWidth: 0))
                                           }
                                       }
                                       .chartOverlay { proxy in
                                           
                                           GeometryReader { geometry in
                                               
                                               Rectangle()
                                                   .fill(Color.clear)
                                                   .contentShape(Rectangle())
                                                   .gesture(
                                                       DragGesture(minimumDistance: 0)
                                                           .onChanged { value in
                                                               
                                                               let origin = geometry[proxy.plotAreaFrame].origin
                                                               
                                                               let currentX = value.location.x - origin.x
                                                               
                                                               if let month: String = proxy.value(atX: currentX) {
                                                                   
                                                                   cuentmonth = month
                                                               }
                                                           }
                                                   )

                                           }
                                       }
                                       .frame(height: 160)
                                       
//                                       Rectangle()
//                                           .fill(
//                                               Color("TextPrimary_ 0E101A_F4F1FB")
//                                                   .opacity(0.08)
//                                           )
//                                           .frame(height: 1)
//                                           .offset(y: -14)
                                   }
                            
                                
                                
                            }
                            .padding(20)
                            .background(themeManager.white_white4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.08),
                                        lineWidth: 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(
                                color: Color("TextPrimary_ 0E101A_F4F1FB")
                                    .opacity(0.04),
                                radius: 8,
                                y: 4
                            )
                        }
                        
                        //MARK: - Where it goes
                        VStack(spacing: 0) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("WHERE IT GOES")
                                    .font(.jetBrainsRegular(11))
                                    .tracking(1.5)
                                    .foregroundColor(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.6)
                                    )
                                
                                Spacer()
                            }
                            .padding(.top, 22)
                            .padding(.bottom, 10)
                            
                            HStack(spacing: 18) {
                                // MARK: - Donut Chart
                                ZStack {
                                    DonutChartViewNew(items: items)
                                    
                                    // Center Content
                                    VStack(spacing: 2) {
                                        Text("TOTAL")
                                            .font(.jetBrainsRegular(9))
                                            .tracking(1)
                                            .foregroundColor(
                                                Color("TextPrimary_ 0E101A_F4F1FB")
                                                    .opacity(0.6)
                                            )
                                        
                                        Text(wigAmount)
                                            .font(.geistSemiBold(22))
                                            .tracking(-0.6)
                                            .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                                        
                                        Text("/mo")
                                            .font(.geistRegular(10))
                                            .foregroundColor(
                                                Color("TextPrimary_ 0E101A_F4F1FB")
                                                    .opacity(0.36)
                                            )
                                    }
                                }
                                .frame(width: 136, height: 136)
                                
                                // MARK: - Legend
                                VStack(spacing: 8) {
                                    ForEach(items) { item in
                                        HStack(spacing: 8) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color(hex: item.color))
                                                .frame(width: 8, height: 8)
                                            
                                            Text(item.name)
                                                .font(.geistRegular(12))
                                                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                                                .lineLimit(1)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text("\(item.currencySymbol)\(item.amountStr)")
                                                .font(.jetBrainsRegular(11))
                                                .foregroundColor(
                                                    Color("TextPrimary_ 0E101A_F4F1FB")
                                                        .opacity(0.6)
                                                )
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(20)
                            .background(themeManager.white_white4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.08),
                                        lineWidth: 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(
                                color: Color("TextPrimary_ 0E101A_F4F1FB")
                                    .opacity(0.04),
                                radius: 8,
                                y: 4
                            )
                        }
                        
                        //MARK: - Top spenders
                        VStack(spacing: 0) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("TOP SPENDERS")
                                    .font(.jetBrainsRegular(11))
                                    .tracking(1.5)
                                    .foregroundColor(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.6)
                                    )
                                
                                Spacer()
                                
                                Text("monthly")
                                    .font(.jetBrainsRegular(10))
                                    .tracking(0.5)
                                    .foregroundColor(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.36)
                                    )
                            }
                            .padding(.top, 22)
                            .padding(.bottom, 10)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(subscriptions.enumerated()), id: \.offset) { index, item in
                                    SubscriptionRowNew(
                                        item: item,
                                        delay: Double(index) * 0.08
                                    )
                                    .onTapGesture {
                                        AppIntentRouter.shared.navigate(to: .subscriptionMatchView(fromList: true, subscriptionId: item.id))
                                    }
                                }
                            }
                            .padding(18)
                            .background(themeManager.white_white4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.08),
                                        lineWidth: 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(
                                color: Color("TextPrimary_ 0E101A_F4F1FB")
                                    .opacity(0.04),
                                radius: 8,
                                y: 4
                            )
                        }
                        .padding(.bottom, upcomingItems.count == 0 ? 120 : 0)
                        
                        //MARK: - Net renewal
                        if upcomingItems.count > 0 {
                            VStack(spacing: 0) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text("NEXT RENEWAL")
                                        .font(.jetBrainsRegular(11))
                                        .tracking(1.5)
                                        .foregroundColor(
                                            Color("TextPrimary_ 0E101A_F4F1FB")
                                                .opacity(0.6)
                                        )
                                    
                                    Spacer()
                                    
                                    Text(upcomingFirstItem?.subtitle ?? "")
                                        .font(.jetBrainsRegular(10))
                                        .tracking(0.5)
                                        .foregroundColor(
                                            Color("TextPrimary_ 0E101A_F4F1FB")
                                                .opacity(0.36)
                                        )
                                }
                                .padding(.top, 22)
                                .padding(.bottom, 10)
                                
                                VStack(spacing: 10) {
                                    // MARK: - Featured Card
                                    ZStack {
                                        HStack(spacing: 14) {
                                            // MARK: - Netflix Icon
                                            ZStack {
                                                /*RoundedRectangle(cornerRadius: 16)
                                                 .fill(Color.black)
                                                 
                                                 Text("N")
                                                 .font(.geistBold(28))
                                                 .foregroundColor(Color(hex: "#E50914"))*/
                                                
                                                AvatarView(
                                                    serviceName: upcomingFirstItem?.name ?? "",
                                                    serviceLogo: upcomingFirstItem?.icon ?? "",
                                                    size: 56,
                                                    cornerRadius: 16,
                                                    fromPreview: false,
                                                    isShadow: false
                                                )
                                                
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(
                                                        themeManager.accentTextColor
                                                            .opacity(0.23),
                                                        lineWidth: 2
                                                    )
                                                    .padding(-4)
                                                    .scaleEffect(animate ? 1.25 : 1.0)
                                                    .opacity(animate ? 0.1 : 0.8)
                                                    .animation(
                                                        .easeOut(duration: 2)
                                                        .repeatForever(autoreverses: false),
                                                        value: animate
                                                    )
                                                    .onAppear {
                                                        animate = true
                                                    }
                                            }
                                            .frame(width: 56, height: 56)
                                            
                                            // MARK: - Content
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("CHARGES \(upcomingFirstItem?.subtitle ?? "")".uppercased())
                                                    .font(.jetBrainsRegular(10))
                                                    .tracking(1.5)
                                                    .foregroundColor(themeManager.accentTextColor)
                                                
                                                Text(upcomingFirstItem?.name ?? "")
                                                    .font(.geistSemiBold(18))
                                                    .tracking(-0.4)
                                                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                                                
                                                Text(upcomingFirstItem?.planName ?? "")
                                                    .font(.geistRegular(12))
                                                    .foregroundColor(
                                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                                            .opacity(0.6)
                                                    )
                                            }
                                            
                                            Spacer()
                                            
                                            // MARK: - Price
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text("\(upcomingFirstItem?.currencySymbol ?? "")\(upcomingFirstItem?.amount ?? "")")
                                                    .font(.geistSemiBold(22))
                                                    .tracking(-0.6)
                                                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                                                
                                                Text(upcomingFirstItem?.billingCycleShortLabel ?? "")
                                                    .font(.jetBrainsRegular(10))
                                                    .foregroundColor(
                                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                                            .opacity(0.36)
                                                    )
                                            }
                                        }
                                        .padding(18)
                                    }
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                themeManager.selectedAccent.primaryColor.opacity(0.063),
                                                themeManager.selectedAccent.lastColor.opacity(0.03)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(
                                                themeManager.accentTextColor
                                                    .opacity(0.157),
                                                lineWidth: 1
                                            )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .onTapGesture {
                                        if let upcomingFirstItem {
                                            AppIntentRouter.shared.navigate(to: .subscriptionMatchView(fromList: true, subscriptionId: upcomingFirstItem.subscriptionId))
                                        }
                                    }
                                    
                                    // MARK: - List
                                    VStack(spacing: 8) {
                                        ForEach(upcomingItems) { item in
                                            UpcomingRow(item: item)
                                                .onTapGesture {
                                                    AppIntentRouter.shared.navigate(to: .subscriptionMatchView(fromList: true, subscriptionId: item.subscriptionId))
                                                }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 120)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .applyAppBackground()
                
            }
            else{
                WelcomeHomeView(currentPlan: currentPlan)
                    .applyGlobalTransition()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            guard AppState.shared.isLoggedIn else { return }
            Constants.saveDefaults(value: true, key: "isSyncing")
            if let fullName = commonApiVM.userInfoResponse?.fullName{
                self.fullName = fullName
            }
            
            let delay = homeVM.isInitialLoad ? 0.5 : 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                homeVM.home(input: HomeRequest(userId: Constants.getUserId()))
                homeVM.isInitialLoad = false
            }
            let now = Date()
            selectedYear    = Calendar.current.component(.year, from: now)
            //            homeYearlyGraphApi()
            commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
            //            commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            monthYear = formatter.string(from: now)
        }
        .onChange(of: homeVM.homeResponse){ _ in updateHomeResponse() }
        .onChange(of: homeVM.apiError) { _ in
            if homeVM.apiError != nil {
                withAnimation(.customScreenAnimation) {
                    isHome = false
                }
            }
        }
        .onChange(of: commonApiVM.userInfoResponse){ _ in getUserDetailsResponse() }
        .sheet(isPresented: $showYouSavedSheet) {
            YouSavedBottomSheet(
                title       : youSaved,
                subTitle    : youSavedExpiry,
                lastMonth   : "$\(homeVM.homeYearGraphResponse?.monthlySpend?.suffix(2).first?.amount ?? 0.0)",
                thisMonth   : monthlySpend,
                action      : {
                    // Action for analytics
                }
            )
            .presentationDetents([.height(520)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showSaveSheet) {
            YouSavedBottomSheet(
                title       : "Save 58% on Netflix",
                subTitle    : "Applies to your next renewal",
                lastMonth   : "$\(homeVM.homeYearGraphResponse?.monthlySpend?.suffix(2).first?.amount ?? 0.0)",
                thisMonth   : monthlySpend,
                isSave      : true,
                action      : {
                    // Action for analytics
                }
            )
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.hidden)
        }
    }
    
    //MARK: - User defined methods
    //MARK: goToNotifications
    private func goToNotifications() {
        Constants.FeatureConfig.performS4Action {
            homeVM.navigate(to: .notifications)
        }
    }
    
    private func clickOnSave() {
        showSaveSheet = true
    }
    
    private func clickOnYouSaved() {
        showYouSavedSheet = true
    }
    
    private func goToSubscriptions() {
        tabSelected = .subscriptions
    }
    
    private func goToAddSubscriptions() {
        tabSelected = .addSubscription
    }
    
    private func updateHomeResponse() {
        homeResponse        = homeVM.homeResponse
        let monthlyOverview = homeResponse?.monthlyOverview
        let status = monthlyOverview?.status ?? ""
        if status == "on_track"
        {
            isOnTrack = true
        }
        else if status == "off_track"{
            isOnTrack = false
        }
        msCurrency = monthlyOverview?.currencySymbol ?? ""
        let amount = monthlyOverview?.amount ?? 0.00
        let formatted = String(format: "%.2f", amount)
        let components = formatted.split(separator: ".")
        msAmmount = String(components.first ?? "")
        msAmmountD = "." + String(components.last ?? "")
        let deltaDirection = monthlyOverview?.deltaDirection ?? ""
        let deltaAmount = monthlyOverview?.deltaAmount ?? 0.00
        let formattedDA = String(format: "%.2f", deltaAmount)
        if deltaDirection == "down"
        {
            msDeltaValue = "↓ \(msCurrency)\(formattedDA) vs last month"
        }
        else if deltaDirection == "up"
        {
            msDeltaValue = "↑ \(msCurrency)\(formattedDA) vs last month"
        }
        else{
            msDeltaValue = "\(msCurrency)\(formattedDA) vs last month"
        }
        
        let spendProjection = homeResponse?.spendProjection
        let pnsformatted = String(format: "%.2f", spendProjection?.projectedAnnualSpend ?? 0.00)
        pnsAmount = "\(spendProjection?.currencySymbol ?? "")\(pnsformatted)"
        let peakformatted = String(format: "%.2f", spendProjection?.peakAmount ?? 0.00)
        let peakAmount = "\(spendProjection?.currencySymbol ?? "")\(peakformatted)"
        if deltaDirection == "down"
        {
            pnsDeltaValue = "↓ \(peakAmount) peak in \(spendProjection?.peakMonth ?? "")"
        }
        else if deltaDirection == "up"
        {
            pnsDeltaValue = "↑ \(peakAmount) peak in \(spendProjection?.peakMonth ?? "")"
        }
        else{
            pnsDeltaValue = "\(peakAmount) peak in \(spendProjection?.peakMonth ?? "")"
        }
        months.removeAll()
        let monthsobjc = homeResponse?.spendProjection?.months ?? []
        for item in monthsobjc
        {
            months.append(("\(item.month ?? "")".uppercased(), item.amount ?? 0.0))
        }
        if months.count > 0 {
            cuentmonth = months[0].0
        }
        let whereItGoes = homeResponse?.whereItGoes
        let wigformatted = String(format: "%.0f", whereItGoes?.totalAmount ?? 0.00)
        wigAmount = "\(whereItGoes?.currencySymbol ?? "")\(wigformatted)"
        items.removeAll()
        let categories = homeResponse?.whereItGoes?.categories ?? []
        for item in categories
        {
            let itformatted = String(format: "%.2f", item.totalAmount ?? 0.00)
            items.append(CategoryItem.init(name             : item.categoryName ?? "",
                                           amount           : item.totalAmount ?? 0.00,
                                           amountStr        : itformatted,
                                           color            : item.color ?? "",
                                           currencySymbol   : item.currencySymbol ?? ""))
        }
        
        subscriptions.removeAll()
        let topSpenders = homeResponse?.topSpenders ?? []
        for item in topSpenders
        {
            let itformatted = String(format: "%.2f", item.amount ?? 0.00)
            subscriptions.append(SubscriptionItemNew.init(id: item.id ?? "", name: item.serviceName ?? "", amountStr: itformatted, amount: item.amount ?? 0.00, progress: (item.progressPercentage ?? 0.00)/100, serviceLogo: item.serviceLogo ?? "", currencySymbol: item.currencySymbol ?? ""))
        }
        
        upcomingItems.removeAll()
        let nextRenewals = homeResponse?.nextRenewals ?? []
        for item in nextRenewals
        {
            let itformatted = String(format: "%.2f", item.amount ?? 0.00)
            upcomingItems.append(UpcomingCharge.init(subscriptionId: item.id ?? "", name: item.serviceName ?? "", subtitle: "in \(item.daysUntil ?? 0)d", amount: itformatted, icon: item.serviceLogo ?? "", planName: item.planName ?? "", billingCycleShortLabel: item.billingCycleShortLabel ?? "", currencySymbol: item.currencySymbol ?? ""))
        }
        if upcomingItems.count > 0
        {
            upcomingFirstItem = upcomingItems[0]
            upcomingItems.remove(at: 0)
        }
        
        withAnimation(.customScreenAnimation) {
            if let response = homeVM.homeResponse {
                isHome = (response.totalSubscriptionCount == 0 || response.totalSubscriptionCount == nil) ? false : true
            } else if homeVM.apiError != nil {
                isHome = false
            }
        }
    }
    
    func homeYearlyGraphApi(){
        homeVM.homeYearlyGraph(input: HomeYearlyGraphRequest(userId: Constants.getUserId(), year: selectedYear))
    }
    
    private func getUserDetailsResponse() {
        currentPlan = commonApiVM.userInfoResponse?.internalPlanType ?? 0
        if let fullName = commonApiVM.userInfoResponse?.fullName{
            self.fullName = fullName
        }
    }
    private func goToProfile() {
        AppIntentRouter.shared.navigate(to: .profileTab)
    }
}

//MARK: - SubscriptionAnalyticsCard
struct SubscriptionAnalyticsCard: View {
    
    var topCategory         : TopCategoriesData
    var action: () -> Void  = {}
    
    var body: some View {
        HStack(spacing: 26) {
            
            // MARK: Circular Progress View
            ZStack {
                Circle()
                    .stroke(.neutral300Border, lineWidth: 2)
                Circle()
                    .trim(from: 0, to: CGFloat((topCategory.percentage ?? 0.0) / 100))
                    .stroke(Color.blueMain700, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: topCategory.percentage ?? 0.0)
                
                Text("\(Int(topCategory.percentage ?? 0.0))%")
                    .font(.appSemiBold(16))
                    .foregroundColor(.navyBlueCTA700)
            }
            .frame(width: 58, height: 58)
            
            // MARK: View analytics button
            VStack(alignment: .leading, spacing: 4) {
                Text("Of your subscriptions is in \(topCategory.categoryName ?? "") platforms")
                    .font(.appRegular(16))
                    .foregroundColor(.neutralMain700)
                    .multilineTextAlignment(.leading)
                
                HStack{
                    Spacer()
                    Button(action: action) {
                        HStack{
                            Text("View analytics")
                                .font(.appRegular(14))
                                .foregroundColor(.navyBlueCTA700)
                            Image("arrow_blue")
                                .frame(width: 24,height: 24, alignment: .trailing)
                        }
                    }
                    .frame(alignment: .trailing)
                }
            }
        }
        .padding(13)
        .background(.whiteBlackBG)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.neutral300Border, lineWidth: 1)
        )
        //        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

//MARK: - HeaderView
struct HeaderView: View {
    
    //MARK: - Properties
    var title                           : LocalizedStringKey
    var subTitle                        : LocalizedStringKey = "Here's your subscription overview"
    var titleFont                       = 28
    let action                          : () -> Void
    @EnvironmentObject var commonApiVM  : CommonAPIViewModel
    
    var body: some View {
        //MARK: notification btn
        ZStack(alignment: .topTrailing) {
            Button(action: action) {
                Image("notification-03")
                    .frame(width: 32, height: 32)
            }
            if let count = commonApiVM.unreadCountResponse?.unreadCount{
                if count != 0{
                    let filterCount = count >= 10 ? "9+" : "\(count)"
                    Text(filterCount)
                        .font(.appBold(11))
                        .foregroundColor(Color.white)
                        .frame(width: 16, height: 15)
                        .multilineTextAlignment(.center)
                    //                        .padding(4)
                        .background(Color.redBadge)
                        .cornerRadius(4)
                        .offset(x: 0, y: -5)
                }
            }
            
            VStack(alignment: .leading,spacing: 2) {
                // MARK: - Title
                Text(title)
                    .font(.appRegular(CGFloat(titleFont)))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.leading)
                
                // MARK: - SubTitle
                //                Text(subTitle)
                //                    .font(.appRegular(18))
                //                    .multilineTextAlignment(.leading)
                //                    .foregroundColor(Color.neutral500)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing,16)
        }
        .offset(x: 0, y: -5)
        .onAppear{
            if Constants.FeatureConfig.isS4Enabled {
                //                if commonApiVM.unreadCountResponse == nil{
                //                    commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
                //                }
                guard AppState.shared.isLoggedIn else { return }
                commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
            }
        }
    }
}

//MARK: - HeaderViewWithProfile
struct HeaderViewWithProfile: View {
    
    //MARK: - Properties
    var title                           : LocalizedStringKey
    var username                        = ""
    var subTitle                        : LocalizedStringKey = "Here's your subscription overview"
    var titleFont                       = 28
    let action                          : () -> Void
    let actionProfile                   : () -> Void
    var profileLogo                     = ""
    @EnvironmentObject var commonApiVM  : CommonAPIViewModel
    @EnvironmentObject var themeManager : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        //MARK: notification btn
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    Button(action: action) {
                        if colorScheme == .dark {
                            Image("notification-03")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .frame(width: 40, height: 40)
                                .background(
                                    themeManager.white_white4,
                                    in: RoundedRectangle(cornerRadius: 20)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.08), lineWidth: 1)
                                )
                        }
                        else{
                            Image("notification-03")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .frame(width: 40, height: 40)
                                .background(
                                    themeManager.white_white4,
                                    in: RoundedRectangle(cornerRadius: 20)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.08), lineWidth: 1)
                                )
                        }
                    }
                    
                    if let count = commonApiVM.unreadCountResponse?.unreadCount{
                        if count != 0{
                            let filterCount = ""//count >= 10 ? "9+" : "\(count)"
                            Text(filterCount)
                                .font(.appBold(11))
                                .foregroundColor(.white)
                                .frame(width: 5, height: 5)
                                .padding(3)
                                .background(themeManager.accentTextColor)
                                .clipShape(Circle())
                                .shadow(color: themeManager.accentShadowColor, radius: 5, x: 0, y: 0)
                                .offset(x: -7, y: 4)
                        }
                    }
                }
                Button(action: actionProfile) {
                    AvatarView(
                        serviceName: username,
                        serviceLogo: profileLogo,
                        size: 40,
                        cornerRadius: 20,
                        fromPreview: true
                    )
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 16)
            
            VStack(alignment: .leading,spacing: 2) {
                // MARK: - Title
                HStack{
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 24)
                    
                    
                    if colorScheme == .dark {
                        Image("AppNameDark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 14)
                    } else {
                        Image("AppName")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 14)
                    }
                }
                
                //MARK: - SubTitle
                Text(title)
                    .font(.geistSemiBold(22))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing,16)
            .padding(.horizontal,20)
        }
        .offset(x: 0, y: -5)
        .onAppear{
            if Constants.FeatureConfig.isS4Enabled {
                //                if commonApiVM.unreadCountResponse == nil{
                //                    commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
                //                }
                guard AppState.shared.isLoggedIn else { return }
                commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
            }
        }
    }
}

//MARK: - AvatarView
//struct AvatarView: View {
//    var serviceName     : String
//    var serviceLogo     : String?
//    var size            : CGFloat = 34
//    var cornerRadius    : CGFloat = 8
//    var fontSize        : CGFloat = 18
//    var fromPreview     : Bool = false
//    @State private var imageLoadFailed          = false
//    @EnvironmentObject var themeManager : ThemeManager
//    
//    private var initials: String {
//        let words = serviceName
//            .split(separator: " ")
//            .filter { !$0.isEmpty }
//        
//        if words.count == 1 {
//            return String(words[0].prefix(1)).uppercased()
//        } else {
//            return words.prefix(2)
//                .map { String($0.prefix(1)).uppercased() }
//                .joined()
//        }
//    }
//    
//    private var serviceLogoURL: URL? {
//        guard let logo = serviceLogo,
//              !logo.isEmpty else { return nil }
//        
//        if let url = URL(string: logo), url.scheme != nil {
//            // Already absolute URL
//            return url
//        }
//        
//        let baseURL = Constants.getUserDefaultsValue(for: Constants.providerBaseUrl)
//        return URL(string: baseURL + logo)
//    }
//    
//    var body: some View {
//        Group {
//            if (serviceLogo ?? "").isEmpty {
//                if fromPreview{
//                    ZStack {
//                        themeManager.accentGradient
//                        Text(initials)
//                            .font(.geistBold(fontSize))
//                            .foregroundColor(.white)
//                    }
//                    .frame(width: size, height: size)
//                    .background(
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .fill(Color.clear)
//                            .shadow(
//                                color: themeManager.accentShadowColor,
//                                radius: 8,
//                                x: 0,
//                                y: 4
//                            )
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//                }
//                else{
//                    ZStack {
//                        Color.whiteBlackBG
//                        Text(initials)
//                            .font(.geistBold(fontSize))
//                            .foregroundColor(.white)
//                    }
//                    .frame(width: size, height: size)
//                    .background(
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .fill(Color.clear)
//                            .shadow(
//                                color: themeManager.accentShadowColor,
//                                radius: 8,
//                                x: 0,
//                                y: 4
//                            )
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//                }
//                
//            } else {
//                if fromPreview{
//                    if let url = serviceLogoURL {
//                        if imageLoadFailed {
//                            Image("profile_avatar")
//                                .resizable()
//                                .scaledToFill()
//                        }else{
//                            WebImage(url: url)
//                                .resizable()
//                                .onFailure { _ in
//                                    imageLoadFailed = true
//                                }
//                                .indicator(.activity)
//                                .transition(.fade(duration: 0.5))
//                                .scaledToFit()
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: cornerRadius)
//                                        .stroke(.neutral300Border, lineWidth: 1)
//                                )
//                            
//                                .cornerRadius(cornerRadius)
//                        }
//                    }
//                }else{
//                    if imageLoadFailed {
//                        Image("profile_avatar")
//                            .resizable()
//                            .scaledToFill()
//                    }else{
//                        WebImage(url: URL(string: serviceLogo ?? ""))
//                            .resizable()
//                            .onFailure { _ in
//                                imageLoadFailed = true
//                            }
//                            .indicator(.activity)
//                            .transition(.fade(duration: 0.5))
//                            .scaledToFit()
//                            .overlay(
//                                RoundedRectangle(cornerRadius: cornerRadius)
//                                    .stroke(.neutral300Border, lineWidth: 1)
//                            )
//                            .cornerRadius(cornerRadius)
//                    }
//                }
//            }
//        }
//        .frame(width: size, height: size)
//        .cornerRadius(cornerRadius)
//        .clipped()
//    }
//}

struct AvatarView: View {
    var serviceName     : String
    var serviceLogo     : String?
    var size            : CGFloat = 34
    var cornerRadius    : CGFloat = 8
    var fontSize        : CGFloat = 18
    var fromPreview     : Bool = false
    var isShadow        : Bool = true
    @State private var imageLoadFailed          = false
    @EnvironmentObject var themeManager : ThemeManager
    
    private var initials: String {
        let words = serviceName
            .split(separator: " ")
            .filter { !$0.isEmpty }
        
        if words.count == 1 {
            return String(words[0].prefix(1)).uppercased()
        } else {
            return words.prefix(2)
                .map { String($0.prefix(1)).uppercased() }
                .joined()
        }
    }
    
    private var serviceLogoURL: URL? {
        guard let logo = serviceLogo,
              !logo.isEmpty else { return nil }
        
        if let url = URL(string: logo), url.scheme != nil {
            // Already absolute URL
            return url
        }
        
        let baseURL = Constants.getUserDefaultsValue(for: Constants.providerBaseUrl)
        return URL(string: baseURL + logo)
    }
    
    var body: some View {
        Group {
            if (serviceLogo ?? "").isEmpty {
                ZStack {
                    if fromPreview {
                        themeManager.accentGradient
                    } else {
                        Color.flagBgF1F2F7F7F7F9
                    }
                    
                    Text(initials)
                        .font(.geistBold(fontSize))
                        .foregroundColor(fromPreview == true ? .white : Color("TextPrimary_ 0E101A_F4F1FB"))
                }
            } else {
                Group {
                    if fromPreview {
                        if let url = serviceLogoURL {
                            if imageLoadFailed {
//                                Image("profile")
//                                    .resizable()
//                                    .scaledToFill()
                                ZStack {
                                    if fromPreview {
                                        themeManager.accentGradient
                                    } else {
                                        Color.flagBgF1F2F7F7F7F9
                                    }
                                    
                                    Text(initials)
                                        .font(.geistBold(fontSize))
                                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                                }
                            } else {
                                WebImage(url: url)
                                    .resizable()
                                    .onFailure { _ in imageLoadFailed = true }
                                    .indicator(.activity)
                                    .transition(.fade(duration: 0.5))
                                    .scaledToFit()
                            }
                        }
                    } else {
                        if imageLoadFailed {
//                            Image("profile")
//                                .resizable()
//                                .scaledToFill()
                            ZStack {
                                if fromPreview {
                                    themeManager.accentGradient
                                } else {
                                    Color.flagBgF1F2F7F7F7F9
                                }
                                
                                Text(initials)
                                    .font(.geistBold(fontSize))
                                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                            }
                        } else {
                            WebImage(url: URL(string: serviceLogo ?? ""))
                                .resizable()
                                .onFailure { _ in imageLoadFailed = true }
                                .indicator(.activity)
                                .transition(.fade(duration: 0.5))
                                .scaledToFit()
                        }
                    }
                }
                // Optional: Adds a solid background so transparent PNGs cast a
                // rounded box shadow instead of casting a shadow of the logo itself
                .background(themeManager.white_white4)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//        .overlay(
//            RoundedRectangle(cornerRadius: cornerRadius)
//                .stroke(.neutral300Border, lineWidth: 1)
//        )
        // Apply the shadow AFTER all framing and clipping is done
        .shadow(
            color: isShadow ? themeManager.accentShadowColor : Color.clear,
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

//MARK: - TopSpendingSubscriptionsView
struct TopSpendingSubscriptionsView: View {
    
    let data : [TopCategoriesData]
    var maxAmount: Double {
        data.map { $0.totalAmount ?? 0.0 }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Top spending subscriptions")
                .font(.appRegular(16))
                .foregroundColor(Color.neutralMain700)
                .padding(.bottom, 15)
                .padding(.horizontal, 15)
            Divider()
                .overlay(Color.neutral300Border)
            VStack(spacing: 16) {
                ForEach(data.prefix(3)) { item in
                    SpendingRowView(
                        title          : item.categoryName ?? "",
                        amount         : item.totalAmount ?? 0.0,
                        percentage     : item.percentage ?? 0.0,
                        color          : item.color ?? "",
                        currencySymbol : item.currencySymbol ?? "$"
                    )
                }
            }
            .padding(15)
            
            HStack{
                Spacer()
                Text("View More")
                    .font(.appRegular(16))
                    .foregroundColor(.blueMain700)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Constants.FeatureConfig.performS4Action {
                            AppIntentRouter.shared.navigate(to: .subscriptionsListView(selectedSegment: .third))
                        }
                    }
                Spacer()
            }
        }
        .padding(.vertical, 16)
        .background(.whiteBlackBG)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.neutral300Border, lineWidth: 1)
        )
        .cornerRadius(12)
        //        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

//MARK: - SpendingRowView
struct SpendingRowView: View {
    
    let title          : String
    let amount         : Double
    let percentage     : Double
    let color          : String
    let currencySymbol : String
    var progress       : CGFloat {
        CGFloat(percentage / 100)
    }
    
    var body: some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
                .frame(width: 90, alignment: .leading)
                .padding(.trailing, 20)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.clear)
                    Capsule()
                        .fill(Color.safeHex(color))
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 10)
            .padding(.trailing, 7)
            Text(String(format: "%@%.2f", currencySymbol, amount))
                .font(.appBold(14))
                .foregroundColor(.neutralMain700)
                .frame(alignment: .trailing)
        }
    }
}

//struct YearOverviewChartView: View {
//
//    @State private var selected             : MonthlySpendData?
//    @State private var clearSelectionTask   : Task<Void, Never>?
//    let visibleMonths                       : [String] = ["Jan", "Mar", "May", "Jul", "Sep", "Nov"]
//    let fakeMonths                          = ["Jan", "Mar", "May", "Jul", "Sep", "Nov"]
//    let data                                : [MonthlySpendData]
//    var currencySymbol                      : String
//    @State var openYearSheet                = false
//    @State var year                         : Int = 2025
//    let onDone                              : (Int) -> Void
//
//    private var yAxisValues: [Double] {
//        let maxAmount = data.map { $0.amount }.max() ?? 0
//        let effectiveMax = maxAmount == 0 ? 5 : maxAmount
//        let step = effectiveMax / 5
//        return (0...5).map { Double($0) * step }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            // Header
//            HStack {
//                Text("Year Overview")
//                    .font(.appRegular(16))
//                    .foregroundStyle(Color.neutralMain700)
//                Spacer()
//                HStack(spacing: 4) {
//                    Text(String(year))
//                        .font(.appRegular(16))
//                        .foregroundStyle(Color.grayLG)
//                    Image(systemName: "chevron.down")
//                        .font(.system(size: 12))
//                }
//                .padding(.horizontal, 10)
//                .padding(.vertical, 6)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 4)
//                        .stroke(.neutral300Border)
//                )
//                .onTapGesture {
//                    openYearSheet = true
//                }
//            }
//            .padding(.horizontal, 20)
//            Spacer()
//
//            Divider()
//                .overlay(Color.neutral300Border)
//                .padding(.bottom, 25)
//
//            ZStack(alignment: .leading) {
//                Rectangle()
//                    .fill(Color.neutral300Border)
//                    .frame(width: 1)
//                    .padding(.top, 0)
//                    .padding(.bottom, 0)
////                    .padding(.leading, -10)
//                    .offset(x: 32)
//
//                // Chart
//                Chart {
//                    ForEach(data) { item in
//                        AreaMark(
//                            x: .value("Month", item.month),
//                            y: .value("Value", item.amount)
//                        )
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [
//                                    Color.graphGradient1.opacity(0.25), // near line
//                                    Color.graphGradient1.opacity(0.05), // fade
//                                    Color.clear                          // bottom
//                                ],
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
//
//                        LineMark(
//                            x: .value("Month", item.month),
//                            y: .value("Value", item.amount)
//                        )
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [Color.graphGradient1, Color.graphGradient2],
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        )
//                        .lineStyle(.init(lineWidth: 1))
////
//                        // OUTERMOST border (grey)
//                        PointMark(
//                            x: .value("Month", item.month),
//                            y: .value("Value", item.amount)
//                        )
//                        .symbolSize(300)
//                        .opacity(selected?.id == item.id ? 1 : 0)
//                        .foregroundStyle(Color.graphBorder)
//
//                        PointMark(
//                            x: .value("Month", item.month),
//                            y: .value("Value", item.amount)
//                        )
//                        .symbolSize(200) // outer size
//                        .opacity(selected?.id == item.id ? 1 : 0)
//                        .foregroundStyle(Color.white)
//                        // INNER purple dot
//                        PointMark(
//                            x: .value("Month", item.month),
//                            y: .value("Value", item.amount)
//                        )
//                        .symbolSize(80) // inner size
//                        .opacity(selected?.id == item.id ? 1 : 0)
//                        .foregroundStyle(Color.graphGradient1)
//                    }
//                }
//                .chartYScale(domain: 0...(yAxisValues.last ?? 5))
//                .chartXScale(range: .plotDimension(padding: 0))
//                .chartYAxis {
//                    AxisMarks(position: .leading, values: yAxisValues) { value in
//                        AxisValueLabel {
//                            if let y = value.as(Double.self) {
//                                Text("\(Int(y))")
//                                    .font(.appRegular(16))
//                                    .foregroundStyle(Color.neutralMain700)
//                                    .padding(.trailing, 20)
//                            }
//                        }
//                    }
//                }
//
//                .chartXAxis {
//
//                }
//                .frame(height: 220)
//                .chartOverlay { proxy in
//                    GeometryReader { geo in
//                        ZStack(alignment: .topLeading) {
//                            ForEach(yAxisValues, id: \.self) { value in
//                                if value != 0, let yPos = proxy.position(forY: value) {
//                                    DashedHorizontalDivider(dash: [2,2])
//                                        .frame(height: 1)
//                                        .position(
//                                            x: geo.size.width / 2,
//                                            y: yPos
//                                        )
//                                        .padding(.leading, 18)
//                                        .padding(.trailing, 10)
//                                }
//                            }
//
//                            Rectangle()
//                                .fill(Color.clear)
//                                .contentShape(Rectangle())
//                                .gesture(
//                                    DragGesture(minimumDistance: 0)
//                                        .onChanged { value in
//                                            let x = value.location.x
//                                            if let month: String = proxy.value(atX: x) {
//                                                selected = data.first { $0.month == month }
//                                            }
//                                        }
//                                )
//
//                            if let selected,
//                               let xPos = proxy.position(forX: selected.month),
//                               let yPos = proxy.position(forY: selected.amount) {
//
//                                VStack {
//                                    Text("\(selected.month) : \(currencySymbol)\(Int(selected.amount))")
//                                        .font(.appMedium(10))
//                                        .padding(6)
//                                        .background(Color.white)
//                                        .cornerRadius(8)
//                                        .shadow(color: Color.dropShadow, radius: 4, x: 0, y: 2)
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 8)
//                                                .stroke(.neutral300Border, lineWidth: 1)
//                                        )
//                                }
//                                .position(
//                                    x: xPos,
//                                    y: yPos - 30
//                                )
//                            }
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal, 20)
//
//            Divider()
//                .background(Color.neutral300Border)
//                .padding(.top, -2)
//                .padding(.leading, 22)
//                .padding(.horizontal, 30)
//                .padding(.trailing, 10)
//
//            HStack(spacing: 0) {
//                ForEach(fakeMonths, id: \.self) { month in
//                    Text(month)
//                        .font(.appRegular(16))
//                        .foregroundColor(Color.neutralMain700)
//                        .frame(maxWidth: .infinity)
//                }
//            }
//            .padding(.top, 10)
//            .padding(.horizontal, 30)
//            .padding(.trailing, 10)
//
//            HStack{
//                Spacer()
//                Text("View More")
//                    .font(.appRegular(16))
//                    .foregroundColor(.blueMain700)
//                Spacer()
//            }
//            .padding(.top, 16)
//        }
//        .padding(.vertical, 20)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(.neutral300Border, lineWidth: 1)
//        )
//        .background(.whiteBlackBG)
//        .cornerRadius(12)
//        .onChange(of: selected?.id) { _ in
//            clearSelectionTask?.cancel()
//            guard selected != nil else { return }
//            clearSelectionTask = Task {
//                try? await Task.sleep(nanoseconds: 3_000_000_000)
//                await MainActor.run {
//                    selected = nil
//                }
//            }
//        }
//        .sheet(isPresented: $openYearSheet) {
//            CustomYearBottomSheet(isPresented   : $openYearSheet,
//                                  onDone        : { year in
//                self.year = year
//                onDone(year)
//            })
//            .presentationDetents([.height(300)])
//            .presentationDragIndicator(.hidden)
//        }
//    }
//}

//MARK: - YearOverviewChartView
struct YearOverviewChartView: View {
    
    @State private var selected             : MonthlySpendData?
    @State private var clearSelectionTask   : Task<Void, Never>?
    let visibleMonths                       : [String] = ["Jan", "Mar", "May", "Jul", "Sep", "Nov"]
    let fakeMonths                          = ["Jan", "Mar", "May", "Jul", "Sep", "Nov"]
    let data                                : [MonthlySpendData]
    var currencySymbol                      : String
    @State var openYearSheet                = false
    @State var year                         : Int = 2025
    let onDone                              : (Int) -> Void
    
    private let monthMap: [String: Int] = [
        "Jan": 0, "Feb": 1, "Mar": 2, "Apr": 3, "May": 4, "Jun": 5,
        "Jul": 6, "Aug": 7, "Sep": 8, "Oct": 9, "Nov": 10, "Dec": 11
    ]
    
    private func getIndex(for month: String) -> Int {
        return monthMap[month] ?? 0
    }
    
    //MARK: Computed Properties
    private var yAxisValues: [Double] {
        let maxAmount = data.map { $0.amount }.max() ?? 0
        if maxAmount == 0 {
            return [0, 1, 2, 3, 4, 5]
        }
        
        let effectiveMax: Double
        if maxAmount <= 5 {
            effectiveMax = 5
        } else if maxAmount <= 10 {
            effectiveMax = 10
        } else if maxAmount <= 25 {
            effectiveMax = 25
        } else if maxAmount <= 50 {
            effectiveMax = 50
        } else if maxAmount <= 100 {
            effectiveMax = 100
        } else if maxAmount <= 500 {
            effectiveMax = ceil(maxAmount / 50.0) * 50.0
        } else if maxAmount <= 1000 {
            effectiveMax = ceil(maxAmount / 100.0) * 100.0
        } else {
            effectiveMax = ceil(maxAmount / 500.0) * 500.0
        }
        
        let step = effectiveMax / 5
        return (0...5).map { Double($0) * step }
    }
    
    //MARK: body
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header
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
            .padding(.horizontal, 20)
            Spacer()
            
            Divider()
                .overlay(Color.neutral300Border)
                .padding(.bottom, 25)
            
            ZStack(alignment: .leading) {
                // Vertical Line will be drawn in chartOverlay for perfect alignment
                
                // Chart
                Chart {
                    ForEach(data) { item in
                        let index = getIndex(for: item.month)
                        AreaMark(
                            x: .value("Month", index),
                            y: .value("Value", item.amount)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.graphGradient1.opacity(0.25), // near line
                                    Color.graphGradient1.opacity(0.05), // fade
                                    Color.clear                          // bottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        LineMark(
                            x: .value("Month", index),
                            y: .value("Value", item.amount)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.graphGradient1, Color.graphGradient2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineStyle(.init(lineWidth: 1))
                        //
                        // OUTERMOST border (grey)
                        PointMark(
                            x: .value("Month", index),
                            y: .value("Value", item.amount)
                        )
                        .symbolSize(300)
                        .opacity(selected?.id == item.id ? 1 : 0)
                        .foregroundStyle(Color.graphBorder)
                        
                        PointMark(
                            x: .value("Month", index),
                            y: .value("Value", item.amount)
                        )
                        .symbolSize(200) // outer size
                        .opacity(selected?.id == item.id ? 1 : 0)
                        .foregroundStyle(Color.white)
                        // INNER purple dot
                        PointMark(
                            x: .value("Month", index),
                            y: .value("Value", item.amount)
                        )
                        .symbolSize(80) // inner size
                        .opacity(selected?.id == item.id ? 1 : 0)
                        .foregroundStyle(Color.graphGradient1)
                    }
                }
                .chartYScale(domain: 0...(yAxisValues.last ?? 5))
                .chartXScale(domain: -0.3...11.3)
                .chartYAxis {
                    AxisMarks(position: .leading, values: yAxisValues) { value in
                        
                        //                        if let y = value.as(Double.self), y == 0 {
                        //                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                        //                                        .foregroundStyle(Color.neutral300Border)
                        //                                }
                        
                        if let y = value.as(Double.self) {
                            if y == 0 {
                                // 1. Solid horizontal baseline for 0
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                                    .foregroundStyle(Color.dashClr)
                            } else {
                                // 2. Dashed horizontal lines for all other values (1, 2, 3, 4, 5 etc.)
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                                    .foregroundStyle(Color.neutralDisabled200)
                            }
                        }
                        AxisValueLabel(anchor: .trailing) { // Anchor trailing to place labels left of the line
                            if let y = value.as(Double.self) {
                                Text("\(Int(y))")
                                    .font(.appRegular(11))
                                    .foregroundStyle(Color.neutralMain700)
                                    .padding(.trailing, 5)
                                    .fixedSize()
                            }
                        }
                    }
                }
                //                .chartXAxis {
                //                    // Native Vertical Axis Line at index 0
                //                    //                    AxisMarks(values: [0]) { _ in
                //                    //                        AxisGridLine()
                //                    //                            .foregroundStyle(Color.neutral300Border)
                //                    //                    }
                //                    //
                //                    //                    // Month Labels
                //                    //                                        AxisMarks(values: [0, 3, 5, 7, 9, 11]) { mode in
                //                    //                                            AxisValueLabel {
                //                    //                                                if let index = mode.as(Int.self) {
                //                    //                                                    let monthsNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                //                    //                                                    if index >= 0 && index < monthsNames.count {
                //                    //                                                        Text(monthsNames[index])
                //                    //                                                            .font(.appRegular(16))
                //                    //                                                            .foregroundColor(Color.neutralMain700)
                //                    //                                                    }
                //                    //                                                }
                //                    //                                            }
                //                    //                                        }
                //                }
                .chartXAxis {
                    // 1. Vertical straight line at the start (Jan)
                    AxisMarks(values: [0]) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                            .foregroundStyle(Color.dashClr)
                    }
                    
                    // 2. Month Labels perfectly aligned with the graph points
                    AxisMarks(values: [0, 2, 4, 6, 8, 10]) { value in
                        AxisValueLabel(anchor: .top) {
                            if let index = value.as(Int.self) {
                                let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                                Text(LocalizedStringKey(months[index]))
                                    .font(.appRegular(11))
                                    .foregroundColor(Color.neutralMain700)
                                    .fixedSize()
                            }
                        }
                    }
                }
                .frame(height: 220)
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let x = value.location.x
                                            if let index: Double = proxy.value(atX: x) {
                                                let roundedIndex = Int(round(index))
                                                if roundedIndex >= 0 && roundedIndex < 12 {
                                                    // Find if we have data for this index
                                                    selected = data.first { getIndex(for: $0.month) == roundedIndex }
                                                }
                                            }
                                        }
                                )
                            
                            // Native line handled by AxisMarks now
                            
                            if let selected,
                               let xPos = proxy.position(forX: getIndex(for: selected.month)),
                               let yPos = proxy.position(forY: selected.amount) {
                                
                                //                                VStack {
                                //                                    Text("\(selected.month) : \(currencySymbol)\(Int(selected.amount))")
                                //                                        .font(.appMedium(10))
                                //                                        .padding(6)
                                //                                        .background(Color.white)
                                //                                        .cornerRadius(8)
                                //                                        .shadow(color: Color.dropShadow, radius: 4, x: 0, y: 2)
                                //                                        .overlay(
                                //                                            RoundedRectangle(cornerRadius: 8)
                                //                                                .stroke(.neutral300Border, lineWidth: 1)
                                //                                        )
                                //                                }
                                VStack(spacing: 0) {
                                    Text("\(selected.month) : \(currencySymbol)\(Int(selected.amount))")
                                        .font(.appMedium(10))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .background(Color.white)
                                        .cornerRadius(6)
                                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.neutral300Border, lineWidth: 0.5)
                                        )
                                    
                                    // Pointer
                                    Image(systemName: "arrowtriangle.down.fill")
                                        .resizable()
                                        .frame(width: 8, height: 4)
                                        .foregroundColor(.white)
                                        .offset(y: -2)
                                }
                                .position(
                                    x: xPos + 10,
                                    y: yPos - 30
                                )
                                .zIndex(1)
                            }
                        }
                    }
                }
                .padding(.leading, 45)
                .padding(.trailing, 10)
            }
            
            HStack{
                Spacer()
                HStack(spacing: 4) {
                    Text("View Details")
                        .font(.appRegular(16))
                        .foregroundColor(.blueMain700)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    Constants.FeatureConfig.performS4Action {
                        AppIntentRouter.shared.navigate(to: .subscriptionsListView(selectedSegment: .third))
                    }
                }
                Spacer()
            }
            .padding(.top, 16)
        }
        .padding(.vertical, 20)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.neutral300Border, lineWidth: 1)
        )
        .background(.whiteBlackBG)
        .cornerRadius(12)
        .onAppear{
            let now = Date()
            year    = Calendar.current.component(.year, from: now)
        }
        .onChange(of: selected?.id) { _ in
            clearSelectionTask?.cancel()
            guard selected != nil else { return }
            clearSelectionTask = Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run {
                    selected = nil
                }
            }
        }
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
    }
}
