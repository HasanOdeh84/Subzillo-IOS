//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI
import SDWebImageSwiftUI

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
                            
                            //MARK: Save cards
                            GradientBorderView(title: savePercent, subTitle: saveExpiry, buttonImage: "percent-square",nextBtnImage: "arrow_blue", action: clickOnSave, titleColor: Color.blue800,minHeight: 75,titleFont: 18,subTitleFont: 14)
                                .padding(.bottom, 16)
                                .padding(.top,15)
                            
                            GradientBorderView(title: youSaved, subTitle: youSavedExpiry, buttonImage: "checkmark-badge",nextBtnImage: "arrow_blue", action: clickOnYouSaved, titleColor: Color.blue800,minHeight: 75,titleFont: 18,subTitleFont: 14)
                            
                            //MARK: Add / view subscriptions
                            HStack(spacing:16){
                                Button(action: {
                                    goToAddSubscriptions()
                                }) {
                                    VStack(spacing:10){
                                        Image("plus-sign-circle")
                                        Text("Add new subscription")
                                            .font(.appRegular(14))
                                            .foregroundStyle(Color.blueMain700)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 100)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.neutral300Border, lineWidth: 1)
                                )
                                .background(.whiteBlackBG)
                                .cornerRadius(8)
                                
                                Button(action: {
                                    goToSubscriptions()
                                }) {
                                    VStack(spacing:10){
                                        Image("subs")
                                        Text("View all subscriptions")
                                            .font(.appRegular(14))
                                            .foregroundStyle(Color.amethystmain700)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 100)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.neutral300Border, lineWidth: 1)
                                )
                                .background(.whiteBlackBG)
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .padding(.vertical,16)
                            
                            //MARK: Subscriptions list
                            if subscriptionsList.count != 0{
                                HStack(spacing: 8) {
                                    Text("Your subscriptions")
                                        .font(.appRegular(16))
                                        .foregroundColor(.neutralMain700)
                                    Spacer()
                                    Button(action: goToSubscriptions) {
                                        HStack{
                                            Text("View all")
                                                .font(.appRegular(14))
                                                .foregroundColor(.navyBlueCTA700)
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
                            
                            //MARK: View analytics progress
                            VStack(spacing: 14) {
                                ForEach(topCategoriesList) { category in
                                    SubscriptionAnalyticsCard(topCategory: category,
                                                              action: {
                                        //                            goToSubscriptions()
                                        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
                                    })
                                }
                            }
                            .padding(.top,24)
                            .padding(.bottom,90)
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
        }
        .onChange(of: homeVM.homeResponse){ _ in updateHomeResponse() }
    }
    
    //MARK: - User defined methods
    //MARK: goToNotifications
    private func goToNotifications() {
        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
    }
    
    private func clickOnSave() {
        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
    }
    
    private func clickOnYouSaved() {
        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
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
        HStack(spacing: 16) {
            VStack(alignment: .leading,spacing: 2) {
                // MARK: - Title
                Text(title)
                    .font(.appRegular(CGFloat(titleFont)))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.leading)
                
                // MARK: - SubTitle
                Text(subTitle)
                    .font(.appRegular(18))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.neutral500)
            }
            Spacer()
            
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
                
            }
            .offset(x: 0, y: -5)
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
                WebImage(url: URL(string: serviceLogo ?? ""))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(cornerRadius)
        .clipped()
    }
}
