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
                        
                        //MARK: Top spending subscriptions
                        if topCategoriesList.count != 0{
                            TopSpendingSubscriptionsView(data: topCategoriesList)
                                .padding(.top, 16)
                        }
                        
                        //MARK: Year Overview
                        YearOverviewChartView(data              : homeVM.homeYearGraphResponse?.monthlySpend ?? [],
                                              currencySymbol    : homeVM.homeYearGraphResponse?.userCurrencySymbol ?? "",
                                              onDone            : { year in
                            selectedYear = year
                            homeYearlyGraphApi()
                        })
                        .padding(.top, 16)
                        .padding(.bottom, activeSubsList.count == 0 ? 90 : 15)
                        
                        
                        //MARK: Save cards
//                        GradientBorderView(title: savePercent, subTitle: saveExpiry, buttonImage: "percent-square",nextBtnImage: "arrow_blue", action: clickOnSave, titleColor: Color.blue800,minHeight: 75,titleFont: 18,subTitleFont: 14)
//                            .padding(.bottom, 16)
//                            .padding(.top,15)
//                        
//                        GradientBorderView(title: youSaved, subTitle: youSavedExpiry, buttonImage: "checkmark-badge",nextBtnImage: "arrow_blue", action: clickOnYouSaved, titleColor: Color.blue800,minHeight: 75,titleFont: 18,subTitleFont: 14)
//                            .padding(.bottom, activeSubsList.count == 0 ? 90 : 12)
                        
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
//            commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
        }
        .onChange(of: homeVM.homeResponse){ _ in updateHomeResponse() }
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
        monthlySpend        = "\(homeResponse?.monthlySpendCurrency ?? "")\(homeResponse?.monthlySpend ?? 0.0)"
        activeSubs          = homeResponse?.totalSubscriptions ?? 0
        activeSubsList      = homeResponse?.expiringSoon ?? []
        subscriptionsList   = homeResponse?.subscriptionList ?? []
        topCategoriesList   = homeResponse?.topCategories ?? []
        isHome              = (homeVM.homeResponse?.topCategories?.count == 0 || homeVM.homeResponse?.topCategories == nil) ? false : true
    }
    
    func homeYearlyGraphApi(){
        homeVM.homeYearlyGraph(input: HomeYearlyGraphRequest(userId: Constants.getUserId(), year: selectedYear))
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
    var title                           : String
    var subTitle                        : String = "Here's your subscription overview"
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
                    var filterCount = count >= 10 ? "9+" : "\(count)"
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
//            if commonApiVM.unreadCountResponse == nil{
//                commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
//            }
//            commonApiVM.unreadNotificationCount(input: UnreadNotificationCountRequest(userId: Constants.getUserId()))
        }
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
                        title       : item.categoryName ?? "",
                        amount      : item.totalAmount ?? 0.0,
                        percentage  : item.percentage ?? 0.0,
                        color       : item.color ?? ""
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
    
    let title       : String
    let amount      : Double
    let percentage  : Double
    let color       : String
    var progress    : CGFloat {
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
            Text(String(format: "$%.2f", amount))
                .font(.appBold(14))
                .foregroundColor(.neutralMain700)
                .frame(alignment: .trailing)
            //                .frame(width: 60, alignment: .trailing)
        }
    }
}

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
    let visibleMonths                       : [String] = ["Jan", "Apr", "Jun", "Aug", "Oct", "Dec"]
    let fakeMonths                          = ["Jan", "Apr", "Jun", "Aug", "Oct", "Dec"]
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
                //                .chartXScale(domain: -0.5...11.5)  //Widened domain to ensure Dec label is visible
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
                                    .font(.appRegular(16))
                                    .foregroundStyle(Color.neutralMain700)
                                    .padding(.trailing, 5)
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
                    
                    //                    // 2. Month Labels perfectly aligned with the graph points
                    //                    AxisMarks(values: [0, 3, 5, 7, 9, 11]) { value in
                    //                        AxisValueLabel {
                    //                            if let index = value.as(Int.self) {
                    //                                let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                    //                                Text(months[index])
                    //                                    .font(.appRegular(16))
                    //                                    .foregroundColor(Color.neutralMain700)
                    //                            }
                    //                        }
                    //                    }
                    
                    
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
                .padding(.leading, 35)
                .padding(.trailing, 35)
            }
            
            HStack(spacing: 0) {
                ForEach(fakeMonths, id: \.self) { month in
                    Text(month)
                        .font(.appRegular(16))
                        .foregroundColor(Color.neutralMain700)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 15)
            .padding(.leading, 50)
            .padding(.trailing, 20)
            
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
