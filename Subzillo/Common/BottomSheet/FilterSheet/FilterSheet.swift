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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            Capsule()
                .fill(Color.textPrimary0E101AF4F1FB.opacity(0.15))
                .frame(width: 40, height: 4)
                .padding(.top, 20)
                .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 0) {
                // Title
                Text("Filter & Sort")
                    .font(.geistSemiBold(16))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                    .padding(.bottom, 4)
                
                Text("Refine what you see")
                    .font(.geistRegular(14))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    .padding(.bottom, 24)
                
                // INCLUDE Section
                Text("INCLUDE")
                    .font(.jetBrainsMedium(11))
                    .tracking(1.5)
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    .padding(.bottom, 12)
                
                VStack(spacing: 12) {
                    FilterToggleRow(
                        title: "Expired subscriptions",
                        subtitle: "Show subs that have ended",
                        isOn: $filterData.includeExpiredSubscriptions
                    )
                    FilterToggleRow(
                        title: "Family subscriptions",
                        subtitle: "Shared by family members",
                        isOn: $filterData.includeFamilySubscriptions
                    )
                }
                .padding(.bottom, 24)
                
                // SORT BY Section
                Text("INCLUDE") // Keeping text from mockup design
                    .font(.jetBrainsMedium(11))
                    .tracking(1.5)
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    .padding(.bottom, 12)
                
                HStack(spacing: 12) {
                    FilterSortCard(
                        title: "Renewal date",
                        subtitle: "Nearest first",
                        isSelected: filterData.costOrder == 4 || filterData.costOrder == 3,
                        action: { filterData.costOrder = 4 }
                    )
                    
                    FilterSortCard(
                        title: "Price",
                        subtitle: "Highest first",
                        isSelected: filterData.costOrder == 1 || filterData.costOrder == 2,
                        action: { filterData.costOrder = 1 }
                    )
                }
                .padding(.bottom, 32)
                
//                Spacer(minLength: 0)
                
                // Apply Button
                GradientBgButton(
                    title       : "Apply filters",
                    isSolid     : true,
                    showChevron : false
                ) {
                    onApplyAction()
                }
//                Button(action: onApplyAction) {
//                    Text("Apply filters")
//                        .font(.geistSemiBold(16))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity, minHeight: 56)
//                        .background(themeManager.accentGradient)
//                        .cornerRadius(28)
//                        .shadow(color: themeManager.accentShadowColor, radius: 15, x: 0, y: 8)
//                }
//                .buttonStyle(InteractiveButtonStyle())
                .padding(.bottom, 15)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.bottomBGFFFFFF120A1F)
        .ignoresSafeArea(edges: .bottom)
        /*
        // --- OLD UI COMMENTED OUT AS REQUESTED ---
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
                                placeholder      : "Search"
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
                                    filterData.monthYear = String(format: "%04d-%02d", year, month)
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
        */
        .onAppear{
            commonApiVM.getCategories()
            addSubscriptionVM.listFamilyMembers(input: ListFamilyMembersRequest(userId: Constants.getUserId()))
            if let categoryId = filterData.categoryId,
               let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first { $0.id == categoryId }
            }
            
            if let memberIds = filterData.familyMemberIds, !memberIds.isEmpty {
                selectedFamilyMembers =
                familyMembersWithMe.filter {
                    memberIds.contains($0.id ?? "")
                }
            }
            if let monthYear = filterData.monthYear {
                let components = monthYear.split(separator: "-")
                if components.count == 2,
                   let y = Int(components[0]),
                   let m = Int(components[1]) {
                    self.year = y
                    self.month = m
                    chargeDate = String(format: "%02d/%d", m, y)
                }
            }
        }
        .onChange(of: commonApiVM.categoriesResponse) { _ in updateCatInfo() }
        .onChange(of: addSubscriptionVM.listFamilyMembersResponse?.familyMembers) { _ in updateRelationInfo() }
        .onChange(of: filterData.includeFamilySubscriptions) { isEnabled in
            if !isEnabled {
                selectedFamilyMembers.removeAll()
                filterData.familyMemberIds = []
            } else if filterData.familyMemberIds == nil {
                // If it was nil (default), populate all
                selectedFamilyMembers = familyMembersWithMe
                filterData.familyMemberIds = selectedFamilyMembers.compactMap { $0.id }
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
            
            // Auto-select if includeFamilySubscriptions is true and (it's the first time/nil OR after reset)
            if filterData.includeFamilySubscriptions && (filterData.familyMemberIds == nil || isClear) {
                selectedFamilyMembers = familyMembersWithMe
                filterData.familyMemberIds = selectedFamilyMembers.compactMap { $0.id }
            } else if let memberIds = filterData.familyMemberIds {
                // User has made a deliberate selection (could be empty [])
                selectedFamilyMembers = familyMembersWithMe.filter {
                    memberIds.contains($0.id ?? "")
                }
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
            includeFamilySubscriptions: true,
            includeExpiredSubscriptions: true,
            costOrder: 0,
            renewalDateOrder: .none
        )
        selectedCategory = nil
        category = ""
        isClear = true
        // Set to nil to trigger re-population in updateRelationInfo
        filterData.familyMemberIds = nil
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
    
//    func getSubsByMonthApi() {
//        let input = GetSubscriptionsByMonthRequest(
//            userId: Constants.getUserId(),
//            year: year,
//            month: month
//        )
//        subscriptionsVM.getSubscriptionsByMonth(input: input)
//    }
    
    //MARK: - Button actions
    private func onApplyAction() {
        if isClear{
            filterData = FilterModel(includeFamilySubscriptions : false,
                                     includeExpiredSubscriptions: false,
                                     costOrder                  : 0,
                                     renewalDateOrder           : .none)
            filterData.familyMemberIds = []
        } else {
            filterData.familyMemberIds = selectedFamilyMembers.compactMap { $0.id }
        }
        onDelegate?(filterData)
        dismiss()
    }
}

// MARK: - New Filter Components
struct FilterToggleRow: View {
    var title: String
    var subtitle: String
    @Binding var isOn: Bool
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.geistSemiBold(15))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                Text(subtitle)
                    .font(.geistRegular(13))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
            }
            Spacer()
            CustomFilterToggle(isOn: $isOn)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.white_white4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
        )
    }
}

struct CustomFilterToggle: View {
    @Binding var isOn: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(isOn ? AnyShapeStyle(themeManager.accentGradient) : AnyShapeStyle(Color.flagBgF1F2F7F7F7F9))
                .frame(width: 44, height: 24)
            
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                .offset(x: isOn ? 10 : -10)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        .onTapGesture {
            isOn.toggle()
        }
    }
}

struct FilterSortCard: View {
    var title: String
    var subtitle: String
    var isSelected: Bool
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.geistSemiBold(13))
                    .foregroundColor(isSelected ? themeManager.accentTextColor : Color.textPrimary0E101AF4F1FB)
                Text(subtitle)
                    .font(.jetBrainsMedium(10))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AnyShapeStyle(themeManager.accentTextColor.opacity(0.133)) : AnyShapeStyle(themeManager.white_white4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? themeManager.accentTextColor : themeManager.textPrimaryLight8_white8, lineWidth: 1)
            )
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}
