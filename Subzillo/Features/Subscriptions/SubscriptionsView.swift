//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI

struct SubscriptionsView: View {
    
    //MARK: - Properties
    @State private var selectedSegment          : Segment? = .first
    @State private var currentDate              = Date()
    @StateObject var subscriptionsVM            = SubscriptionsViewModel()
    @State private var page                     = 0
    @State private var subscriptionsList        = [SubscriptionListData]()
    @State private var isDatePickerPresented    = false
    @State private var showFilterSheet          = false
    @State private var showSortSheet            = false
    @State private var chargeDate               : String = ""
    @State private var tempDate                 = Date()
    @State var year                             : Int = 0
    @State var month                            : Int = 0
    @State private var monthlySubscriptions     = [SubscriptionDay]()
    @State private var monthlySubscriptionsAll  = [SubscriptionListData]()
    @State var selectionMode                    : Bool = false
    @State var showDeletePopup                  : Bool = false
    @State var filterData                       : FilterModel = FilterModel()
    @State private var subscriptions            = [SubscriptionListData]()
    @State private var openCardIndex            : Int?
    @State private var openCalendarId           : String? = nil
    @State private var selectedDate             : Int?
    @State private var filterSelect             : Bool = false
    @State private var pendingFilterSelect      : Bool? = nil
    @State private var viewMode                 : SubscriptionsMode = .list
    @State private var isScrollDisabled         : Bool = false
    @State private var activeCardId             : String? = nil
    var selectedTab                             : Segment? = .first
    @State private var deleteSheetHeight        : CGFloat = .zero
    @StateObject var subscriptionMatchVM        = SubscriptionMatchViewModel()
    @State private var showRenewSheet           : Bool = false
    @State private var selectedSubscription     : SubscriptionListData? = nil
    @State private var renewSheetHeight         : CGFloat = .zero
    @StateObject var commonVM                   = CommonAPIViewModel()
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @State var selectedCategory                 = ""
    @State var categoryResponse                 = [Category.init(id:"",name: "All")]
    @State private var subsCount                = "10"
    @State private var lockedSubsCount          = 0
    @State private var subsAmount               = "$120.95"
    @State private var currentDateNew = Date()
    @State private var highlights: [CalendarHighlight] = [
        CalendarHighlight(day: 21, dots: 1),
        CalendarHighlight(day: 27, dots: 2)
    ]
    @State private var isPlanExists             : Bool = true
    var hasSelection: Bool {
        subscriptionsList.contains(where: { $0.isSelected ?? false })
    }
    
    //    var lockedSubsCount: Int {
    //        if selectedSegment == .first {
    //            return subscriptionsList.filter { $0.viewStatus == false }.count
    //        } else {
    //            return subscriptions.filter { $0.viewStatus == false }.count
    //        }
    //    }
    
    var isFilterActive: Bool {
        return !filterData.includeFamilySubscriptions ||
        !filterData.includeExpiredSubscriptions
    }
    private var currentYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: currentDate)
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    //MARK: - body
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // MARK: - Header
                
                HStack(alignment: .top){
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("MY SUBSCRIPTIONS")
                            .font(.jetBrainsMedium(10))
                            .foregroundColor(
                                Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                            )
                            .tracking(1.5)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            
                            Text(subsCount)
                                .font(.geistSemiBold(28))
                                .foregroundColor(
                                    Color("TextPrimary_ 0E101A_F4F1FB")
                                )
                            
                            Text("· \(subsAmount)/mo")
                                .font(.jetBrainsRegular(12))
                                .foregroundColor(
                                    Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                                )
                        }
                    }
                    
                    Spacer()
                    if isPlanExists == true {
                        if let segment = selectedSegment {
                            
                            if segment == .first{
                                Button {
                                    clickOnFilter()
                                } label: {
                                    
                                    Image("filterIcon")
                                        .renderingMode(colorScheme == .dark ? .template : .original)
                                        .foregroundColor(themeManager.black_white)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(themeManager.white_white4)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    themeManager.black_white.opacity(0.08),
                                                    lineWidth: 1
                                                )
                                        )
                                        .overlay(alignment: .topTrailing) {
                                            if isFilterActive {
                                                Circle()
                                                    .fill(themeManager.accentColor)
                                                    .frame(width: 8, height: 8)
                                                    .shadow(color: themeManager.accentColor, radius: 4, x: 0, y: 0)
                                                    .offset(x: -9, y: 9)
                                            }
                                        }
                                }
                            }
                        }
                    }
                    else{
                        HStack(spacing: 8) {
                            
                            Circle()
                                .fill(Color.dangerE43C5CFF5A7A)
                                .frame(width: 7, height: 7)
                            
                            Text("\(commonVM.userInfoResponse?.planSubscriptionLimit ?? 0)/\(commonVM.userInfoResponse?.planSubscriptionLimit ?? 0) \(commonVM.userInfoResponse?.planName ?? "")")
                                .font(.jetBrainsBold(12))
                                .foregroundColor(Color.dangerE43C5CFF5A7A.opacity(0.8))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.dangerE43C5CFF5A7A.opacity(0.12))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.dangerE43C5CFF5A7A.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.top, 10)
                    }
                }
                .padding(.top, 40)
                
                /*HeaderView(title: "Your subscriptions",titleFont: 24) {
                 Constants.FeatureConfig.performS4Action {
                 goToNotifications()
                 }
                 }
                 .padding(.top, 50)
                 .frame(alignment: .leading)*/
                
                if selectionMode{
                    //MARK: cancel and delete buttons
                    CancelDeleteView(leftImage: "cross_gradient", rightImage: "delete_red", leftText: "Cancel", rightText: "Delete") {
                        cancelSubscription()
                    } deleteAction: {
                        var selectedIDs: [String] {
                            subscriptionsList.filter { $0.isSelected ?? false }.map { $0.id ?? "" }
                        }
                        if selectedIDs.count != 0{
                            showDeletePopup = true
                        }
                    }
                    .padding(.top, 16)
                }else{
                    if isPlanExists == true {
                        HStack(spacing: 10) {
                            
                            // MARK: - Segment
                            
                            SegmentViewNew(
                                selectedSegment: $selectedSegment,
                                leftText: "List",
                                rightText: "Calendar"
                            )
                            .environmentObject(themeManager)
                            
                            Spacer()
                            
                            
                            if let segment = selectedSegment {
                                
                                if segment == .first{
                                    // MARK: - Sort Button
                                    
                                    Button {
                                        //                                        clickOnSort()
                                        if filterData.costOrder == 0{
                                            filterData.costOrder = 1
                                        }else if filterData.costOrder == 1{
                                            filterData.costOrder = 4
                                        }else if filterData.costOrder == 4{
                                            filterData.costOrder = 1
                                        }
                                        page = 0
                                        self.subscriptionsList.removeAll()
                                        listSubsApi()
                                    } label: {
                                        
                                        HStack(spacing: 6) {
                                            
                                            Image("chart")
                                                .renderingMode(colorScheme == .dark ? .template : .original)
                                                .foregroundColor(themeManager.black_white)
                                                .frame(width: 12, height: 12)
                                            
                                            HStack(spacing: 0) {
                                                
                                                Text("Sort: ")
                                                    .font(.geistMedium(11))
                                                
                                                if self.filterData.costOrder == 1 || self.filterData.costOrder == 2
                                                {
                                                    Text("Price")
                                                        .font(.geistSemiBold(11))
                                                        .foregroundStyle(
                                                            themeManager.accentTextColor
                                                        )
                                                }
                                                else{
                                                    Text("Date")
                                                        .font(.geistSemiBold(11))
                                                        .foregroundStyle(
                                                            themeManager.accentTextColor
                                                        )
                                                }
                                            }
                                        }
                                        .foregroundColor(
                                            Color("TextPrimary_ 0E101A_F4F1FB")
                                        )
                                        .padding(.horizontal, 12)
                                        .frame(height: 32)
                                        .background(themeManager.white_white4)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(
                                                    themeManager.black_white.opacity(0.08),
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                    }
                }
                if categoryResponse.count != 0 && isPlanExists == true {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 8) {
                            ForEach(categoryResponse, id: \.self) { category in
                                
                                let isSelected = selectedCategory == (category.id ?? "")
                                
                                Button {
                                    
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedCategory = category.id ?? ""
                                    }
                                    
                                } label: {
                                    
                                    Text(category.name ?? "")
                                        .font(.geistSemiBold(11))
                                        .foregroundColor(
                                            isSelected ?
                                                .white :
                                                Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                                        )
                                        .padding(.horizontal, 14)
                                        .frame(height: 30)
                                        .background(
                                            Group {
                                                if isSelected {
                                                    themeManager.accentGradient
                                                } else {
                                                    themeManager.white_white4
                                                }
                                            }
                                        )
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(
                                                    isSelected ?
                                                    Color.clear :
                                                        themeManager.black_white.opacity(0.08),
                                                    lineWidth: 1
                                                )
                                        )
                                        .shadow(
                                            color: isSelected ?
                                            themeManager.selectedAccent.senColor.opacity(0.35) :
                                                    .clear,
                                            radius: 5,
                                            x: 0,
                                            y: 3
                                        )
                                }
                                .fixedSize()
                            }
                        }
                    }
                }
                if isPlanExists == false {
                    VStack(spacing: 8) {
                        
                        // MARK: - Top Labels
                        HStack {
                            
                            Text("\(commonVM.userInfoResponse?.planName ?? "") plan limit")
                                .font(.geistMedium(12))
                                .foregroundColor(
                                    themeManager.black_white.opacity(0.6)
                                )
                            
                            Spacer()
                            
                            Text("\(commonVM.userInfoResponse?.planSubscriptionLimit ?? 0) / \(commonVM.userInfoResponse?.planSubscriptionLimit ?? 0)")
                                .font(.jetBrainsBold(12))
                                .foregroundColor(
                                    Color.dangerE43C5CFF5A7A
                                )
                        }
                        
                        // MARK: - Progress Bar
                        GeometryReader { geometry in
                            
                            ZStack(alignment: .leading) {
                                
                                Capsule()
                                    .fill(
                                        themeManager.black_white.opacity(0.08)
                                    )
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(
                                        Color.dangerE43C5CFF5A7A
                                    )
                                    .frame(
                                        width: geometry.size.width * 1.0, // progress
                                        height: 6
                                    )
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        themeManager.white_white4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                themeManager.black_white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                    .padding(.top, 20)
                }
                /*// MARK: - year and Month
                 if viewMode != .analytics {
                 if selectedSegment == .second{
                 Button(action: dateSelection) {
                 FieldView(text: $chargeDate, textValue: "", title: "", image: "Calendar1", placeHolder: "mm/yyyy", isButton: false, isText: true, isDate:true)
                 }
                 .sheet(isPresented: $isDatePickerPresented) {
                 CustomCalenderSheet(
                 isPresented         : $isDatePickerPresented,
                 selectedMonth       : $month,
                 selectedYear        : $year,
                 onDone: {
                 let monthString = String(format: "%02d", month)
                 self.chargeDate = "\(monthString)/\(year)"
                 getSubsByMonthApi()
                 }
                 )
                 .presentationDetents([.height(300)])
                 .presentationDragIndicator(.hidden)
                 }
                 }
                 }*/
            }
            .padding(.bottom, 17)
            
            //MARK: Analytics view
            if viewMode == .analytics {
                if Constants.FeatureConfig.isS4Enabled {
                    AnalyticalView()
                }
            } else if let segment = selectedSegment {
                //MARK: Calender view
                if segment == .second{
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            SubscriptionCalendarView(
                                currentDate: $currentDateNew,
                                selectedDate: $selectedDate,
                                highlights: $highlights
                            )
                            .onChange(of: selectedDate) { value in
                                updateMonthSubsListSelected()
                            }
                            .onChange(of: currentDateNew) { newValue in
                                
                                let formatter = DateFormatter()
                                selectedDate = nil
                                highlights = []
                                
                                formatter.dateFormat = "MM/yyyy"
                                year    = Calendar.current.component(.year, from: newValue)
                                month   = Calendar.current.component(.month, from: newValue)
                                
                                let monthString = String(format: "%02d", month)
                                self.chargeDate = "\(monthString)/\(year)"
                                getSubsByMonthApi()
                                
                            }
                            
                        }
                        .padding(.bottom,10)
                        
                        if subscriptionsVM.isLoading && page == 0 {
                            Spacer()
                        } else if monthlySubscriptions.count != 0{
                            LazyVStack  {
                                
                                HStack{
                                    Text("Upcoming renewals · \(subscriptions.count)")
                                        .padding(.bottom, 10)
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(themeManager.textPrimaryLight6_dark62)
                                        .font(.jetBrainsMedium(11))
                                    Spacer()
                                }
                                ForEach(subscriptions, id: \.id) { subscription in
                                    Button {
                                        AppIntentRouter.shared.navigate(
                                            to: .subscriptionMatchView(
                                                fromList: true,
                                                subscriptionId: subscription.id ?? ""
                                            )
                                        )
                                    } label: {
                                        UpcomingSubscriptionRow(subscriptionData:subscription)
                                    }
                                }
                                
                                //                                if lockedSubsCount > 0 {
                                //                                    lockedSubsCard(count: lockedSubsCount)
                                //                                        .padding(.horizontal, 20)
                                //                                        .padding(.top, 10)
                                //                                }
                            }
                            .listStyle(.plain)
                            .scrollIndicators(.hidden)
                            .frame(maxWidth: .infinity)
                            .scrollContentBackground(.hidden)
                            .padding(.bottom,86)
                        }
                        //                        else{
                        //                            Spacer()
                        //                            VStack(){
                        //                                Image("noSubs")
                        //                                    .frame(width: 59, height: 80, alignment: .center)
                        //                                Text("You haven’t added any\nsubscriptions")
                        //                                    .padding(10)
                        //                                    .multilineTextAlignment(.center)
                        //                                    .foregroundStyle(Color.neutral800)
                        //                                    .font(.appBold(16))
                        //                            }
                        //                            Spacer()
                        //                        }
                    }
                    .scrollIndicators(.hidden)
                    
                }  else if segment == .first{
                    //MARK: - Subscriptions list view
                    if subscriptionsVM.isLoading && page == 0 {
                        Spacer()
                    } else if subscriptionsList.count != 0{
                        ScrollViewReader { proxy in
                            List {
                                ForEach(Array(subscriptionsList.enumerated()), id: \.element.id) { index, sub in
                                    SwipeActionCard(
                                        id              : index,
                                        openCardIndex   : $openCardIndex,
                                        isScrollDisabled: $isScrollDisabled,
                                        selectionMode   : selectionMode,
                                        viewStatus      : sub.viewStatus ?? false,
                                        onEdit          : {
                                            editSubscription(sub: sub)
                                        },
                                        onDelete        : {
                                            for i in subscriptionsList.indices {
                                                subscriptionsList[i].isSelected = false
                                            }
                                            subscriptionsList[index].isSelected = true
                                            showDeletePopup = true
                                        }
                                    ) {
                                        subscriptionListCard(
                                            subscriptionData   : sub,
                                            selectionMode      : selectionMode,
                                            onSelect           : {
                                                toggleSelection(at: index)
                                            },
                                            onLongPress        : {
                                                // handleLongPress(at: index)
                                            },
                                            onRenew: {
                                                selectedSubscription = sub
                                                showRenewSheet = true
                                            }
                                        )
                                        .contentShape(Rectangle())
                                    }
                                    .onTapGesture {
                                        guard openCardIndex == nil else { return }
                                        if selectionMode {
                                            toggleSelection(at: index)
                                        } else {
                                            if Constants.FeatureConfig.isS4Enabled {
                                                if sub.viewStatus ?? false {
                                                    AppIntentRouter.shared.navigate(
                                                        to: .subscriptionMatchView(
                                                            fromList: true,
                                                            subscriptionId: sub.id ?? ""
                                                        )
                                                    )
                                                } else {
                                                    //SheetManager.shared.isUpgradeSheetVisible = true
                                                    AppIntentRouter.shared.navigate(to: .exceedLimit)
                                                }
                                            }else{
                                                AppIntentRouter.shared.navigate(
                                                    to: .subscriptionMatchView(
                                                        fromList: true,
                                                        subscriptionId: sub.id ?? ""
                                                    )
                                                )
                                            }
                                            //                                            if sub.viewStatus ?? false {
                                            //                                                AppIntentRouter.shared.navigate(
                                            //                                                    to: .subscriptionMatchView(
                                            //                                                        fromList: true,
                                            //                                                        subscriptionId: sub.id ?? ""
                                            //                                                    )
                                            //                                                )
                                            //                                            } else {
                                            //                                                SheetManager.shared.isUpgradeSheetVisible = true
                                            //                                            }
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 8, trailing: 0))
                                    .listRowBackground(Color.clear)
                                    .onAppear {
                                        if index == subscriptionsList.count - 1 {
                                            loadNextPageIfNeeded()
                                        }
                                    }
                                    .padding(.bottom, (index == subscriptionsList.count - 1 && lockedSubsCount == 0) ? 90 : 0)
                                }
                                .background(Color.clear)
                                .padding(.top, 0)
                                
                                if lockedSubsCount > 0 {
                                    lockedSubsCard(count: lockedSubsCount)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(.init(top: 10, leading: 4, bottom: 90, trailing: 4)) // Reset padding to match standard rows
                                        .listRowBackground(Color.clear)
                                }
                            }
                            .listStyle(.plain)
                            .scrollIndicators(.hidden)
                            .background(Color.clear)
                            .scrollContentBackground(.hidden)
                            .scrollDisabled(isScrollDisabled)
                            .onChange(of: subscriptionsList) { _ in
                                if page == 0, let firstId = subscriptionsList.first?.id {
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            proxy.scrollTo(firstId, anchor: .top)
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                subscriptionsVM.isLoading = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    loadNextPageIfNeeded()
                                }
                            }
                        }
                        /*VStack{
                         ScrollView {
                         VStack(spacing: 0) {
                         ForEach(Array(subscriptionsList.enumerated()), id: \.element.id) { index, sub in
                         SwipeableSubscriptionRow(
                         sub             : sub,
                         activeCardId    : $activeCardId,
                         isScrollDisabled: $isScrollDisabled,
                         onEdit: {
                         editSubscription(sub: sub)
                         },
                         onDelete: {
                         // Clear any previous selections
                         for i in subscriptionsList.indices {
                         subscriptionsList[i].isSelected = false
                         }
                         
                         // Mark ONLY this item
                         subscriptionsList[index].isSelected = true
                         showDeletePopup = true
                         },
                         isFamily        : false
                         )
                         .onTapGesture {
                         guard openCardIndex == nil else { return }
                         if selectionMode {
                         toggleSelection(at: index)
                         } else {
                         AppIntentRouter.shared.navigate(
                         to: .subscriptionMatchView(
                         fromList: true,
                         subscriptionId: sub.id ?? ""
                         )
                         )
                         }
                         }
                         .listRowSeparator(.hidden)
                         .listRowInsets(.init(top: 0, leading: 0, bottom: 8, trailing: 0))
                         .listRowBackground(Color.clear)
                         .onAppear {
                         if index == subscriptionsList.count - 1 {
                         loadNextPageIfNeeded()
                         }
                         }
                         .padding(.bottom, index == subscriptionsList.count - 1 ? 90 : 0)
                         }
                         .background(Color.clear)
                         .padding(.top, 5)
                         }
                         }
                         .scrollDisabled(isScrollDisabled)
                         }*/
                    }else{
                        Spacer()
                        VStack(){
                            Image("noSubs")
                                .frame(width: 59, height: 80, alignment: .center)
                            Text("You haven’t added any\nsubscriptions")
                                .padding(10)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.neutral800)
                                .font(.appBold(16))
                        }
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .padding(20)
        .applyAppBackground()
        .onAppear {
            commonApiVM.getCategories()
            selectedSegment = selectedTab// .first
            page = 0
            self.subscriptionsList.removeAll()
            listSubsApi()
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yyyy"
            year    = Calendar.current.component(.year, from: now)
            month   = Calendar.current.component(.month, from: now)
            self.chargeDate = formatter.string(from: now)
            commonVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
        }
        .onChange(of: commonVM.userInfoResponse) { _ in
            updateUserInfo()
        }
        .onChange(of: commonApiVM.categoriesResponse) { _ in updateCatInfo() }
        .sheet(isPresented: $showDeletePopup , onDismiss: {
            if !selectionMode {
                for i in subscriptionsList.indices {
                    subscriptionsList[i].isSelected = false
                }
            }
        }) {
            InfoAlertSheet(
                onDelegate: {
                    deleteSubscription()
                }, title    : "Are you sure you want to delete the subscriptions?",
                subTitle    : "Data will be permanently deleted",
                imageName   : "del_red_new",
                buttonIcon  : "del_red_newSmall",
                buttonTitle : "Delete",
                imageSize   : 70
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet(
                onDelegate: { filterData in
                    self.filterData = filterData
                    print("Filter Data : \(filterData)")
                    page = 0
                    self.subscriptionsList.removeAll()
                    listSubsApi()
                },
                filterData: self.filterData,
                filterSelect: filterSelect
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(500)])
        }
        .sheet(isPresented: $showSortSheet) {
            FilterSheet(
                onDelegate: { filterData in
                    self.filterData = filterData
                    print("Filter Data : \(filterData)")
                    page = 0
                    self.subscriptionsList.removeAll()
                    listSubsApi()
                },
                filterData: self.filterData,
                filterSelect: filterSelect
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(350)])
        }
        .onChange(of: selectedCategory) { value in
            if selectedSegment == .first{
                page = 0
                self.subscriptionsList.removeAll()
                listSubsApi()
            }else{
                //                page = 0
                //                self.subscriptionsList.removeAll()
                getSubsByMonthApi()
            }
        }
        .onChange(of: pendingFilterSelect) { value in
            guard let value else { return }
            filterSelect = value
            if pendingFilterSelect ?? false == true{
                showFilterSheet = true
            }else{
                showSortSheet = true
            }
            pendingFilterSelect = nil
        }
        .onChange(of: subscriptionsVM.listSubsResponse) { _ in updateSubsList() }
        .onChange(of: subscriptionsVM.getSubsByMonthResponse) { _ in updateMonthSubsList() }
        .onChange(of: subscriptionsVM.isDeletedSubscription) { _ in updateDeleteSubscription() }
        .onChange(of: subscriptionMatchVM.isRenewSuccess) { value in
            if value {
                page = 0
                self.subscriptionsList.removeAll()
                listSubsApi()
            }
        }
        //        .onChange(of: selectedSegment) { _ in callApis() }
        .onChange(of: selectedSegment) { newValue in
            if newValue == .first {
                viewMode = .list
            } else if newValue == .second {
                viewMode = .calendar
            } else {
                Constants.FeatureConfig.performS4Action {
                    viewMode = .analytics
                }
            }
            callApis()
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            isDatePickerPresented = false
            showDeletePopup = false
            showFilterSheet = false
            showSortSheet = false
            showRenewSheet = false
        }
        .sheet(isPresented: $showRenewSheet) {
            RenewSubscriptionBottomSheet(
                onRenew: {
                    if let id = selectedSubscription?.id {
                        let input = RenewalUpdateRequest(userId         : Constants.getUserId(),
                                                         subscriptionId : id,
                                                         type           : 1)
                        subscriptionMatchVM.renewalUpdate(input: input)
                    }
                },
                onRenewWithChanges: {
                    if let sub = selectedSubscription {
                        editSubscription(sub: sub, isRenew: true)
                    }
                },
                onNo: {
                    showRenewSheet = false
                }
            )
            .overlay {
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: InnerHeightPreferenceKey.self,
                            value: geo.size.height
                        )
                }
            }
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 150 {
                    renewSheetHeight = height
                }
            }
            .presentationDetents([.height(renewSheetHeight)])
            .presentationDragIndicator(.hidden)
        }
    }
    
    func generateHighlights(
        from items: [SubscriptionListData]
    ) -> [CalendarHighlight] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        
        var grouped: [Int: Int] = [:]
        
        for item in items {
            
            guard
                let dateString = item.nextPaymentDate,
                let date = formatter.date(from: dateString)
            else {
                continue
            }
            
            let day = calendar.component(.day, from: date)
            
            grouped[day, default: 0] += 1
        }
        
        return grouped.map {
            
            CalendarHighlight(
                day: $0.key,
                dots: $0.value
            )
        }
        .sorted {
            $0.day < $1.day
        }
    }
    func dayFromDate(_ dateString: String?) -> Int {
        
        guard let dateString else {
            return 0
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return 0
        }
        
        return Calendar.current.component(.day, from: date)
    }
    //MARK: - User defined methods
    private func updateUserInfo() {
        //print(commonApiVM.userInfoResponse)
        if commonVM.userInfoResponse?.remainingSubscriptionLimit == 0 {
            isPlanExists = false
        }
    }
    private func updateCatInfo() {
        categoryResponse.removeAll()
        categoryResponse.append(Category.init(id:"",name: "All"))
        if commonApiVM.categoriesResponse != nil {
            categoryResponse.append(contentsOf: commonApiVM.categoriesResponse ?? [])
        }
    }
    func callApis(){
        if selectedSegment == .first{
            page = 0
            self.subscriptionsList.removeAll()
            listSubsApi()
        }else{
            page = 0
            self.subscriptionsList.removeAll()
            getSubsByMonthApi()
        }
    }
    
    func listSubsApi(showLoader:Bool = true){
        if page == 0 {
            self.showOfflineDetails()
        }
        let input = ListSubscriptionsRequest(userId : Constants.getUserId(),
                                             page   : page,
                                             filter : SubscriptionFilter(includeFamilyMembers        : filterData.includeFamilySubscriptions,
                                                                         includeExpiredSubscriptions : filterData.includeExpiredSubscriptions,
                                                                         
                                                                         categoryId                  : selectedCategory,
                                                                         familyMembers               : filterData.familyMemberIds,
                                                                         monthYear                   : filterData.monthYear),
                                             sortBy : filterData.costOrder)
        subscriptionsVM.listSubscriptions(input: input, showLoader: showLoader)
    }
    
    //    func loadNextPageIfNeeded(){
    //        guard !subscriptionsVM.isLoading else { return }
    //        if let totalPages = self.subscriptionsVM.listSubsResponse?.totalPages, (page + 1) < totalPages {
    //            page += 1
    //            listSubsApi(showLoader: false)
    //        }
    //    }
    func loadNextPageIfNeeded() {
        guard !subscriptionsVM.isLoading else { return }
        
        guard let totalPages = subscriptionsVM.listSubsResponse?.totalPages else { return }
        
        guard page + 1 < totalPages else { return }
        
        subscriptionsVM.isLoading = true
        page += 1
        listSubsApi(showLoader: false)
    }
    
    func getSubsByMonthApi(){
        let input = GetSubscriptionsByMonthRequest(userId       : Constants.getUserId(),
                                                   year         : year,
                                                   month        : month,
                                                   categoryId   : selectedCategory)
        subscriptionsVM.getSubscriptionsByMonth(input: input)
    }
    
    func showOfflineDetails()
    {
        self.subscriptionsList = SubscriptionDBManager.shared.getSubscriptions(value: "", type: "list")
        print(self.subscriptionsList.count)
    }
    
    func updateSubsList(){
        guard let listResponse = self.subscriptionsVM.listSubsResponse else { return }
        let listArray = listResponse.subscriptions ?? []
        for item in listArray
        {
            SubscriptionDBManager.shared.updateSubscription(params: item)
        }
        subsCount = "\(listResponse.totalSubscriptions ?? 0)"
        lockedSubsCount = listResponse.totalHiddenSubscriptions ?? 0
        subsAmount = "\(listResponse.currentMonthSpendingCurrencySymbol ?? "")\(listResponse.currentMonthSpendingAmount ?? 0.00)"
        if page == 0 {
            self.subscriptionsList = listArray
        } else {
            self.subscriptionsList.append(contentsOf: listArray)
        }
        print("data from response")
    }
    func updateMonthSubsListSelected(){
        subscriptions.removeAll()
        let filtered = monthlySubscriptionsAll.filter {
            dayFromDate($0.nextPaymentDate) == selectedDate
        }
        //subscriptions = filtered
        
        subscriptions = filtered.sorted {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let date1 = formatter.date(from: $0.nextPaymentDate ?? "") ?? Date.distantPast
            let date2 = formatter.date(from: $1.nextPaymentDate ?? "") ?? Date.distantPast
            
            return date1 < date2
        }
        
    }
    func updateMonthSubsList(){
        subscriptions.removeAll()
        monthlySubscriptionsAll.removeAll()
        monthlySubscriptions = subscriptionsVM.getSubsByMonthResponse?.days ?? []
        for item in monthlySubscriptions
        {
            monthlySubscriptionsAll.append(contentsOf: item.subscriptions ?? [])
        }
        highlights = generateHighlights(
            from: monthlySubscriptionsAll
        )
        //subscriptions = monthlySubscriptionsAll
        subscriptions = monthlySubscriptionsAll.sorted {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let date1 = formatter.date(from: $0.nextPaymentDate ?? "") ?? Date.distantPast
            let date2 = formatter.date(from: $1.nextPaymentDate ?? "") ?? Date.distantPast
            
            return date1 < date2
        }
        /*if let days = subscriptionsVM.getSubsByMonthResponse?.days{
         for day in days{
         var mainRelations       = [RelationsInfo]()
         var plans               = [PlanInfo]()
         if let subscriptions = day.subscriptions{
         var relations           : [String] = []
         for subscription in subscriptions{
         //subscriptionFor Need to change with nickName
         let relation = (subscription.subscriptionFor == "" || subscription.subscriptionFor == Constants.getUserId()) ? "Me".localized : subscription.subscriptionFor
         if !relations.contains(relation ?? "Me") {
         relations.append(relation ?? "Me")
         }
         }
         for relation in relations {
         var nickName    = ""
         var color       = ""
         var relationId  = ""
         for sub in subscriptions {
         //subscriptionFor Need to change with nickName
         //                            let rel     = sub.subscriptionFor == "" ? "Me" : sub.subscriptionFor
         let rel     = (sub.subscriptionFor == "" || sub.subscriptionFor == Constants.getUserId()) ? "Me".localized : sub.subscriptionFor
         relationId  = (sub.subscriptionFor == "" ? Constants.getUserId() : sub.subscriptionFor) ?? ""
         if rel == relation {
         plans.append(PlanInfo(id        : sub.id ?? "",
         name      : sub.serviceName,
         image     : sub.serviceLogo,
         amount    : sub.amount,
         currency  : sub.currencySymbol,
         card      : sub.paymentMethodName))
         nickName = sub.nickName ?? ""
         color = sub.color ?? ""
         }
         }
         mainRelations.append(RelationsInfo(id       : relationId,
         name     : relation == "Me" ? "" : nickName,
         color    : color, plans: plans))
         }
         print("relations \(relations)")
         }
         subscriptions.append(SubscriptionInfoo(id           : (day.id == nil || day.id == "") ? "\(day.date ?? "")_\(index)" : day.id ?? "",
         amount       : day.totalAmount,
         currency     : day.currencySymbol,
         createdAt    : day.date,
         plans        : plans,
         relations    : mainRelations,
         isOpen       : false,
         status       : day.status))
         }
         }*/
    }
    
    func editSubscription(sub: SubscriptionListData, isRenew: Bool = false){
        let subData = SubscriptionData(id               : sub.id ?? "",
                                       serviceName      : sub.serviceName ?? "",
                                       subscriptionType : sub.subscriptionType ?? "",
                                       amount           : sub.amount ?? 0.0,
                                       currency         : sub.currency ?? "",
                                       currencySymbol   : sub.currencySymbol ?? "",
                                       billingCycle     : sub.billingCycle ?? "",
                                       nextPaymentDate  : sub.nextPaymentDate ?? "",
                                       paymentMethodId  : sub.paymentMethod ?? "",
                                       paymentMethod    : sub.paymentMethod ?? "",
                                       paymentMethodName: sub.paymentMethodName ?? "",
                                       categoryId       : sub.category ?? "",
                                       categoryName     : sub.categoryName ?? "",
                                       reason           : sub.notes ?? "",
                                       subscriptionFor      : sub.subscriptionFor ?? "",
                                       paymentMethodDataId  : sub.paymentMethodDataId ?? "",
                                       paymentMethodDataName: sub.paymentMethodDataName ?? "",
                                       renewalReminder      : sub.renewalReminder,
                                       renewalReminders     : sub.renewalReminder,
                                       notes                : sub.notes ?? "")
        globalSubscriptionData = subData
        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit     : true,
                                                         isFromListEdit : true,
                                                         isRenew: isRenew,
                                                         subscriptionId : sub.id ?? ""))
    }
    
    //MARK: - Button actions
    
    func toggleSelection(at index: Int) {
        var obj = subscriptionsList[index]
        if Constants.FeatureConfig.isS4Enabled {
            guard obj.viewStatus != false else { return }
        }
        if (obj.isSelected ?? false ) == true
        {
            obj.isSelected = false
        }
        else{
            obj.isSelected = true
        }
        subscriptionsList[index] = obj
    }
    
    func handleLongPress(at index: Int) {
        var obj = subscriptionsList[index]
        if Constants.FeatureConfig.isS4Enabled {
            guard obj.viewStatus != false else { return }
        }
        selectionMode = true
        obj.isSelected = true
        subscriptionsList[index] = obj
    }
    
    func cancelSubscription() {
        for i in subscriptionsList.indices { subscriptionsList[i].isSelected = false }
        selectionMode = false
    }
    
    func deleteSubscription() {
        var selectedIDs: [String] {
            subscriptionsList.filter { $0.isSelected ?? false }.map { $0.id ?? "" }
        }
        subscriptionsVM.deleteSubscription(input: DeleteSubscriptionRequest(userId: Constants.getUserId(), subscriptionIds: selectedIDs))
    }
    
    func updateDeleteSubscription(){
        if subscriptionsVM.isDeletedSubscription ?? false{
            page = 0
            selectionMode = false
            subscriptionsList.removeAll()
            listSubsApi()
            //            subscriptionsList.removeAll(where: { $0.isSelected ?? false })
            //            selectionMode = false
        }
    }
    
    private func goToNotifications() {
        Constants.FeatureConfig.performS4Action {
            subscriptionsVM.navigate(to: .notifications)
        }
    }
    
    private func clickOnChat() {
        selectedSegment = nil
        viewMode = .analytics
    }
    
    private func clickOnFilter() {
        pendingFilterSelect = true
    }
    
    private func clickOnSort() {
        pendingFilterSelect = false
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
    
    private func dateSelection() {
        withAnimation(.easeInOut) {
            isDatePickerPresented = true
        }
    }
    // MARK: - Locked Subs Card
    private func lockedSubsCard(count: Int) -> some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                themeManager.accentGradient
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Image("sparkles")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            .frame(width: 44, height: 44)
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text("Unlock \(count) more subs")
                    .font(.geistSemiBold(14))
                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                Text("Upgrade to Premium for\nunlimited tracking")
                    .font(.geistRegular(12))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                //                    .lineLimit(2)
            }
            
            Spacer()
            
            // Button
            Button(action: {
                AppIntentRouter.shared.navigate(to: .pricingPlans())
            }) {
                Text("Upgrade")
                    .font(.geistSemiBold(14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(themeManager.accentGradient)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient.brandFromDark0133_brandToDark0133)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(themeManager.selectedAccent.senColor.opacity(0.3), lineWidth: 1)
        )
    }
}

//MARK: - SwipeActionCard
struct SwipeActionCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    let id                          : Int
    @Binding var openCardIndex      : Int?
    @Binding var isScrollDisabled   : Bool
    let selectionMode               : Bool
    let viewStatus                  : Bool
    let onEdit                      : () -> Void
    let onDelete                    : () -> Void
    let content                     : Content
    @State private var isSwiped     : Bool = false
    @State private var offsetX      : CGFloat = 0
    private let maxOffset           : CGFloat = -140
    
    init(
        id              : Int,
        openCardIndex   : Binding<Int?>,
        isScrollDisabled: Binding<Bool>,
        selectionMode   : Bool,
        viewStatus      : Bool,
        onEdit          : @escaping () -> Void,
        onDelete        : @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self._openCardIndex = openCardIndex
        self._isScrollDisabled = isScrollDisabled
        self.selectionMode = selectionMode
        self.viewStatus = viewStatus
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // EDIT and DELETE BUTTONS CONTAINER
            //            HStack(spacing: 0) {
            //                // EDIT
            //                Button {
            //                    onEdit()
            //                    closeCard()
            //                } label: {
            //                    VStack(spacing: 6) {
            //                        Image("edit_white")
            //                            .renderingMode(.template)
            //                            .resizable()
            //                            .scaledToFit()
            //                            .frame(width: 20, height: 20)
            //                        Text("Edit")
            //                            .font(.geistSemiBold(13))
            //                    }
            //                    .foregroundColor(colorScheme == .dark ? Color(hex: "#23C16B") : .white)
            //                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            //                    .background(colorScheme == .dark ? Color(hex: "#23C16B").opacity(0.12) : Color(hex: "#34A853"))
            //                    .clipShape(
            //                        RoundedCorner(radius: 18, corners: [.topLeft, .bottomLeft])
            //                    )
            //                    .overlay(
            //                        RoundedCorner(radius: 18, corners: [.topLeft, .bottomLeft])
            //                            .stroke(colorScheme == .dark ? Color(hex: "#23C16B").opacity(0.3) : Color.clear, lineWidth: 1)
            //                    )
            //                }
            //
            //                // DELETE
            //                Button {
            //                    onDelete()
            //                    closeCard()
            //                } label: {
            //                    VStack(spacing: 6) {
            //                        Image("del_white")
            //                            .renderingMode(.template)
            //                            .resizable()
            //                            .scaledToFit()
            //                            .frame(width: 20, height: 20)
            //                        Text("Delete")
            //                            .font(.geistSemiBold(13))
            //                    }
            //                    .foregroundColor(colorScheme == .dark ? Color.dangerE43C5CFF5A7A : .white)
            //                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            //                    .background(colorScheme == .dark ? Color.dangerE43C5CFF5A7A.opacity(0.12) : Color.dangerE43C5CFF5A7A)
            //                    .clipShape(
            //                        RoundedCorner(radius: 18, corners: [.topRight, .bottomRight])
            //                    )
            //                    .overlay(
            //                        RoundedCorner(radius: 18, corners: [.topRight, .bottomRight])
            //                            .stroke(colorScheme == .dark ? Color.dangerE43C5CFF5A7A.opacity(0.3) : Color.clear, lineWidth: 1)
            //                    )
            //                }
            //            }
            //            .frame(width: 140, height: 74)
            //            .opacity(offsetX < -2 ? 1 : 0) // Hide when completely closed to prevent corner leak
            
            
            
            VStack {
                HStack{
                    Spacer()
                    VStack(spacing: 8){
                        Image("swipeDel")
                        Text("Delete")
                            .font(.jetBrainsBold(11))
                            .foregroundColor(colorScheme == .light ? .textPrimaryDarkF4F1FB : .dangerDarkFF5A7A)
                    }
                    .padding(.leading, 5)
                    .frame(alignment: .trailing)
                    .frame(width: 80, height: 74)
                }
                .frame(width: 190, height: 74)
            }
            .frame(width: 190, height: 74)
            .background(colorScheme == .light ? .dangerLightE43C5C : .dangerLightE43C5C.opacity(0.4))
            .clipShape(
                RoundedCorner(
                    radius: 18,
                    corners: [.topRight, .bottomRight]
                )
            )
            .overlay(
                RoundedCorner(
                    radius: 18,
                    corners: [.topRight, .bottomRight]
                )
                .stroke(colorScheme == .light ? .E_2_E_8_F_0 : .dangerLightE43C5C.opacity(0.40), lineWidth: 1)
//                .stroke(colorScheme == .light ? .E_2_E_8_F_0 : .dangerLightE43C5C, lineWidth: 1)
                .padding(0.5)
            )
            .onTapGesture {
                withAnimation {
                    offsetX = 0
                    isSwiped = false
                }
                onDelete()
            }
            .opacity(offsetX < -2 ? 1 : 0) // Hide when completely closed to prevent corner leak
            
            VStack(spacing: 8) {
                VStack(spacing: 8){
                    Image("swipeEdit")
                    Text("Edit")
                        .font(.jetBrainsBold(11))
                        .foregroundColor(colorScheme == .light ? .textPrimaryDarkF4F1FB : .successDark5CE4A8)
                }
                .padding(.leading, 15)
                .frame(alignment: .trailing)
                .frame(width: 70, height: 74)
            }
            .frame(width: 90, height: 74)
            .background(colorScheme == .light ? .successLight0EA870 : .successLight0EA870.opacity(0.4))
            .clipShape(
                RoundedCorner(
                    radius: 18,
                    corners: [.topRight, .bottomRight]
                )
            )
            .overlay(
                RoundedCorner(
                    radius: 18,
                    corners: [.topRight, .bottomRight]
                )
                .stroke(colorScheme == .light ? .E_2_E_8_F_0 : .successDark5CE4A8.opacity(0.40), lineWidth: 1)
//                .stroke(colorScheme == .light ? .E_2_E_8_F_0 : .successDark5CE4A8, lineWidth: 1)
                .padding(0.5)
            )
            .offset(x: -70)
            .zIndex(0)
            .onTapGesture {
                withAnimation {
                    offsetX = 0
                    isSwiped = false
                }
                onEdit()
            }
            .opacity(offsetX < -2 ? 1 : 0) // Hide when completely closed to prevent corner leak
            
            
            // Foreground content
            content
                .offset(x: offsetX)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 30) // Provide more headroom for vertical scroll
                        .onChanged { value in
                            if Constants.FeatureConfig.isS4Enabled {
                                guard viewStatus != false else { return }
                            }
                            // Prioritize vertical scroll if vertical translation is significant
                            let isHorizontal = abs(value.translation.width) > abs(value.translation.height) * 1.5
                            guard isHorizontal else { return }
                            
                            guard !selectionMode else { return }
                            
                            isScrollDisabled = true
                            
                            if openCardIndex != id {
                                openCardIndex = id
                            }
                            
                            let translation = value.translation.width
                            if translation < 0 {
                                offsetX = max(translation, maxOffset)
                            } else {
                                offsetX = min(translation, 0)
                            }
                        }
                        .onEnded { value in
                            if Constants.FeatureConfig.isS4Enabled {
                                guard viewStatus != false else { return }
                            }
                            isScrollDisabled = false
                            
                            guard !selectionMode else {
                                closeCard(animated: true)
                                return
                            }
                            if value.translation.width < -70 {
                                openCard()
                            } else {
                                closeCard(animated: true)
                            }
                        }
                )
                .onChange(of: openCardIndex) { newValue in
                    if newValue != id {
                        closeCard(animated: true)
                    }
                }
                .onChange(of: selectionMode) { isActive in
                    if isActive {
                        closeCard(animated: true)
                    }
                }
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
        .mask(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }
    
    private func openCard() {
        withAnimation(
            .interactiveSpring(
                response: 0.28,
                dampingFraction: 0.88,
                blendDuration: 0
            )
        ) {
            offsetX = maxOffset
        }
        
        openCardIndex = id
    }
    
    private func closeCard(animated: Bool = true) {
        if animated {
            withAnimation(
                .spring(
                    response: 0.22,
                    dampingFraction: 0.9,
                    blendDuration: 0
                )
            ) {
                offsetX = 0
            }
        } else {
            offsetX = 0
        }
        
        if openCardIndex == id {
            openCardIndex = nil
        }
    }
}

