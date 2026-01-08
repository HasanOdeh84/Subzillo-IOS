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
                ProgressView()
            }else if isHome == true{
                VStack(spacing: 16){
                    // MARK: - Header
                    HeaderView(title: "Hi \(fullName)") {
                        goToNotifications()
                    }
                    .padding(.top, 50)
                    .padding(.bottom, -8)
                    .frame(alignment: .leading)
                    
                    //MARK: Scroll view
                    ScrollView(showsIndicators: false){
                        VStack(alignment: .leading,spacing: 18){
                            HStack(spacing: 16){
                                Image("info")
                                Text("Your subscriptions at a glance")
                                    .font(.appRegular(16))
                                    .foregroundColor(Color.neutralMain700)
                            }
                            
                            DashedHorizontalDivider(dash: [2,2])
                            
                            HStack(){
                                Spacer()
                                VStack(spacing: 8){
                                    Text(monthlySpend)
                                        .font(.appSemiBold(28))
                                        .foregroundStyle(Color.blue800)
                                    Text("Monthly spend")
                                        .font(.appRegular(14))
                                        .foregroundStyle(Color.neutral500)
                                }
                                Spacer()
                                Divider()
                                    .frame(width: 1)
                                    .overlay(.neutralDisabled200)
                                Spacer()
                                VStack(spacing: 8){
                                    Text("\(activeSubs)")
                                        .font(.appSemiBold(28))
                                        .foregroundStyle(Color.blue800)
                                    Text("Active Subscriptions")
                                        .font(.appRegular(14))
                                        .foregroundStyle(Color.neutral500)
                                }
                                Spacer()
                            }
                            .frame(alignment: .center)
                            
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.neutral300Border, lineWidth: 1)
                        )
                        .background(.whiteBlackBG)
                        .cornerRadius(12)
                        
                        /*
                        //MARK: Top spending subscriptions
                        TopSpendingSubscriptionsView(data: topCategoriesList)
                            .padding(.top, 16)
                        
                        //MARK: Year Overview
                        YearOverviewChartView(data              : homeVM.homeYearGraphResponse?.monthlySpend ?? [],
                                              currencySymbol    : homeVM.homeYearGraphResponse?.userCurrencySymbol ?? "",
                                              onDone            : { year in
                            selectedYear = year
                            homeYearlyGraphApi()
                        })
                            .padding(.top, 16)
                         */
                        
                        TopSpendingSubscriptionsView()
                            .padding(.top, 16)
                        
                        YearOverviewChartView()
                            .padding(.top, 16)

                        
                        //MARK: Save cards
                        GradientBorderView(title: savePercent, subTitle: saveExpiry, buttonImage: "percent-square",nextBtnImage: "arrow_blue", action: clickOnSave, titleColor: Color.blue800,minHeight: 75,titleFont: 18,subTitleFont: 14)
                            .padding(.bottom, 16)
                            .padding(.top,15)
                        
                        GradientBorderView(title: youSaved, subTitle: youSavedExpiry, buttonImage: "checkmark-badge",nextBtnImage: "arrow_blue", action: clickOnYouSaved, titleColor: Color.blue800,minHeight: 75,titleFont: 18,subTitleFont: 14)
                            .padding(.bottom, activeSubsList.count == 0 ? 90 : 12)
                        
                        //                            //MARK: Add / view subscriptions
                        //                            HStack(spacing:16){
                        //                                Button(action: {
                        //                                    goToAddSubscriptions()
                        //                                }) {
                        //                                    VStack(spacing:10){
                        //                                        Image("plus-sign-circle")
                        //                                        Text("Add new subscription")
                        //                                            .font(.appRegular(14))
                        //                                            .foregroundStyle(Color.blueMain700White)
                        //                                    }
                        //                                    .frame(maxWidth: .infinity)
                        //                                    .frame(height: 100)
                        //                                }
                        //                                .padding(.vertical, 8)
                        //                                .padding(.horizontal, 8)
                        //                                .overlay(
                        //                                    RoundedRectangle(cornerRadius: 8)
                        //                                        .stroke(.neutral300Border, lineWidth: 1)
                        //                                )
                        //                                .background(.whiteBlackBG)
                        //                                .cornerRadius(8)
                        //
                        //                                Button(action: {
                        //                                    goToSubscriptions()
                        //                                }) {
                        //                                    VStack(spacing:10){
                        //                                        Image("subs")
                        //                                        Text("View all subscriptions")
                        //                                            .font(.appRegular(14))
                        //                                            .foregroundStyle(Color.amethystmain700)
                        //                                    }
                        //                                    .frame(maxWidth: .infinity)
                        //                                    .frame(height: 100)
                        //                                }
                        //                                .padding(.vertical, 8)
                        //                                .padding(.horizontal, 8)
                        //                                .overlay(
                        //                                    RoundedRectangle(cornerRadius: 8)
                        //                                        .stroke(.neutral300Border, lineWidth: 1)
                        //                                )
                        //                                .background(.whiteBlackBG)
                        //                                .cornerRadius(8)
                        //                            }
                        //                            .frame(maxWidth: .infinity)
                        //                            .frame(height: 100)
                        //                            .padding(.vertical,16)
                        
                        //MARK: Subscriptions list
                        /*if subscriptionsList.count != 0{
                         HStack(spacing: 8) {
                         Text("Your subscriptions")
                         .font(.appRegular(16))
                         .foregroundColor(.neutralMain700)
                         Spacer()
                         Button(action: goToSubscriptions) {
                         HStack{
                         Text("View all")
                         .font(.appRegular(14))
                         .foregroundColor(.navyBlueCTA700White)
                         Image("arrow_blue")
                         .frame(width: 24,height: 24, alignment: .trailing)
                         }
                         }
                         //                        .frame(width: 40, alignment: .trailing)
                         }
                         }
                         
                         //MARK: - Your subscriptions list
                         VStack(spacing: 14) {
                         ForEach(subscriptionsList) { sub in
                         subscriptionListCard(subscriptionData: sub)
                         }
                         }
                         */
                        
                        if activeSubsList.count != 0{
                            VStack(alignment: .leading, spacing: 16){
                                Text("Next renewal")
                                    .font(.appRegular(16))
                                    .foregroundColor(Color.graphText)
                                
                                //MARK: - Active subscriptions list
                                if showAll{
                                    ScrollView {
                                        VStack(spacing: 14) {
                                            ForEach(currentSubscriptions) { sub in
                                                subscriptionListCard(subscriptionData: sub,isActive:true)
                                            }
                                        }
                                    }
                                    .frame(height: calculatedHeight)
                                    .animation(.easeInOut, value: showAll)
                                }else{
                                    if let first = activeSubsList.first {
                                        subscriptionListCard(subscriptionData: first,isActive:true)
                                    }
                                }
                                
                                //MARK: Show More / Less button
                                if activeSubsList.count > 1 {
                                    Button {
                                        withAnimation(.easeInOut) {
                                            showAll.toggle()
                                        }
                                    } label: {
                                        Spacer()
                                        Text(showAll ? "Show Less" : "Show More")
                                            .font(.appRegular(16))
                                            .foregroundColor(.blueMain700)
                                        Image("dropDown_blue")
                                            .frame(width: 24,height: 24, alignment: .trailing)
                                            .rotationEffect(.degrees(showAll ? 0 : 180))
                                            .animation(.easeInOut, value: showAll)
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.neutral300Border, lineWidth: 1)
                            )
                            .background(.whiteBlackBG)
                            .cornerRadius(12)
                            .padding(.bottom,90)
                        }
                        
                        //MARK: View analytics progress
                        //                        VStack(spacing: 14) {
                        //                            ForEach(topCategoriesList) { category in
                        //                                SubscriptionAnalyticsCard(topCategory: category,
                        //                                                          action: {
                        //                                    //                            goToSubscriptions()
                        //                                    ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        //                                })
                        //                            }
                        //                        }
                        //                        .padding(.top,24)
                        //                        .padding(.bottom,90)
                        Spacer()
                    }
                }
                .background(Color.neutralBg100)
                .padding(20)
            }
            else{
                WelcomeHomeView()
            }
        }
        .onAppear{
            if let fullName = SessionManager.shared.loginData?.fullName{
                self.fullName = fullName
            }
            homeVM.home(input: HomeRequest(userId: Constants.getUserId()))
            homeYearlyGraphApi()
        }
        .onChange(of: homeVM.homeResponse){ _ in updateHomeResponse() }
    }
    
    //MARK: - User defined methods
    //MARK: goToNotifications
    private func goToNotifications() {
        ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
    }
    
    private func clickOnSave() {
        ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
    }
    
    private func clickOnYouSaved() {
        ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
    }
    
    private func goToSubscriptions() {
        tabSelected = .subscriptions
    }
    
    private func goToAddSubscriptions() {
        tabSelected = .addSubscription
    }
    
    private func updateHomeResponse() {
        homeResponse        = homeVM.homeResponse
        monthlySpend        = "\(homeResponse?.monthlySpendCurrency ?? "")\(homeResponse?.monthlySpend ?? 0.0)"
        activeSubs          = homeResponse?.totalSubscriptions ?? 0
        activeSubsList      = homeResponse?.expiringSoon ?? []
        subscriptionsList   = homeResponse?.subscriptionList ?? []
        topCategoriesList   = homeResponse?.topCategories ?? []
        isHome              = homeVM.homeResponse?.totalSubscriptions == 0 ? false : true
    }
    
    func homeYearlyGraphApi(){
//        homeVM.homeYearlyGraph(input: HomeYearlyGraphRequest(userId: Constants.getUserId(), year: selectedYear))
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
                            Text("View analytics ")
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
    var title           : String
    var subTitle        : String = "Here's your subscription overview"
    var titleFont       = 28
    let action          : () -> Void
    
    var body: some View {
        //MARK: notification btn
        ZStack(alignment: .topTrailing) {
            Button(action: action) {
                Image("notification-03")
                    .frame(width: 32, height: 32)
            }
            
            //                Text("3")
            //                    .font(.appBold(11))
            //                    .foregroundColor(Color.white)
            //                    .frame(width: 16, height: 16)
            //                    .background(Color.redBadge)
            //                    .cornerRadius(4)
            //                    .offset(x: 0, y: -5)
            
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
    }
}

//MARK: - AvatarView
struct AvatarView: View {
    var serviceName     : String
    var serviceLogo     : String?
    var size            : CGFloat = 34
    var cornerRadius    : CGFloat = 8
    var fontSize        : CGFloat = 20
    var fromPreview     : Bool = false
    
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
                    Color.whiteBlackBG
                    Text(initials)
                        .font(.appBold(fontSize))
                        .foregroundColor(.secondaryNavyBlue400)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.neutral300Border, lineWidth: 1)
                )
                .cornerRadius(cornerRadius)
            } else {
                if fromPreview{
                    if let url = serviceLogoURL {
                        WebImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5))
                            .scaledToFit()
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(.neutral300Border, lineWidth: 1)
                            )
                            .cornerRadius(cornerRadius)
                    }
                }else{
                    WebImage(url: URL(string: serviceLogo ?? ""))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(.neutral300Border, lineWidth: 1)
                        )
                        .cornerRadius(cornerRadius)
                }
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(cornerRadius)
        .clipped()
    }
}

////MARK: - TopSpendingSubscriptionsView
//struct TopSpendingSubscriptionsView: View {
//    
//    let data : [TopCategoriesData]
//    var maxAmount: Double {
//        data.map { $0.totalAmount ?? 0.0 }.max() ?? 1
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Top spending subscriptions")
//                .font(.appRegular(16))
//                .foregroundColor(Color.neutralMain700)
//                .padding(.bottom, 15)
//                .padding(.horizontal, 15)
//            Divider()
//                .overlay(Color.neutral300Border)
//            VStack(spacing: 16) {
//                ForEach(data) { item in
//                    SpendingRowView(
//                        title       : item.categoryName ?? "",
//                        amount      : item.totalAmount ?? 0.0,
//                        maxAmount   : maxAmount,
//                        percentage  : item.percentage ?? 0.0,
//                        color       : item.color ?? ""
//                    )
//                }
//            }
//            .padding(15)
//            
//            HStack{
//                Spacer()
//                Text("View More")
//                    .font(.appRegular(16))
//                    .foregroundColor(.blueMain700)
//                Spacer()
//            }
//        }
//        .padding(.vertical, 16)
//        .background(.whiteBlackBG)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(.neutral300Border, lineWidth: 1)
//        )
//        .cornerRadius(12)
//        //        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
//    }
//}
//
////MARK: - SpendingRowView
//struct SpendingRowView: View {
//    
//    let title       : String
//    let amount      : Double
//    let maxAmount   : Double
//    let percentage  : Double
//    let color       : String
//    var progress    : CGFloat {
//        CGFloat(percentage / 100)
//    }
//    
//    var body: some View {
//        HStack(spacing: 5) {
//            Text(title)
//                .font(.appRegular(14))
//                .foregroundColor(.neutralMain700)
//                .frame(width: 90, alignment: .leading)
//                .padding(.trailing, 24)
//            GeometryReader { geo in
//                ZStack(alignment: .leading) {
//                    Capsule()
//                        .fill(Color.clear)
//                    Capsule()
//                        .fill(Color.safeHex(color))
//                        .frame(width: geo.size.width * progress)
//                }
//            }
//            .frame(height: 10)
//            .padding(.trailing, 7)
//            Text(String(format: "$%.2f", amount))
//                .font(.appBold(14))
//                .foregroundColor(.neutralMain700)
//                .frame(width: 50, alignment: .trailing)
//        }
//    }
//}
//
////MARK: - YearOverviewChartView
//struct YearOverviewChartView: View {
//    
//    @State private var selected             : MonthlySpendData?
//    @State private var clearSelectionTask   : Task<Void, Never>?
//    let visibleMonths                       : [String] = ["Jan", "Apr", "Jun", "Aug", "Oct", "Dec"]
//    let fakeMonths                          = ["Jan", "Apr", "Jun", "Aug", "Oct", "Dec"]
//    let data                                : [MonthlySpendData]
//    var currencySymbol                      : String
//    @State var openYearSheet                = false
//    @State var year                         : Int = 2025
//    let onDone                              : (Int) -> Void
//    
//    //MARK: - Computed Properties
//    private var yAxisValues: [Double] {
//        let maxAmount = data.map { $0.amount }.max() ?? 0
//        let effectiveMax = maxAmount == 0 ? 5 : maxAmount
//        let step = effectiveMax / 5
//        return (0...5).map { Double($0) * step }
//    }
//    
//    //MARK: - body
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

//MARK: - SpendingRowView
struct SpendingRowView: View {
    let title: String
    let amount: Double
    let maxAmount: Double
    let color: Color
    var progress: CGFloat {
        CGFloat(amount / maxAmount)
    }
    var body: some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.appRegular(14))
                .foregroundColor(.black)
                .frame(width: 90, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)
                    Capsule()
                        .fill(color)
                        .frame(
                            width: geo.size.width * progress,
                            height: 10
                        )
                }
            }
            .frame(height: 10)
            Text(String(format: "$%.2f", amount))
                .font(.appRegular(14))
                .foregroundColor(.black)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

struct MonthlySpend: Identifiable {
    let id = UUID()
    let index: Int
    let month: String
    let value: Double
}

struct SubscriptionSpending: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let color: Color
}

//MARK: - TopSpendingSubscriptionsView
struct TopSpendingSubscriptionsView: View {
    let data: [SubscriptionSpending] = [
        .init(title: "Entertainment", amount: 299.99, color: .purple),
        .init(title: "Sports", amount: 99.99, color: .red),
        .init(title: "Education", amount: 99.99, color: .blue)
    ]
    var maxAmount: Double {
        data.map { $0.amount }.max() ?? 1
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Top spending subscriptions")
                .font(.appRegular(16))
                .foregroundColor(Color.graphText)
            Divider()
            VStack(spacing: 16) {
                ForEach(data) { item in
                    SpendingRowView(
                        title: item.title,
                        amount: item.amount,
                        maxAmount: maxAmount,
                        color: item.color
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        //        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

//MARK: - YearOverviewChartView
struct YearOverviewChartView: View {
    
    @State private var selected             : MonthlySpend?
    @State private var clearSelectionTask   : Task<Void, Never>?
    let visibleMonths           : [String] = ["Jan", "Apr", "Jun", "Aug", "Oct", "Dec"]
    let fakeMonths              = ["Jan", "Apr", "Jun", "Aug", "Oct", "Dec"]
    let data: [MonthlySpend]    = [
        .init(index: 0,  month: "Jan", value: 1.8),
        .init(index: 1,  month: "Feb", value: 2.2),
        .init(index: 2,  month: "Mar", value: 2.6),
        .init(index: 3,  month: "Apr", value: 2.5),
        .init(index: 4,  month: "May", value: 2.3),
        .init(index: 5,  month: "Jun", value: 2.2),
        .init(index: 6,  month: "Jul", value: 2.4),
        .init(index: 7,  month: "Aug", value: 2.8),
        .init(index: 8,  month: "Sep", value: 3.1),
        .init(index: 9,  month: "Oct", value: 3.5),
        .init(index: 10, month: "Nov", value: 3.7),
        .init(index: 11, month: "Dec", value: 3.8)
    ]
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header
            HStack {
                Text("Year Overview")
                    .font(.appRegular(16))
                    .foregroundColor(Color.graphText)
                Spacer()
                HStack(spacing: 4) {
                    Text("2025")
                        .font(.appRegular(14))
                    //                    Image(systemName: "chevron.down")
                    //                        .font(.system(size: 12))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.neutral300Border)
                )
            }
            Spacer()
            Spacer()
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.neutral300Border)
                    .frame(width: 1)
                    .padding(.top, 0)
                    .padding(.bottom, 0)
                    .padding(.leading, -10)
                    .offset(x: 32)
                
                // ✅ Manual horizontal dotted lines (start at leading + 5)
                //            GeometryReader { geo in
                //                let lineCount = 4          // 1,2,3,4 (no 0)
                //                let totalSteps = lineCount + 1
                //                let spacing = geo.size.height / CGFloat(totalSteps)
                //
                //                VStack(spacing: 0) {
                //
                //                    // ❌ Skip 0 level
                //                    Spacer()
                //                        .frame(height: spacing)
                //
                //                    // ✅ Draw lines for 1...lineCount
                //                    ForEach(1...lineCount, id: \.self) { _ in
                //                        Rectangle()
                //                            .fill(Color.clear)
                //                            .frame(height: 1)
                //                            .overlay(
                //                                DashedHorizontalDivider(dash: [2,2])
                //                            )
                //                            .padding(.leading, 22)
                //                            .padding(.trailing, 20)
                //
                //                        Spacer()
                //                            .frame(height: spacing)
                //                    }
                //                }
                //            }
                // Chart
                Chart {
                    ForEach(data) { item in
                        
                        AreaMark(
                            x: .value("Month", item.month),
                            y: .value("Value", item.value)
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
                            x: .value("Month", item.month),
                            y: .value("Value", item.value)
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
                        
                        // OUTERMOST border (grey)
                        PointMark(
                            x: .value("Month", item.month),
                            y: .value("Value", item.value)
                        )
                        .symbolSize(300)
                        .opacity(selected?.id == item.id ? 1 : 0)
                        .foregroundStyle(Color.graphBorder)
                        
                        PointMark(
                            x: .value("Month", item.month),
                            y: .value("Value", item.value)
                        )
                        .symbolSize(200) // outer size
                        .opacity(selected?.id == item.id ? 1 : 0)
                        .foregroundStyle(Color.white)
                        // INNER purple dot
                        PointMark(
                            x: .value("Month", item.month),
                            y: .value("Value", item.value)
                        )
                        .symbolSize(80) // inner size
                        .opacity(selected?.id == item.id ? 1 : 0)
                        .foregroundStyle(Color.graphGradient1)
                    }
                    
                    //                if let selected {
                    //                    RuleMark(x: .value("Selected", selected.month))
                    //                        .foregroundStyle(.gray.opacity(0.3))
                    //                        .annotation(position: .top) {
                    //                            Text("\(selected.month) : $\(Int(selected.value * 20))")
                    //                                .font(.appRegular(14))
                    //                                .padding(8)
                    //                                .background(Color.white)
                    //                                .cornerRadius(8)
                    //                                .shadow(radius: 3)
                    //                        }
                    //                }
                }
                //            .chartYAxis {
                //                AxisMarks(
                //                    position: .leading,
                //                    values: .automatic(desiredCount: 6)
                //                ) { value in
                //
                //                    if let yValue = value.as(Double.self), yValue != 0 {
                //                        // ✅ Draw dashed grid lines for non-zero values
                //                        AxisGridLine(stroke: StrokeStyle(dash: [4]))
                //                            .foregroundStyle(.neutralDisabled200White)
                //                            .padding(.leading,5)
                //                    }
                //
                //                    // ✅ Still show labels (including 0)
                //                    AxisValueLabel()
                //                }
                //            }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 6)) { value in
                        AxisValueLabel {
                            if let y = value.as(Double.self) {
                                Text("\(Int(y))")
                                    .font(.appRegular(16))
                                    .foregroundColor(Color.graphText)
                            }
                        }
                    }
                }
                //            .chartPlotStyle { plot in
                //              plot.padding(.leading, 5)
                //            }
                
                .chartXAxis {
                    // Added Fake X - Axis
                    //                AxisMarks(values: visibleMonths) { value in
                    //                    AxisValueLabel {
                    //                        if let month = value.as(String.self) {
                    //                            Text(month)
                    //                                .font(.appRegular(14))
                    //                                .foregroundColor(.neutralMain700)
                    //                        }
                    //                    }
                    //                }
                    //              AxisValueLabel().hidden()
                    //              AxisTick().hidden()
                    //              AxisGridLine().hidden()
                }
                .frame(height: 220)
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            
                            ForEach(1...4, id: \.self) { value in
                                if let yPos = proxy.position(forY: Double(value)) {
                                    DashedHorizontalDivider(dash: [2,2])
                                        .frame(height: 1)
                                        .position(
                                            x: geo.size.width / 2,
                                            y: yPos
                                        )
                                        .padding(.leading, 12)
                                        .padding(.trailing, 10)
                                }
                            }
                            
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let x = value.location.x
                                            if let month: String = proxy.value(atX: x) {
                                                selected = data.first { $0.month == month }
                                            }
                                        }
                                )
                            
                            if let selected,
                               let xPos = proxy.position(forX: selected.month),
                               let yPos = proxy.position(forY: selected.value) {
                                
                                VStack {
                                    Text("\(selected.month) : $\(Int(selected.value * 20))")
                                        .font(.appRegular(14))
                                        .padding(8)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(radius: 4)
                                }
                                .position(
                                    x: xPos,
                                    y: yPos - 30
                                )
                            }
                        }
                    }
                }
            }
            Divider()
                .background(Color.neutral300Border)
                .padding(.top, -2)
                .padding(.leading, 22)
            HStack(spacing: 0) {
                ForEach(fakeMonths, id: \.self) { month in
                    Text(month)
                        .font(.appRegular(16))
                        .foregroundColor(Color.graphText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 10)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        //        .shadow(color: Color.black.opacity(0.05), radius: 8)
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
    }
}
