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
    @State var selectionMode                    : Bool = false
    @State var showDeletePopup                  : Bool = false
    @State var filterData                       : FilterModel = FilterModel()
    @State private var subscriptions            = [SubscriptionInfoo]()
    @State private var openCardIndex            : Int?
    @State private var openCalendarId           : String? = nil
    @State private var selectedDate             = Date()
    @State private var filterSelect             : Bool = false
    @State private var pendingFilterSelect      : Bool? = nil
    @State private var viewMode                 : SubscriptionsMode = .list
    @State private var isScrollDisabled         : Bool = false
    @State private var activeCardId             : String? = nil
    var selectedTab                             : Segment? = .first
    @State private var deleteSheetHeight        : CGFloat = .zero
    
    var hasSelection: Bool {
        subscriptionsList.contains(where: { $0.isSelected ?? false })
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
                HeaderView(title: "Your subscriptions",titleFont: 24) {
                    Constants.FeatureConfig.performS4Action {
                        goToNotifications()
                    }
                }
                .padding(.top, 50)
                .frame(alignment: .leading)
                
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
                    // MARK: - Segment
                    HStack(spacing: 0) {
                        SegmentView(selectedSegment : $selectedSegment,
                                    leftImage       : "left-to-right-list-bullet",
                                    rightImage      : "calendar-04",
                                    leftText        : "List View",
                                    rightText       : "Calendar")
                        .padding(.trailing, 8)
                        
                        HStack(spacing: 8) {
                            Button(action: clickOnChat) {
                                Image("chart-line-data-02")
                                    .renderingMode(.template)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(viewMode == .analytics ? .white : .navyBlueCTA700)
                            }
                            .frame(width: 40, height: 40)
                            .background(
                                viewMode == .analytics ? Color.navyBlueCTA700 : Color.clear
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 2
                                    )
                                    .opacity(viewMode == .analytics ? 0 : 1)
                            )
                            .cornerRadius(8)
                            
                            if selectedSegment == .first && viewMode != .analytics {
                                Button(action: clickOnFilter) {
                                    Image("filter")
                                        .frame(width: 20, height: 20)
                                }
                                .frame(width: 40, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .cornerRadius(8)
                                
                                // Sort Button
                                Button(action: {
                                    clickOnSort()
                                }) {
                                    Image("sort")
                                        .frame(width: 20, height: 20)
                                }
                                .frame(width: 40, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .padding(.top, 16)
                }
                
                // MARK: - year and Month
                if viewMode != .analytics {
                    if selectedSegment == .second{
                        Button(action: dateSelection) {
                            FieldView(text: $chargeDate, textValue: "", title: "", image: "Calendar1", placeHolder: "mm/yyyy", isButton: false, isText: true, isDate:true)
                        }
                        /*Button(action: {
                         showExpiryPopup = true
                         }) {
                         FieldView(text: $expDate, textValue: expDate, title: "Amount", image: "expDateIcon", placeHolder: "MM / YY", isText:  true)
                         }*/
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
                        /*.background(
                         DatePickerPopup(isPresented: $isDatePickerPresented, selectedDate: $tempDate) { date in
                         let formatter = DateFormatter()
                         formatter.dateFormat = "MM/yyyy"
                         self.chargeDate = formatter.string(from: date)
                         let calendar = Calendar.current
                         year = calendar.component(.year, from: date)
                         month = calendar.component(.month, from: date)
                         print("year:", year)   // 2025
                         print("month:", month) // 11
                         print(chargeDate)
                         getSubsByMonthApi()
                         }
                         )*/
                    }
                }
            }
            .padding(.bottom, 24)
            //            VStack {
            //                        DatePicker(
            //                            "Select Date",
            //                            selection: $selectedDate,
            //                            displayedComponents: .date
            //                        )
            //                        .datePickerStyle(.wheel) // Displays a calendar-style picker
            //                        .padding()
            //
            //                        Text("Selected Date: \(selectedDate, formatter: dateFormatter)")
            //                    }
            //MARK: Analytics view
            if viewMode == .analytics {
                if Constants.FeatureConfig.isS4Enabled {
                    AnalyticalView()
                }
            } else if let segment = selectedSegment {
                //MARK: Calender view
                if segment == .second{
                    if monthlySubscriptions.count != 0{
                        List {
                            ForEach(subscriptions, id: \.id) { subscription in
                                let isOpen = openCalendarId == subscription.id
                                SubscriptionRow(subscriptionData: subscription, isOpen: isOpen)
                                    .onTapGesture {
                                        if openCalendarId == subscription.id {
                                            openCalendarId = nil
                                        } else {
                                            openCalendarId = subscription.id
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .scrollIndicators(.hidden)
                        .frame(maxWidth: .infinity)
                        .scrollContentBackground(.hidden)
                        .background(.neutralBg100)
                        .padding(.bottom,86)
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
                }  else if segment == .first{
                    if subscriptionsList.count != 0{
                        //MARK: - subscriptions list view
//                        ScrollViewReader { proxy in
//                            List {
//                                ForEach(Array(subscriptionsList.enumerated()), id: \.element.id) { index, sub in
//                                    SwipeActionCard(
//                                        id              : index,
//                                        openCardIndex   : $openCardIndex,
//                                        isScrollDisabled: $isScrollDisabled,
//                                        selectionMode   : selectionMode,
//                                        viewStatus      : sub.viewStatus ?? false,
//                                        onEdit          : {
//                                            editSubscription(sub: sub)
//                                        },
//                                        onDelete        : {
//                                            // Clear any previous selections
//                                            for i in subscriptionsList.indices {
//                                                subscriptionsList[i].isSelected = false
//                                            }
//                                            // Mark ONLY this item
//                                            subscriptionsList[index].isSelected = true
//                                            showDeletePopup = true
//                                        }
//                                    ) {
//                                        subscriptionListCard(
//                                            subscriptionData   : sub,
//                                            selectionMode      : selectionMode,
//                                            onSelect           : {
//                                                toggleSelection(at: index)
//                                            },
//                                            onLongPress        : {
//                                                handleLongPress(at: index) }
//                                        )
//                                        .contentShape(Rectangle())
//                                    }
//                                    .onTapGesture {
//                                        guard openCardIndex == nil else { return }
//                                        if selectionMode {
//                                            toggleSelection(at: index)
//                                        } else {
//                                            if sub.viewStatus ?? false{
//                                                AppIntentRouter.shared.navigate(
//                                                    to: .subscriptionMatchView(
//                                                        fromList: true,
//                                                        subscriptionId: sub.id ?? ""
//                                                    )
//                                                )
//                                            } else {
//                                                SheetManager.shared.isUpgradeSheetVisible = true
//                                            }
//                                        }
//                                    }
//                                    .listRowSeparator(.hidden)
//                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 8, trailing: 0))
//                                    .listRowBackground(Color.clear)
//                                    .onAppear {
//                                        if index == subscriptionsList.count - 1 {
//                                            loadNextPageIfNeeded()
//                                        }
//                                    }
//                                    .padding(.bottom, index == subscriptionsList.count - 1 ? 90 : 0)
//                                }
//                                .background(Color.clear)
//                                .padding(.top, 5)
//                            }
//                            .listStyle(.plain)
//                            .scrollIndicators(.hidden)
//                            .background(Color.clear)
//                            .scrollContentBackground(.hidden)
//                            .scrollDisabled(isScrollDisabled)
//                            .onChange(of: subscriptionsList) { _ in
//                                if page == 0, let firstId = subscriptionsList.first?.id {
//                                    DispatchQueue.main.async {
//                                        withAnimation {
//                                            proxy.scrollTo(firstId, anchor: .top)
//                                        }
//                                    }
//                                }
//                            }
//                            .onAppear {
//                                subscriptionsVM.isLoading = false
//                            }
//                        }
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
                                                handleLongPress(at: index)
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
                                                    SheetManager.shared.isUpgradeSheetVisible = true
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
                                    .padding(.bottom, index == subscriptionsList.count - 1 ? 90 : 0)
                                }
                                .background(Color.clear)
                                .padding(.top, 5)
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
        .background(Color.neutralBg100)
        .padding(20)
        .onAppear {
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
        }
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
                }, title    : "Are you sure you want to delete the subscriptions?\nData will be permanently deleted",
                subTitle    :"",
                imageName   : "del_red_big",
                buttonIcon  : "deleteIcon",
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
            .presentationDetents([.height(600)])
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
        }
    }
    
    //MARK: - User defined methods
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
                                                                         
                                                                         categoryId                  : filterData.categoryId,
                                                                         familyMembers               : filterData.familyMemberIds,
                                                                         month                       : filterData.month,
                                                                         year                        : filterData.year), sortBy: filterData.costOrder)
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
        let input = GetSubscriptionsByMonthRequest(userId: Constants.getUserId(), year: year, month: month)
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
        
        if page == 0 {
            self.subscriptionsList = listArray
        } else {
            self.subscriptionsList.append(contentsOf: listArray)
        }
        print("data from response")
    }
    
    func updateMonthSubsList(){
        subscriptions.removeAll()
        monthlySubscriptions = subscriptionsVM.getSubsByMonthResponse?.days ?? []
        if let days = subscriptionsVM.getSubsByMonthResponse?.days{
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
        }
    }
    
    func editSubscription(sub: SubscriptionListData){
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
                                                         subscriptionId : sub.id ?? ""))
    }
    
    //MARK: - Button actions
    private func toggleSubscription(at index: Int) {
        var obj = subscriptions[index]
        if (obj.isOpen ?? false ) == true
        {
            obj.isOpen = false
        }
        else{
            obj.isOpen = true
        }
        subscriptions[index] = obj
    }
    
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
}

//MARK: - SwipeActionCard
struct SwipeActionCard<Content: View>: View {
    
    let id                          : Int
    @Binding var openCardIndex      : Int?
    @Binding var isScrollDisabled   : Bool
    let selectionMode               : Bool
    let viewStatus                  : Bool
    let onEdit                      : () -> Void
    let onDelete                    : () -> Void
    let content                     : Content
    @State private var offsetX      : CGFloat = 0
    private let maxOffset           : CGFloat = -130
    
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
            // DELETE (foreground, overlays Edit)
            Button {
                onDelete()
                closeCard()
            } label: {
                VStack(spacing: 8) {
                    Image("del_white")
                    Text("Delete")
                        .font(.appSemiBold(14))
                        .foregroundColor(.white)
                }
                .frame(width: 70, height: 74)
                .background(Color("redColor"))
                .clipShape(
                    RoundedCorner(
                        radius: 8,
                        corners: [.topRight, .bottomRight]
                    )
                )
                .overlay(
                    RoundedCorner(
                        radius: 8,
                        corners: [.topRight, .bottomRight]
                    )
                    .stroke(Color.neutral300Border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // EDIT (background)
            Button {
                onEdit()
                closeCard()
            } label: {
                VStack(spacing: 8) {
                    Image("edit_white")
                    Text("Edit")
                        .font(.appSemiBold(14))
                        .foregroundColor(.white)
                }
                .frame(width: 70, height: 74)
                .background(Color.greenClr)
                .clipShape(
                    RoundedCorner(
                        radius: 8,
                        corners: [.topRight, .bottomRight]
                    )
                )
                .overlay(
                    RoundedCorner(
                        radius: 8,
                        corners: [.topRight, .bottomRight]
                    )
                    .stroke(Color.neutral300Border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .offset(x: -65)
            .zIndex(0)
            
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
            RoundedRectangle(cornerRadius: 8)
        )
        .mask(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
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

