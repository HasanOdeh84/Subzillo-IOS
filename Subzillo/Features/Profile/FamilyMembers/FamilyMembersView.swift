//
//  FamilyMembersView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 29/12/25.
//

import SwiftUI

struct FamilyMembersView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State var openFamilyMemberSheet        = false
    @StateObject var manualVM               = ManualEntryViewModel()
    @State private var expandedMemberId     : String? = nil
    @State private var openSwipeCardIndex   : Int? = nil
    @State private var editingFamily        : EditableFamilyWrapper?
    @State private var isScrollDisabled     : Bool = false
    @EnvironmentObject var commonApiVM      : CommonAPIViewModel
    @StateObject var familyMembersVM        = FamilyMembersViewModel()
    @State var selectedCountry              : Country?
    @State var showDeletePopup              : Bool = false
    @State var deleteFamilyMemberId         : String = ""
    
    @State private var deleteSheetHeight : CGFloat = .zero

    struct EditableFamilyWrapper: Identifiable {
        let id = UUID()
        let data: ListFamilyMembersResponseData
    }
    
    //MARK: - Body
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image("back_gray")
                        .frame(width: 24, height: 24)
                }
                
                Text("Family Members")
                    .font(.appRegular(24))
                    .foregroundColor(.neutralMain700)
                
                Spacer()
            }
            .frame(height: 32)
            .padding(.top, 16)
            .padding(.bottom, 19)
            .padding(.horizontal, 5)
            
            //MARK: Family members list
            if let members = manualVM.listFamilyMembersResponse?.familyMembers, !members.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack(spacing:0) {
                        ForEach(members, id: \.id) { member in
                            FamilyMemberCard(
                                member              : member,
                                isExpanded          : expandedMemberId == member.id,
                                openSwipeCardIndex  : $openSwipeCardIndex,
                                onTap               : {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        if expandedMemberId == member.id {
                                            expandedMemberId = nil
                                        } else {
                                            expandedMemberId = member.id
                                            openSwipeCardIndex = nil // Reset swipes
                                        }
                                    }
                                },
                                editBtn: {
                                    if let countries = commonApiVM.countriesResponse {
                                        selectedCountry = countries.first(where: { $0.dialCode == member.countryCode })
                                    }
                                    editingFamily = EditableFamilyWrapper(data: member)
                                },
                                delBtn : {
                                    deleteFamilyMemberId = member.id ?? ""
                                    showDeletePopup = true
                                },
                                delSubscriptionBtn:{
                                    listFamilyMembersApi()
                                }
                                , addSubscriptionBtn: { id in
                                    if manualVM.listFamilyMembersResponse?.remainingSubscriptionLimit == 0 {
                                        SheetManager.shared.isUpgradeSheetVisible = true
                                    } else {
                                        familyMembersVM.navigate(to: .manualEntry(isFromEdit        : false,
                                                                                  isFromListEdit    : false,
                                                                                  subscriptionId    : "",
                                                                                  familyMemberId    : id))
                                    }
                                }
                            )
                            Divider()
                                .overlay(Color.border)
                        }
                    }
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    .padding(5)
                }
                .cornerRadius(16)
            } else {
                //MARK: Empty view
                VStack(spacing: 24) {
                    Spacer()
                    Image("box_blue")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    VStack(spacing: 16) {
                        Text("No family members yet")
                            .font(.appRegular(24))
                            .foregroundColor(Color.grayClr)
                            .multilineTextAlignment(.center)
                        
                        Text("You haven’t added any family members yet")
                            .font(.appRegular(16))
                            .foregroundColor(Color.grayClr)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
            }
            
            Spacer()
            
            //MARK: Add Family Member Button
                GradientBorderButton(
                    title: "Add Family Member",
                    isBtn: true,
                    buttonImage: "profile_add",
                    action: {
                        if manualVM.listFamilyMembersResponse?.remainingFamilyMembersLimit ?? 0 > 0{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                openFamilyMemberSheet = true
                            }
                        }else{
                            SheetManager.shared.isUpgradeSheetVisible = true
                        }
                        print("Add Family Member tapped")
                    }
                )
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 15)
        .background(Color.neutralBg100)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $openFamilyMemberSheet) {
            AddFamilyMemberBottomSheet(header       : "Add Family Member",
                                       description  : "Add a family member to manage and share plans together.",
                                       buttonName   : "Save",
                                       action       : {nickName, phone, countryCode, colorHex in
                let input = AddFamilyMemberRequest(userId       : Constants.getUserId(),
                                                   nickName     : nickName.trimmed,
                                                   phoneNumber  : phone,
                                                   countryCode  : countryCode,
                                                   color        : colorHex)
                manualVM.addfamilyMember(input: input)
            })
            .id(UUID())
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(600)])
        }
        .sheet(item: $editingFamily) { wrapper in
            AddFamilyMemberBottomSheet(header           : "Edit Family Member",
                                       description      : "",
                                       buttonName       : "Update",
                                       buttonImg        : "update",
                                       selectedCountry  : selectedCountry ?? nil,
                                       phoneNumber      : wrapper.data.phoneNumber ?? "",
                                       nickName         : wrapper.data.nickName ?? "",
                                       selectedColor    : wrapper.data.color ?? "",
                                       isEdit           : true,
                                       action           : {nickName, phone, countryCode, colorHex in
                let input = EditFamilyMemberRequest(familyMemberId        : wrapper.data.id ?? "",
                                                    nickName              : nickName.trimmed,
                                                    phoneNumber           : phone,
                                                    countryCode           : countryCode,
                                                    color                 : colorHex)
                familyMembersVM.editFamilyMember(input: input)
            })
            .id(UUID())
            .presentationDetents([.height(600)])
            .presentationDragIndicator(.hidden)
        }
        .onAppear {
            listFamilyMembersApi()
        }
        .onChange(of: manualVM.isAddFamilyMember) { value in
            if value{
                listFamilyMembersApi()
            }
        }
        .sheet(isPresented: $showDeletePopup) {
            InfoAlertSheet(
                onDelegate: {
                    deleteFamilyMemberApi()
                }, title    : "Are you sure you want to delete this family member?\nAll related subscriptions will be permanently deleted",
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
        .onChange(of: familyMembersVM.isDelete) { value in
            if value == true{
                listFamilyMembersApi()
            }
        }
        .onChange(of: familyMembersVM.isEdit) { value in
            if value == true{
                listFamilyMembersApi()
            }
        }
    }
    
    //MARK: - User defined methods
    func listFamilyMembersApi(){
        manualVM.listFamilyMembers(input: ListFamilyMembersRequest(userId: Constants.getUserId()))
    }
    
    func deleteFamilyMemberApi(){
        familyMembersVM.deleteFamilyMember(input: DeleteFamilyMemberRequest(familyMemberId: deleteFamilyMemberId))
    }
}

#Preview {
    FamilyMembersView()
}

//MARK: - FamilyMemberCard
struct FamilyMemberCard: View {
    let member                              : ListFamilyMembersResponseData
    let isExpanded                          : Bool
    @Binding var openSwipeCardIndex         : Int?
    let onTap                               : () -> Void
    let editBtn                             : () -> Void
    let delBtn                              : () -> Void
    let delSubscriptionBtn                  : () -> Void
    let addSubscriptionBtn                  : (String) -> Void
    @State private var activeCardId         : String? = nil
    @State private var isScrollDisabled     : Bool = false
    @State var showDeletePopup              : Bool = false
    @StateObject var subscriptionsVM        = SubscriptionsViewModel()
    @State var delSubscriptionId            = ""
    @State private var deleteSheetHeight    : CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Collapsed Header
            HStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: member.color ?? "#619BEE"))
                        .frame(width: 48, height: 48)
                    
                    Image("person")
                        .frame(width: 20, height: 20)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(member.nickName ?? "Member")
                        .font(.appRegular(16))
                        .foregroundColor(.neutralMain700)
                    
                    Text(member.phoneNumber ?? "")
                        .font(.appRegular(14))
                        .foregroundColor(.neutral500)
                }
                
                Spacer()
                
                HStack(spacing: 24) {
                    Button {
                        editBtn()
                    } label: {
                        Image("edit_gray")
                    }
                    
                    Button {
                        delBtn()
                    } label: {
                        Image("del_gray")
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            // MARK: - Expanded Content
            if isExpanded {
                VStack(spacing: 0) {
                    if let subs = member.subscriptions, !subs.isEmpty {
                        VStack{
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(Array(subs.enumerated()), id: \.element.id) { index, sub in
                                        SwipeableSubscriptionRow(
                                            sub             : sub,
                                            activeCardId    : $activeCardId,
                                            isScrollDisabled: $isScrollDisabled,
                                            onEdit: {
                                                print("Edit sub: \(sub.serviceName ?? "")")
                                                editSubscription(sub: sub, familyMemberId: member.id ?? "")
                                            },
                                            onDelete: {
                                                print("Delete sub: \(sub.serviceName ?? "")")
                                                delSubscriptionId = sub.id ?? ""
                                                showDeletePopup = true
                                            }
                                        )
                                        if index < subs.count - 1 {
                                            Divider()
                                                .overlay(Color.neutral300Border)
                                        }
                                    }
                                }
                            }
                            .scrollDisabled(isScrollDisabled)
                            //                            .scrollDisabled(subs.count <= 3) // Disable scroll if few items
                        }
                        .frame(maxHeight: 200)
                        .background(.neutralBg100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.neutral300Border, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    
                    //MARK: Add New Subscription Button
                    Button(action: {
                        guard let id = member.id, !id.isEmpty else { return }
                        print("Add New Subscription tapped for \(member.nickName ?? "")")
                        addSubscriptionBtn(id)
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add New")
                                .font(.appRegular(16))
                                .underline()
                        }
                        .foregroundColor(Color.navyBlueCTA700)
                        .padding(.bottom, 16)
                    }
                    
                }
                .background(Color.white)
            }
        }
        .background(Color.white)
        .sheet(isPresented: $showDeletePopup , onDismiss: {
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
        .onChange(of: subscriptionsVM.isDeletedSubscription) { _ in updateDeleteSubscription() }
    }
    
    //MARK: - User defined methods
    func editSubscription(sub: SubscriptionListData, familyMemberId: String){
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
                                                         subscriptionId : sub.id ?? "",
                                                         familyMemberId : familyMemberId))
    }
    
    func deleteSubscription() {
        //        var selectedIDs: [String] {
        //            (member.subscriptions ?? [])
        //                .filter { $0.isSelected == true }
        //                .compactMap { $0.id }
        //        }
        subscriptionsVM.deleteSubscription(input: DeleteSubscriptionRequest(userId: Constants.getUserId(), subscriptionIds: [delSubscriptionId]))
    }
    
    func updateDeleteSubscription(){
        if subscriptionsVM.isDeletedSubscription ?? false{
            delSubscriptionBtn()
        }
    }
}

//MARK: - ColorPickerGrid
struct ColorPickerGrid: View {
    let colors: [String] = [ "#76869E",
                             "#8766CE",
                             "#619BEE",
                             "#9AC473",
                             "#E9D2A1",
                             "#FF5959"]
    @Binding var selectedColor: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack {
                ForEach(colors, id: \.self) { color in
                    Rectangle()
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.safeHex(color))
                        .clipShape(.rect(cornerRadius: 4)) // shorthand for RoundedRectangle(cornerRadius: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(selectedColor == color ? Color.navyBlueCTA700 : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding(.vertical,10)
            .padding(.leading,3)
        }
    }
}

//MARK: - SwipeableSubscriptionRow
struct SwipeableSubscriptionRow: View {
    let sub                     : SubscriptionListData
    @Binding var activeCardId   : String?
    @Binding var isScrollDisabled : Bool
    let onEdit                  : () -> Void
    let onDelete                : () -> Void
    @State private var offset   : CGFloat = 0
    @State private var isSwiped : Bool = false
    let swipeThreshold: CGFloat = -80
    let menuWidth: CGFloat      = 145
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack {
                HStack{
                    VStack(spacing: 8){
                        Image("del_white")
                        Text("Delete")
                            .font(.appSemiBold(14))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 80, height: 74)
            }
            .frame(width: 80, height: 74)
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
            .opacity(offset != 0 || isSwiped ? 1 : 0) // Hide when not swiping
            .onTapGesture {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
                onDelete()
            }
            
            VStack(spacing: 8) {
                Image("edit_white")
                Text("Edit")
                    .font(.appSemiBold(14))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 74)
            .background(Color("green"))
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
            .offset(x: -75)
            .zIndex(0)
            .opacity(offset != 0 || isSwiped ? 1 : 0) // Hide when not swiping
            .onTapGesture {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
                onEdit()
            }
            
            // Top Card Layer
            subscriptionListCardInFamilyMember(
                subscriptionData    : sub,
                isActive            : false
            )
            .background(Color.white)
            .offset(x: offset)
//            .onTapGesture {
//                guard activeCardId == nil else { return }
//                if sub.viewStatus ?? false {
//                    AppIntentRouter.shared.navigate(
//                        to: .subscriptionMatchView(
//                            fromList: true,
//                            subscriptionId: sub.id ?? ""
//                        )
//                    )
//                } else {
//                    SheetManager.shared.isUpgradeSheetVisible = true
//                }
//            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged { value in
                        guard sub.viewStatus != false else { return }
                        guard abs(value.translation.width) > abs(value.translation.height) else {
                            isScrollDisabled = false
                            return
                        }
                        isScrollDisabled = true
                        let containerWidth = -menuWidth
                        var proposedOffset: CGFloat = 0
                        if isSwiped {
                            // Starting from open state (-menuWidth)
                            proposedOffset = containerWidth + value.translation.width
                        } else {
                            // Starting from closed state (0)
                            proposedOffset = value.translation.width
                        }
                        // Strictly clamp the offset
                        self.offset = min(0, max(containerWidth, proposedOffset))
                    }
                    .onEnded { value in
                        isScrollDisabled = false
                        guard sub.viewStatus != false else { return }
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        withAnimation(.spring()) {
                            if value.translation.width < swipeThreshold {
                                self.offset = -menuWidth
                                self.isSwiped = true
                                self.activeCardId = sub.id
                            } else {
                                self.offset = 0
                                self.isSwiped = false
                                if self.activeCardId == sub.id {
                                    self.activeCardId = nil
                                }
                            }
                        }
                    }
            )
            .zIndex(1)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .onChange(of: activeCardId) { newValue in
            if newValue != sub.id && (offset != 0 || isSwiped) {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
            }
        }
    }
}


//struct FamilyMember: Identifiable {
//    var id = UUID()
//    var nickname: String = ""
//    var phoneNumber: String = ""
//    var color: Color
//    var selectedCurrency : Currency?
//}

//struct FamilyMemberView: View {
//    @Binding var member: FamilyMember
//    let action      : () -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 24) {
//            HStack{
//                Text("Family Member 1")
//                    .font(.appRegular(16))
//                    .foregroundColor(Color.neutralMain700)
//                Spacer()
//                Button(action: action) {
//                    Image("cancel")
//                }
//            }
//            Rectangle()
//                .fill(Color.border)
//                .frame(height: 2)
//                .padding(.horizontal,-18)
//                .padding(.top,-8)
//
//            ReusableTextField(placeholder   : "Nickname",
//                              text          : $member.nickname,
//                              header        : "Family Nickname")
//            .padding(.top,-8)
//
////            PhoneNumberField(phoneNumber        : $member.phoneNumber,
////                             header             : "Family Member phone number",
////                             placeholder        : "000 000 000",
////                             selectedCurrency   : $member.selectedCurrency)
//
//            Text("Color (To distinguish color family subscriptions)")
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding(.bottom, -20)
//
//            ColorPickerGrid(selectedColor: $member.color)
//        }
//        .padding(18)
//        .background(.white)
//        .cornerRadius(16)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.border, lineWidth: 1)
//        )
//    }
//}

//#Preview {
//    FamilyMemberView(
//        member: .constant(
//            FamilyMember(
//                nickname: "John Doe",
//                phoneNumber: "9876543210",
//                color: .blue
//            )
//        ), action: { print("Button tapped!") }
//    )
//}
