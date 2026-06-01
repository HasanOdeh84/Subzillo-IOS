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
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager     : ThemeManager
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
    @State private var deleteSheetHeight    : CGFloat = .zero
    struct EditableFamilyWrapper: Identifiable {
        let id = UUID()
        let data: ListFamilyMembersResponseData
    }
    @EnvironmentObject private var commonVM : CommonAPIViewModel
    
    //MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                
                Spacer()
                
                Text("Family members")
                    .font(.geistSemiBold(16))
                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                
                Spacer()
                
                Spacer().frame(width: 44)
            }
            .padding(.top, 60)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // MARK: - Family Plan Card & Members List inside ScrollView
            ScrollView(showsIndicators: false) {
                // Family Plan Card
                let remaining = manualVM.listFamilyMembersResponse?.remainingFamilyMembersLimit ?? 5
                let usedSeats = 5 - remaining
                
                VStack(spacing: 8) {
                    Text("FAMILY PLAN")
                        .font(.jetBrainsMedium(11))
                        .tracking(2)
                        .foregroundColor(themeManager.accentTextColor)
                    
                    Text("\(max(0, usedSeats))/5 seats")
                        .font(.geistSemiBold(26))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    
                    Text("Share subscriptions and savings")
                        .font(.geistRegular(12))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .padding(.bottom, 8)
                    
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(themeManager.textPrimaryLight14_white14)
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(themeManager.accentGradient)
                                .frame(width: geo.size.width * CGFloat(min(5, max(0, usedSeats))) / 5, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient.brandFromDark0133_brandToDark0133)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.accentTextColor.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // MARK: - Members List Title
                HStack {
                    Text("MEMBERS")
                        .font(.jetBrainsMedium(11))
                        .tracking(2)
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                LazyVStack(spacing: 12) {
                    // MARK: - Self Card (Owner)
                    FamilyMemberCard(
                        member      : ListFamilyMembersResponseData(
                            id              : "self",
                            nickName        : commonVM.userInfoResponse?.fullName ?? "",
                            phoneNumber     : "",
                            countryCode     : "",
                            color           : "#A719DD",
                            subscriptions   : nil,
                            tag             : "YOU",
                            role            : "Owner"
                        ),
                        isSelfCard  : true,
                        editBtn     : {}
                    )
                    
                    if let members = manualVM.listFamilyMembersResponse?.familyMembers, !members.isEmpty {
                        ForEach(members, id: \.id) { member in
                            FamilyMemberCard(
                                member: member,
                                isSelfCard: false,
                                editBtn: {
                                    if let countries = commonApiVM.countriesResponse {
                                        selectedCountry = countries.first(where: { $0.dialCode == member.countryCode })
                                    }
                                    editingFamily = EditableFamilyWrapper(data: member)
                                    AppIntentRouter.shared.navigate(to:
                                            .addFamilyMemberBottomSheet(idVal            : editingFamily?.data.id ?? "",
                                                                        header           : "Edit family member",
                                                                        description      : "",
                                                                        buttonName       : "Update",
                                                                        buttonImg        : "update",
                                                                        selectedCountry  : selectedCountry ?? nil,
                                                                        phoneNumber      : editingFamily?.data.phoneNumber ?? "",
                                                                        nickName         : editingFamily?.data.nickName ?? "",
                                                                        selectedColor    : editingFamily?.data.color ?? "",
                                                                        isEdit           : true)
                                    )
                                }
                            ) {
                                deleteFamilyMemberId = member.id ?? ""
                                showDeletePopup = true
                            }
                        }
                    }
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, manualVM.listFamilyMembersResponse?.remainingFamilyMembersLimit ?? 5 == 0 ? 120 : 0)
            }
            
            Spacer(minLength: 0)
            
            // MARK: - Invite Member Button
//            let remaining = manualVM.listFamilyMembersResponse?.remainingFamilyMembersLimit ?? 5
            if manualVM.listFamilyMembersResponse?.remainingFamilyMembersLimit ?? 5 != 0 {
                VStack {
                    CustomBorderButton(
                        title       : "Invite member",
                        background  : themeManager.white_white4,
                        borderColor : themeManager.textPrimaryLight8_white8,
                        textColor   : Color("TextPrimary_ 0E101A_F4F1FB"),
                        font        : .geistSemiBold(15),
                        height      : 48,
                        showIcon    : true,
                        icon        : "plus_new",
                        iconOnLeft  : true,
                        action      : {
                            //                        let remaining = manualVM.listFamilyMembersResponse?.remainingFamilyMembersLimit ?? 5
                            //                        if remaining == 0 {
                            //                            SheetManager.shared.isFamilyMemberLimitSheetVisible = true
                            //                        } else {
                            // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // openFamilyMemberSheet = true
                            
                            AppIntentRouter.shared.navigate(to: .addFamilyMemberBottomSheet(header: "Add family member", description: "Add a family member to manage and share plans together.", buttonName: "Save", selectedCountry: nil))
                            
                            // }
                            //                        }
                        }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
                .padding(.top, 10)
            }
        }
        .applyAppBackground()
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        /*.sheet(isPresented: $openFamilyMemberSheet) {
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
        }*/
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
                }, title                : "Are you sure you want to delete this family member?",
                subTitle                : "All related subscriptions will be permanently deleted",
                imageName               : "del_red_new",
                buttonIcon              : "del_red_newSmall",
                buttonTitle             : "Delete",
                imageSize               : 70,
                isCancelButtonVisible   : true,
                isImageVisible          : true
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
    var isSelfCard                          : Bool = false
    let editBtn                             : () -> Void
    var delBtn                              : () -> Void = {}
    @EnvironmentObject var themeManager     : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Initial circle
            ZStack {
                Rectangle()
                    .fill(Color(hex: member.color ?? "#619BEE"))
                    .frame(width: 44, height: 44)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y:4)
                
                Text(getInitials(name: member.nickName ?? "M"))
                    .font(.geistSemiBold(15))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(member.nickName ?? "Member")
                        .font(.geistSemiBold(14))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    
                    if let tag = member.tag, !tag.isEmpty {
                        Text(tag)
                            .font(.jetBrainsMedium(9))
                            .foregroundColor(themeManager.accentTextColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(themeManager.accentTextColor.opacity(0.133))
                            .cornerRadius(4)
                            .tracking(1)
                            .textCase(.uppercase)
//                            .clipShape(Capsule())
                    }
                }
                
//                Text(member.role ?? "Member")
//                    .font(.jetBrainsMedium(11))
//                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
            }
            
            Spacer()
            
            if !isSelfCard {
                HStack(spacing: 8){
                    Button {
                        editBtn()
                    } label: {
                        Image("edit_new")
                            .renderingMode(.template)
                            .foregroundStyle(themeManager.textPrimaryLight6_dark62)
                            .frame(width: 32, height: 32)
                            .background(.calenderF1F2F7FFFFFF)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(themeManager.textPrimaryLight8_white8)
                            )
                    }
                    
                    Button {
                        delBtn()
                    } label: {
                        Image("del_gray")
                            .renderingMode(.template)
                            .foregroundStyle(themeManager.textPrimaryLight6_dark62)
                            .frame(width: 32, height: 32)
                            .background(.calenderF1F2F7FFFFFF)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(themeManager.textPrimaryLight8_white8)
                            )
                    }
                }
            }
        }
        .padding(16)
        .background(themeManager.white_white4)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.textPrimaryLight8_white8)
        )
//        .shadow(color: Color.black.opacity(colorScheme == .light ? 0.05 : 0.02), radius: 10, x: 0, y: 5)
    }
    
    func getInitials(name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count > 1 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return "\(name.prefix(2))".uppercased()
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
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 8) {
                ForEach(colors, id: \.self) { color in
                    ZStack {
                        Rectangle()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(Color.safeHex(color))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        selectedColor == color
                                        ? themeManager.selectedAccent.senColor
                                        : Color.clear,
                                        lineWidth: 2
                                    )
                            )

                        if selectedColor == color {
                            Image("selected")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    }
                    .onTapGesture {
                        selectedColor = color
                    }
                }
            }
            .padding(.vertical,5)
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
