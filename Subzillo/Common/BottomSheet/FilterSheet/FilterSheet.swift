////
////  FilterSheet.swift
////  Subzillo
////
////  Created by Ratna Kavya on 18/11/25.
////
//
//import SwiftUI
//
//struct FilterSheet: View {
//    
//    //MARK: - Properties
//    var onDelegate: ((FilterModel) -> Void)?
//    @Environment(\.dismiss) private var dismiss
//    @State var filterData   : FilterModel = FilterModel()
//    @State var isClear      = false
//    
//    //MARK: - body
//    var body: some View {
//        VStack {
//            ZStack{
//                Capsule()
//                    .fill(Color.grayCapsule)
//                    .frame(width: 150, height: 5)
//                    .padding(.vertical, 24)
//                    .frame(alignment: .center)
//                
////                if !(filterData.includeFamilySubscriptions == false && filterData.includeExpiredSubscriptions == false && filterData.costOrder == .none && filterData.renewalDateOrder == .none){
//                    HStack{
//                        Spacer()
//                        Button{
//                            filterData      = FilterModel(includeFamilySubscriptions : false,
//                                                          includeExpiredSubscriptions: false,
//                                                          costOrder                  : .none,
//                                                          renewalDateOrder           : .none)
//                            isClear = true
//                        }label: {
//                            HStack{
//                                Text("Clear")
//                                    .font(.appSemiBold(18))
//                                    .foregroundColor(.navyBlueCTA700)
//                                Image("discardIcon")
//                            }
//                        }
//                    }
//                    .opacity((filterData.includeFamilySubscriptions == false && filterData.includeExpiredSubscriptions == false && filterData.costOrder == .none && filterData.renewalDateOrder == .none) ? 0.5 : 1.0)
//                    .disabled((filterData.includeFamilySubscriptions == false && filterData.includeExpiredSubscriptions == false && filterData.costOrder == .none && filterData.renewalDateOrder == .none) ? true : false)
////                }
//            }
//            
//            VStack(alignment: .leading, spacing: 32) {
//                VStack(alignment: .leading, spacing: 16) {
//                    Button {
//                        filterData.includeFamilySubscriptions.toggle()
//                    } label: {
//                        HStack(spacing: 14) {
//                            Image(filterData.includeFamilySubscriptions == true ? "Checkmark" : "UnCheckmark")
//                            Text("Include family subscriptions")
//                                .font(.appRegular(16))
//                                .foregroundColor(.neutralMain700)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .frame(height: 24)
//                    }
//                    Button {
//                        filterData.includeExpiredSubscriptions.toggle()
//                    } label: {
//                        HStack(spacing: 14) {
//                            Image(filterData.includeExpiredSubscriptions == true ? "Checkmark" : "UnCheckmark")
//                            Text("Include Expired subscriptions")
//                                .font(.appRegular(16))
//                                .foregroundColor(.neutralMain700)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .frame(height: 24)
//                    }
//                }
//                DashedHorizontalDivider(dash: [3,3])
//                
//                VStack(alignment: .leading, spacing: 16) {
//                    Button {
//                        filterData.costOrder = .desc
//                    } label: {
//                        HStack(spacing: 14) {
//                            Image(filterData.costOrder == .desc ? "SelectedRadio" : "UnSelectedRadio")
//                            Text("Descending order by cost")
//                                .font(.appRegular(16))
//                                .foregroundColor(.neutralMain700)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .frame(height: 24)
//                    }
//                    Button {
//                        filterData.costOrder = .asc
//                    } label: {
//                        HStack(spacing: 14) {
//                            Image(filterData.costOrder == .asc ? "SelectedRadio" : "UnSelectedRadio")
//                            Text("Ascending order by cost")
//                                .font(.appRegular(16))
//                                .foregroundColor(.neutralMain700)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .frame(height: 24)
//                    }
//                }
//                DashedHorizontalDivider(dash: [3,3])
//                
//                VStack(alignment: .leading, spacing: 16) {
//                    Button {
//                        filterData.renewalDateOrder = .desc
//                    } label: {
//                        HStack(spacing: 14) {
//                            Image(filterData.renewalDateOrder == .desc ? "SelectedRadio" : "UnSelectedRadio")
//                            Text("Descending order by renewal date")
//                                .font(.appRegular(16))
//                                .foregroundColor(.neutralMain700)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .frame(height: 24)
//                    }
//                    Button {
//                        filterData.renewalDateOrder = .asc
//                    } label: {
//                        HStack(spacing: 14) {
//                            Image(filterData.renewalDateOrder == .asc ? "SelectedRadio" : "UnSelectedRadio")
//                            Text("Ascending order by renewal date")
//                                .font(.appRegular(16))
//                                .foregroundColor(.neutralMain700)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .frame(height: 24)
//                    }
//                }
//            }
//            .padding(.bottom, 24)
//            
//            CustomButton(title: "Apply", action: onApplyAction)
//        }
//        .padding(.horizontal, 40)
//    }
//    
//    //MARK: - Button actions
//    private func onApplyAction() {
//        if isClear{
//            filterData = FilterModel(includeFamilySubscriptions : false,
//                                     includeExpiredSubscriptions: false,
//                                     costOrder                  : .none,
//                                     renewalDateOrder           : .none)
//        }
//        onDelegate?(filterData)
//        dismiss()
//    }
//}
//
////MARK: - SheetHeaderView
//struct SheetHeaderView: View {
//    var clearAction: () -> Void
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 3)
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: 120, height: 5)
//            
//            HStack {
//                Spacer()
//                Button(action: clearAction) {
//                    HStack(spacing: 4) {
//                        Text("Clear")
//                            .foregroundColor(.blue)
//                            .font(.system(size: 16, weight: .medium))
//                        
//                        Image(systemName: "xmark")
//                            .foregroundColor(.blue)
//                            .font(.system(size: 14, weight: .semibold))
//                    }
//                }
//            }
//        }
//    }
//}


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
//    @State var filterData   : FilterModel = FilterModel()
    @State var isClear                          = false
    @State var isFromEdit                       = false
    @State private var category                 : String = ""
    @State private var chargeDate               : String = ""
//    @State var showSortingFilters               : Bool   = false
    let filterSelect                            : Bool
    @State var filterData                       : FilterModel

    init(
        onDelegate: ((FilterModel) -> Void)?,
        filterData: FilterModel,
        filterSelect: Bool
    ) {
        self.onDelegate = onDelegate
        self.filterSelect = filterSelect
        _filterData = State(initialValue: filterData) // 🔑 KEY LINE
    }
    @State private var isDatePickerPresented    = false
    @State private var showCategorySheet        = false
    @State var selectedCategory                 : Category?
    @State var canAddMembers                    = false
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @StateObject var addSubscriptionVM          = ManualEntryViewModel()
    @StateObject var subscriptionsVM            = SubscriptionsViewModel()
    @State private var month: Int = Calendar.current.component(.month, from: Date())
    @State private var year: Int = Calendar.current.component(.year, from: Date())
    @State private var showFamilySheet = false
    @State private var selectedFamilyMembers: [ListFamilyMembersResponseData] = []
    @State private var relationsData = [
        ManualDataInfo(id: Constants.getUserId(), title: "Me")
    ]
    
  
    //MARK: - body
    var body: some View {
        VStack {
            ZStack{
                Capsule()
                    .fill(Color.grayCapsule)
                    .frame(width: 150, height: 5)
                    .padding(.vertical, 24)
                    .frame(alignment: .center)
                
//                if !(filterData.includeFamilySubscriptions == false && filterData.includeExpiredSubscriptions == false && filterData.costOrder == .none && filterData.renewalDateOrder == .none){
//                    HStack{
//                        Spacer()
//                        Button{
//                            filterData      = FilterModel(includeFamilySubscriptions : false,
//                                                          includeExpiredSubscriptions: false,
//                                                          costOrder                  : .none,
//                                                          renewalDateOrder           : .none)
//                            isClear = true
//                        }label: {
//                            HStack{
//                                Text("Clear")
//                                    .font(.appSemiBold(18))
//                                    .foregroundColor(.navyBlueCTA700)
//                                Image("discardIcon")
//                            }
//                        }
//                    }
//                    .opacity((filterData.includeFamilySubscriptions == false && filterData.includeExpiredSubscriptions == false && filterData.costOrder == .none && filterData.renewalDateOrder == .none) ? 0.5 : 1.0)
//                    .disabled((filterData.includeFamilySubscriptions == false && filterData.includeExpiredSubscriptions == false && filterData.costOrder == .none && filterData.renewalDateOrder == .none) ? true : false)
//                }

            }
          VStack(alignment: .leading, spacing: 20) {
            if filterSelect {
//              VStack(alignment: .leading, spacing: 5) {
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
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                  }
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
//              DashedHorizontalDivider(dash: [2,2])
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
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                  }
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
                }
//              }
            } else {
//              if showSortingFilters {
              Text("Sort by cost or renewal date")
                  .font(.appRegular(14))
                  .foregroundColor(.neutralMain700)

              VStack(alignment: .leading, spacing: 16) {

                  Button {
                      filterData.costOrder = .desc
                      filterData.renewalDateOrder = .none   // ✅ clear other
                  } label: {
                      HStack(spacing: 14) {
                          Image(filterData.costOrder == .desc ? "SelectedRadio" : "UnSelectedRadio")
                          Text("Descending order by cost")
                              .font(.appRegular(16))
                              .foregroundColor(.neutralMain700)
                      }
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .frame(height: 24)
                  }

                  Button {
                      filterData.costOrder = .asc
                      filterData.renewalDateOrder = .none   // ✅ clear other
                  } label: {
                      HStack(spacing: 14) {
                          Image(filterData.costOrder == .asc ? "SelectedRadio" : "UnSelectedRadio")
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
                      filterData.renewalDateOrder = .desc
                      filterData.costOrder = .none   // ✅ clear other
                  } label: {
                      HStack(spacing: 14) {
                          Image(filterData.renewalDateOrder == .desc ? "SelectedRadio" : "UnSelectedRadio")
                          Text("Descending order by renewal date")
                              .font(.appRegular(16))
                              .foregroundColor(.neutralMain700)
                      }
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .frame(height: 24)
                  }

                  Button {
                      filterData.renewalDateOrder = .asc
                      filterData.costOrder = .none   // ✅ clear other
                  } label: {
                      HStack(spacing: 14) {
                          Image(filterData.renewalDateOrder == .asc ? "SelectedRadio" : "UnSelectedRadio")
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
          .padding(.horizontal,5)
          Spacer()
        }

        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.neutralBg100)
        .ignoresSafeArea(edges: .bottom)
        .onAppear{
          commonApiVM.getCategories()
          addSubscriptionVM.listFamilyMembers(input: ListFamilyMembersRequest(userId: Constants.getUserId()))
          // 🔹 Restore Category
          if let categoryId = filterData.categoryId,
             let categories = commonApiVM.categoriesResponse {
              selectedCategory = categories.first { $0.id == categoryId }
          }

          // 🔹 Restore Family Members
          if !filterData.familyMemberIds.isEmpty {
              selectedFamilyMembers =
              familyMembersWithMe.filter {
                  filterData.familyMemberIds.contains($0.id ?? "")
              }
          }

          // 🔹 Restore Month (already works, but keep consistent)
          if let month = filterData.month,
             let year = filterData.year {
              chargeDate = String(format: "%02d/%d", month, year)
          }
        }
        .onChange(of: commonApiVM.categoriesResponse) { _ in updateCatInfo() }
        .onChange(of: addSubscriptionVM.listFamilyMembersResponse) { _ in updateRelationInfo() }
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
  
  
    //MARK: - Button actions
    private func onApplyAction() {
        if isClear{
            filterData = FilterModel(includeFamilySubscriptions : false,
                                     includeExpiredSubscriptions: false,
                                     costOrder                  : .none,
                                     renewalDateOrder           : .none)
        }
        onDelegate?(filterData)
        dismiss()
    }
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
      if let familyCards = addSubscriptionVM.listFamilyMembersResponse {
          for family in familyCards {
              relationsData.append(
                  ManualDataInfo(
                      id      : family.id ?? "",
                      title   : family.nickName
                  )
              )
          }
          updateUserInfo()
      }
  }
  
  func updateUserInfo()
  {
      //print(commonApiVM.userInfoResponse)
      if commonApiVM.userInfoResponse?.tierName?.lowercased() == "family plan"
      {
          let familyMembersLimit = commonApiVM.userInfoResponse?.familyMembersLimit ?? 0
          if familyMembersLimit > relationsData.count - 1
          {
              canAddMembers = true
          }
      }
  }
  
  func resetFilters() {
    filterData = FilterModel(
      includeFamilySubscriptions: false,
      includeExpiredSubscriptions: false,
      costOrder: .none,
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

      // Add "Me" first
      let me = ListFamilyMembersResponseData(
          id: Constants.getUserId(),
          nickName: "Me"
      )
      list.append(me)

      // Append API members (excluding current user if present)
      let apiMembers = addSubscriptionVM.listFamilyMembersResponse?
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


}

//MARK: - SheetHeaderView
//struct SheetHeaderView: View {
//    var clearAction: () -> Void
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 3)
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: 120, height: 5)
//
//            HStack {
//                Spacer()
//                Button(action: clearAction) {
//                    HStack(spacing: 4) {
//                        Text("Clear")
//                            .foregroundColor(.blue)
//                            .font(.system(size: 16, weight: .medium))
//
//                        Image(systemName: "xmark")
//                            .foregroundColor(.blue)
//                            .font(.system(size: 14, weight: .semibold))
//                    }
//                }
//            }
//        }
//    }
//}
