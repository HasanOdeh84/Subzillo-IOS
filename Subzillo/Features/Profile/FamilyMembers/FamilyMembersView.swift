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
            if let members = manualVM.listFamilyMembersResponse, !members.isEmpty {
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
                                        selectedCountry = countries.first(where: { $0.countryCode == member.countryCode })
                                    }
                                    editingFamily = EditableFamilyWrapper(data: member)
                                },
                                delBtn : {
                                    deleteFamilyMemberId = member.id ?? ""
                                    showDeletePopup = true
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
                    openFamilyMemberSheet = true
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
                                                   nickName     : nickName,
                                                   phoneNumber  : phone,
                                                   countryCode  : countryCode,
                                                   color        : colorHex)
                if let errorMessage = ProfileValidations.shared.addfamilyMember(input: input) {
                    ToastManager.shared.showToast(message: errorMessage,style:ToastStyle.error)
                } else {
                    manualVM.addfamilyMember(input: input)
                }
            })
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(600)])
        }
        .sheet(item: $editingFamily) { wrapper in
            AddFamilyMemberBottomSheet(header           : "Edit Family Member",
                                       description      : "Edit a family member to manage and share plans together.",
                                       buttonName       : "Update",
                                       buttonImg        : "update",
                                       selectedCountry  : selectedCountry ?? nil,
                                       phoneNumber      : wrapper.data.phoneNumber ?? "",
                                       nickName         : wrapper.data.nickName ?? "",
                                       action: {nickName, phone, countryCode, colorHex in
                let input = EditFamilyMemberRequest(familyMemberId       : wrapper.data.id ?? "",
                                                   nickName              : nickName,
                                                   phoneNumber           : phone,
                                                   countryCode           : countryCode,
                                                   color                 : colorHex)
                if let errorMessage = ProfileValidations.shared.editfamilyMember(input: input) {
                    ToastManager.shared.showToast(message: errorMessage,style:ToastStyle.error)
                } else {
                    familyMembersVM.editFamilyMember(input: input)
                }
            })
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
    let member                      : ListFamilyMembersResponseData
    let isExpanded                  : Bool
    @Binding var openSwipeCardIndex : Int?
    let onTap                       : () -> Void
    let editBtn                     : () -> Void
    let delBtn                      : () -> Void
    
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
                    // Subscription List
                    if let subs = member.subscriptions, !subs.isEmpty {
                        // Max height ~3 items (~74pt each) -> ~240pt
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(Array(subs.enumerated()), id: \.element.id) { index, sub in
                                    // Using existing SwipeActionCard
                                    SwipeActionCard(
                                        id: index,
                                        openCardIndex: $openSwipeCardIndex,
                                        selectionMode: false,
                                        onEdit: {
                                            print("Edit sub: \(sub.serviceName ?? "")")
                                        },
                                        onDelete: {
                                            print("Delete sub: \(sub.serviceName ?? "")")
                                        }
                                    ) {
                                        // Using existing subscriptionListCard
                                        subscriptionListCard(
                                            subscriptionData: sub,
                                            isActive: false
                                        )
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 240) // Limit height to ~3 items
                        .scrollDisabled(subs.count <= 3) // Disable scroll if few items
                    }
                    
                    //MARK: Add New Subscription Button
                    Button(action: {
                        print("Add New Subscription tapped for \(member.nickName ?? "")")
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
    }
}
