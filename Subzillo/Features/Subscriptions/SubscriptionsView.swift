//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI

struct SubscriptionsView: View {
    
    //MARK: - Properties
    @State private var selectedSegment          : Segment = .first
    @State private var currentDate              = Date()
    @StateObject var subscriptionsVM            = SubscriptionsViewModel()
    @State private var page                     = 0
    @State private var subscriptionsList        = [SubscriptionListData]()
    @State private var isDatePickerPresented    = false
    @State private var showFilterSheet          = false
    @State private var chargeDate               : String = ""
    @State private var tempDate                 = Date()
    @State var year                             : Int = 0
    @State var month                            : Int = 0
    @State private var monthlySubscriptions     = [SubscriptionDay]()
    @State var selectionMode                    : Bool = false
    @State var showDeletePopup                  : Bool = false
    @State var filterData                       : FilterModel = FilterModel()
    @State private var subscriptions            = [SubscriptionInfoo]()
    @State private var selectedDate = Date()
    
    var hasSelection: Bool {
        subscriptionsList.contains(where: { $0.isSelected ?? false })
    }
    
    // Date Formatter Helpers
    private var currentYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL" // Full month name
        return formatter.string(from: currentDate)
    }
    
    //MARK: - body
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                //                // MARK: - Header
                HeaderView(title: "Your subscriptions",titleFont: 24) {
                    goToNotifications()
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
                            
                            if selectedSegment == .first{
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
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .padding(.top, 16)
                }
                
                // MARK: - year and Month
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
            
            //MARK: - calender view
            if selectedSegment == .second{
                if monthlySubscriptions.count != 0{
                    List {
                        ForEach(Array(subscriptions.enumerated()), id: \.offset) { index, subscription in
                            SubscriptionRow(subscriptionData: subscription)
                                .onTapGesture {
                                    toggleSubscription(at: index)
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
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
            }else if selectedSegment == .first{
                if subscriptionsList.count != 0{
                    //MARK: - subscriptions list view
                    ScrollView(showsIndicators: false){
                        LazyVStack(spacing: 8) {
                            ForEach(Array(subscriptionsList.enumerated()), id: \.offset) { index, sub in
                                subscriptionListCard(subscriptionData   : sub,
                                                     selectionMode      : selectionMode,
                                                     onSelect           : { toggleSelection(at: index) },
                                                     onLongPress        : { selectionMode = true })
//                                .contentShape(Rectangle())
                                .simultaneousGesture(
                                        TapGesture().onEnded {
                                            if !selectionMode{
                                                AppIntentRouter.shared.navigate(
                                                    to: .subscriptionMatchView(fromList: true, subscriptionId: sub.id ?? "")
                                                )
                                            }
                                        }
                                    )
//                                .onTapGesture {
//                                    AppIntentRouter.shared.navigate(to: .subscriptionMatchView(fromList: true, subscriptionId: sub.id ?? ""))
//                                }
                                .onAppear{
                                    if index == subscriptionsList.count - 1 {
                                        loadNextPageIfNeeded()
                                    }
                                }
                            }
                        }
                        .padding(.bottom,90)
                    }
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
            Spacer()
        }
        .background(Color.neutralBg100)
        .padding(20)
        .onAppear {
            selectedSegment = .first
            listSubsApi()
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yyyy"
            year    = Calendar.current.component(.year, from: now)
            month   = Calendar.current.component(.month, from: now)
            self.chargeDate = formatter.string(from: now)
        }
        .sheet(isPresented: $showDeletePopup) {
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
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(340)])
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet(
                onDelegate: { filterData in
                    self.filterData = filterData
                    print(filterData)
                    page = 0
                    listSubsApi()
                },
                filterData: self.filterData
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(500)])
        }
        .onChange(of: subscriptionsVM.listSubsResponse) { _ in updateSubsList() }
        .onChange(of: subscriptionsVM.getSubsByMonthResponse) { _ in updateMonthSubsList() }
        .onChange(of: subscriptionsVM.isDeletedSubscription) { _ in updateDeleteSubscription() }
        .onChange(of: selectedSegment) { _ in callApis() }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    //MARK: - User defined methods
    func callApis(){
        if selectedSegment == .first{
            page = 0
            listSubsApi()
        }else{
            getSubsByMonthApi()
        }
    }
    
    func listSubsApi(showLoader:Bool = true){
        let input = ListSubscriptionsRequest(userId : Constants.getUserId(),
                                             page   : page,
                                             filter : SubscriptionFilter(includeFamilyMembers        : filterData.includeFamilySubscriptions,
                                                                         includeExpiredSubscriptions : filterData.includeExpiredSubscriptions,
                                                                         amountOrder                 : filterData.costOrder.rawValue,
                                                                         nextPaymentDateOrder        : filterData.renewalDateOrder.rawValue))
        subscriptionsVM.listSubscriptions(input: input, showLoader: showLoader)
    }
    
    func loadNextPageIfNeeded(){
        if self.subscriptionsVM.listSubsResponse?.totalPages ?? 0 > page{
            page += 1
            listSubsApi(showLoader: false)
        }
    }
    
    func getSubsByMonthApi(){
        let input = GetSubscriptionsByMonthRequest(userId: Constants.getUserId(), year: year, month: month)
        subscriptionsVM.getSubscriptionsByMonth(input: input)
    }
    
    func updateSubsList(){
        DispatchQueue.main.async {
            if page == 0 {
                self.subscriptionsList.removeAll()
            }
            self.subscriptionsList.append(contentsOf: self.subscriptionsVM.listSubsResponse?.subscriptions ?? [])
            print("data from response")
        }
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
                        let relation = (subscription.subscriptionFor == "" || subscription.subscriptionFor == Constants.getUserId()) ? "Me" : subscription.subscriptionFor
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
                            let rel     = (sub.subscriptionFor == "" || sub.subscriptionFor == Constants.getUserId()) ? "Me" : sub.subscriptionFor
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
                subscriptions.append(SubscriptionInfoo(id           : day.id ?? "",
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
        if (obj.isSelected ?? false ) == true
        {
            obj.isSelected = false
        }
        else{
            obj.isSelected = true
        }
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
        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
    }
    
    private func clickOnChat() {
        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
    }
    
    private func clickOnFilter() {
        showFilterSheet = true
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

#Preview {
    SubscriptionsView()
}
