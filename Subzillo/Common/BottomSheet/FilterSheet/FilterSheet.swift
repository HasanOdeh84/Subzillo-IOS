//
//  FilterSheet.swift
//  Subzillo
//
//  Created by Ratna Kavya on 18/11/25.
//
import SwiftUI
struct FilterSheet: View {
    
    //MARK: - Properties
    var onDelegate: ((FilterModel) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State var isClear                          = false
    @State var isFromEdit                       = false
    @State private var category                 : String = ""
    @State private var chargeDate               : String = ""
    let filterSelect                            : Bool
    @State var filterData                       : FilterModel
    init(
        onDelegate: ((FilterModel) -> Void)?,
        filterData: FilterModel,
        filterSelect: Bool
    ) {
        self.onDelegate = onDelegate
        self.filterSelect = filterSelect
        _filterData = State(initialValue: filterData)
    }
    @State private var isDatePickerPresented    = false
    @State private var showCategorySheet        = false
    @State var selectedCategory                 : Category?
    @State var canAddMembers                    = false
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @StateObject var addSubscriptionVM          = ManualEntryViewModel()
    @StateObject var subscriptionsVM            = SubscriptionsViewModel()
    @State private var month                    : Int = Calendar.current.component(.month, from: Date())
    @State private var year                     : Int = Calendar.current.component(.year, from: Date())
    @State private var showFamilySheet          = false
    @State private var selectedFamilyMembers    : [ListFamilyMembersResponseData] = []
    @State private var relationsData            = [
        ManualDataInfo(id: Constants.getUserId(), title: "Me".localized)
    ]
    @State private var sheetHeight              : CGFloat = 400
    
    //MARK: - body
    var body: some View {
        VStack {
            ZStack{
                Capsule()
                    .fill(Color.grayCapsule)
                    .frame(width: 150, height: 5)
                    .padding(.vertical, 24)
                    .frame(alignment: .center)
            }
            VStack(alignment: .leading, spacing: 20) {
                if filterSelect {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Filter by Category")
                            .font(.appRegular(14))
                            .foregroundColor(.neutralMain700)
                        
                        Button(action: selectCategory) {
                            FieldView(
                                text        : $category,
                                textValue   : selectedCategory?.name ?? "",
                                title       : nil,
                                image       : "gridIcon",
                                placeHolder : "Please select",
                                isButton    : true,
                                isText      : true
                            )
                            .frame(height: 48)
                        }
                        .sheet(isPresented: $showCategorySheet) {
                            CategoriesBottomSheet(
                                selectedCategory : $selectedCategory,
                                categoryResponse : commonApiVM.categoriesResponse,
                                header           : "Select Category",
                                placeholder      : "Search Category"
                            )
                            .presentationDetents([.large])
                            .presentationDragIndicator(.hidden)
                        }
                        .padding(.horizontal, -5)
                    }
                    .padding(.bottom, 20)
                    
                    DashedHorizontalDivider(dash: [2,2])
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Button {
                            filterData.includeExpiredSubscriptions.toggle()
                        } label: {
                            HStack(spacing: 14) {
                                Image(filterData.includeExpiredSubscriptions == true ? "Checkmark" : "UnCheckmark")
                                Text("Include Expired subscriptions")
                                    .font(.appRegular(16))
                                    .foregroundColor(.neutralMain700)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 24)
                        }
                        
                        Button {
                            filterData.includeFamilySubscriptions.toggle()
                        } label: {
                            HStack(spacing: 14) {
                                Image(filterData.includeFamilySubscriptions == true ? "Checkmark" : "UnCheckmark")
                                Text("Include family subscriptions")
                                    .font(.appRegular(16))
                                    .foregroundColor(.neutralMain700)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 24)
                        }
                    }
                    if filterData.includeFamilySubscriptions {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Filter by family member")
                                .font(.appRegular(14))
                                .foregroundColor(.neutralMain700)
                            
                            Button {
                                showFamilySheet = true
                            } label: {
                                FieldView(
                                    text        : .constant(""),
                                    textValue   : selectedFamilyMembers.isEmpty
                                    ? ""
                                    : selectedFamilyMembers
                                        .compactMap { $0.nickName }
                                        .joined(separator: ", "),
                                    title       : nil,
                                    image       : "gridIcon",
                                    placeHolder : "Please select",
                                    isButton    : true,
                                    isText      : true
                                )
                                .frame(height: 48)
                            }
                            .sheet(isPresented: $showFamilySheet) {
                                FamilyMembersBottomSheet(
                                    selectedMembers: $selectedFamilyMembers,
                                    //                          members: addSubscriptionVM.listFamilyMembersResponse ?? []
                                    members: familyMembersWithMe
                                )
//                                .overlay {
//                                    GeometryReader { geo in
//                                        Color.clear
//                                            .preference(
//                                                key: InnerHeightPreferenceKey.self,
//                                                value: geo.size.height
//                                            )
//                                    }
//                                }
//                                .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
//                                    if height > 150 {
//                                        sheetHeight = height
//                                    }
//                                }
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.hidden)
                            }
                            .padding(.horizontal, -5)
                        }
                        .padding(.bottom, 20)
                    }
                    DashedHorizontalDivider(dash: [2,2])
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Filter by month & year")
                            .font(.appRegular(14))
                            .foregroundColor(.neutralMain700)
                        
                        Button(action: dateSelection) {
                            FieldView(
                                text        : $chargeDate,
                                textValue   : "",
                                title       : nil,
                                image       : "Calendar1",
                                placeHolder : "mm/yyyy",
                                isButton    : false,
                                isText      : true,
                                isDate      : true
                            )
                            .frame(height: 48)
                        }
                        .sheet(isPresented: $isDatePickerPresented) {
                            CustomCalenderSheet(
                                isPresented   : $isDatePickerPresented,
                                selectedMonth : $month,
                                selectedYear  : $year,
                                onDone: {
                                    let monthString = String(format: "%02d", month)
                                    chargeDate = "\(monthString)/\(year)"
                                    filterData.month = month
                                    filterData.year  = year
                                    getSubsByMonthApi()
                                }
                            )
                            .presentationDetents([.height(300)])
                            .presentationDragIndicator(.hidden)
                        }
                        .padding(.horizontal, -5)
                    }
                } else {
                    Text("Sort by cost or renewal date")
                        .font(.appRegular(14))
                        .foregroundColor(.neutralMain700)
                    VStack(alignment: .leading, spacing: 16) {
                        Button {
                            filterData.costOrder = 1
                            filterData.renewalDateOrder = .none
                        } label: {
                            HStack(spacing: 14) {
                                Image(filterData.costOrder == 1 ? "SelectedRadio" : "UnSelectedRadio")
                                Text("Descending order by cost")
                                    .font(.appRegular(16))
                                    .foregroundColor(.neutralMain700)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 24)
                        }
                        Button {
                            filterData.costOrder = 2
                            filterData.renewalDateOrder = .none
                        } label: {
                            HStack(spacing: 14) {
                                Image(filterData.costOrder == 2 ? "SelectedRadio" : "UnSelectedRadio")
                                Text("Ascending order by cost")
                                    .font(.appRegular(16))
                                    .foregroundColor(.neutralMain700)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 24)
                        }
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        Button {
                            filterData.costOrder = 3
                        } label: {
                            HStack(spacing: 14) {
                                Image(filterData.costOrder == 3 ? "SelectedRadio" : "UnSelectedRadio")
                                Text("Descending order by renewal date")
                                    .font(.appRegular(16))
                                    .foregroundColor(.neutralMain700)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 24)
                        }
                        Button {
                            filterData.costOrder = 4
                        } label: {
                            HStack(spacing: 14) {
                                Image(filterData.costOrder == 4 ? "SelectedRadio" : "UnSelectedRadio")
                                Text("Ascending order by renewal date")
                                    .font(.appRegular(16))
                                    .foregroundColor(.neutralMain700)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 24)
                        }
                    }
                }
            }
            .padding(.bottom, 24)
            HStack(spacing: 15) {
                Button(action: resetFilters) {
                    Text("Reset")
                        .font(.appSemiBold(18))
                        .foregroundColor(Color.navyBlueCTA700)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.navyBlueCTA700, lineWidth: 1)
                        )
                }
                CustomButton(title: "Apply",action: onApplyAction)
            }
            .padding(.horizontal,-15)
            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.neutralBg100)
        .ignoresSafeArea(edges: .bottom)
        .onAppear{
            commonApiVM.getCategories()
            addSubscriptionVM.listFamilyMembers(input: ListFamilyMembersRequest(userId: Constants.getUserId()))
            if let categoryId = filterData.categoryId,
               let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first { $0.id == categoryId }
            }
            
            if !filterData.familyMemberIds.isEmpty {
                selectedFamilyMembers =
                familyMembersWithMe.filter {
                    filterData.familyMemberIds.contains($0.id ?? "")
                }
            }
            if let month = filterData.month,
               let year = filterData.year {
                chargeDate = String(format: "%02d/%d", month, year)
            }
        }
        .onChange(of: commonApiVM.categoriesResponse) { _ in updateCatInfo() }
        .onChange(of: addSubscriptionVM.listFamilyMembersResponse?.familyMembers) { _ in updateRelationInfo() }
        .onChange(of: selectedFamilyMembers) { members in
            filterData.familyMemberIds = members.compactMap { $0.id }
        }
        .onChange(of: filterData.includeFamilySubscriptions) { isEnabled in
            if !isEnabled {
                selectedFamilyMembers.removeAll()
                filterData.familyMemberIds.removeAll()
            }
        }
        .onChange(of: selectedCategory) { newValue in
            filterData.categoryId   = newValue?.id
            filterData.categoryName = newValue?.name
        }
    }
    
    //MARK: - Userdefined methods
    private func selectCategory()
    {
        showCategorySheet = true
    }
    
    private func updateCatInfo() {
        // Edit flow
        if isFromEdit == true {
            if globalSubscriptionData?.categoryId ?? "" != "" {
                if let categories = commonApiVM.categoriesResponse {
                    selectedCategory = categories.first {
                        $0.id == globalSubscriptionData?.categoryId
                    }
                }
            }
        }
        // Siri / manual text match
        if category != "" {
            if let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first {
                    $0.name?.lowercased() == category.lowercased()
                }
            }
        }
        
        if filterData != nil{
            if let categoryId = filterData.categoryId,
               let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first { $0.id == categoryId }
            }
        }
    }
    
    func updateRelationInfo()
    {
        relationsData.removeAll()
        if let familyCards = addSubscriptionVM.listFamilyMembersResponse?.familyMembers {
            for family in familyCards {
                relationsData.append(
                    ManualDataInfo(
                        id      : family.id ?? "",
                        title   : family.nickName
                    )
                )
            }
//            updateUserInfo()
        }
    }
    
//    func updateUserInfo()
//    {
//        if commonApiVM.userInfoResponse?.tierName?.lowercased() == "family plan"
//        {
//            let familyMembersLimit = commonApiVM.userInfoResponse?.familyMembersLimit ?? 0
//            if familyMembersLimit > relationsData.count - 1
//            {
//                canAddMembers = true
//            }
//        }
//    }
    
    func resetFilters() {
        filterData = FilterModel(
            includeFamilySubscriptions: false,
            includeExpiredSubscriptions: false,
            costOrder: 0,
            renewalDateOrder: .none
        )
        filterData.familyMemberIds = []
        selectedCategory = nil
        category = ""
        selectedFamilyMembers.removeAll()
        isClear = true
    }
    
    private var familyMembersWithMe: [ListFamilyMembersResponseData] {
        var list: [ListFamilyMembersResponseData] = []
        let me = ListFamilyMembersResponseData(
            id: Constants.getUserId(),
            nickName: "Me".localized
        )
        list.append(me)
        let apiMembers = addSubscriptionVM.listFamilyMembersResponse?.familyMembers?
            .filter { $0.id != Constants.getUserId() } ?? []
        list.append(contentsOf: apiMembers)
        return list
    }
    
    private func dateSelection() {
        withAnimation(.easeInOut) {
            isDatePickerPresented = true
        }
    }
    
    func getSubsByMonthApi() {
        let input = GetSubscriptionsByMonthRequest(
            userId: Constants.getUserId(),
            year: year,
            month: month
        )
        subscriptionsVM.getSubscriptionsByMonth(input: input)
    }
    
    //MARK: - Button actions
    private func onApplyAction() {
        if isClear{
            filterData = FilterModel(includeFamilySubscriptions : false,
                                     includeExpiredSubscriptions: false,
                                     costOrder                  : 0,
                                     renewalDateOrder           : .none)
        }
        onDelegate?(filterData)
        dismiss()
    }
}
