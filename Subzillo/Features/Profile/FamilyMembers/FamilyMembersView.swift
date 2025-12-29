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

            //MARK: Family members list
            if let members = manualVM.listFamilyMembersResponse, !members.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
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
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
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
        .padding(.horizontal, 20)
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
        .onAppear {
            listFamilyMembers()
        }
        .onChange(of: manualVM.isAddFamilyMember) { value in
            if value{
                listFamilyMembers()
            }
        }
    }
    
    func listFamilyMembers(){
        manualVM.listFamilyMembers(input: ListFamilyMembersRequest(userId: Constants.getUserId()))
    }
}

#Preview {
    FamilyMembersView()
}

// Sub-view for the Card
struct FamilyMemberCard: View {
    let member                      : ListFamilyMembersResponseData
    let isExpanded                  : Bool
    @Binding var openSwipeCardIndex : Int?
    let onTap                       : () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Collapsed Header
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: member.color ?? "#619BEE"))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "person") // Replace with asset/Initials
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(member.nickName ?? "Member")
                        .font(.appBold(16))
                        .foregroundColor(.neutralMain700)
                    
                    Text(member.phoneNumber ?? "")
                        .font(.appRegular(12))
                        .foregroundColor(.grayText)
                }
                
                Spacer()
                
                // Collapsed Actions (Edit/Delete icons visible when closed)
                if !isExpanded {
                    HStack(spacing: 12) {
                        Button {
                            // Edit Action
                        } label: {
                            Image("edit_gray") // Replace with your asset
                        }
                        
                        Button {
                            // Delete Action
                        } label: {
                            Image("delete_gray") // Replace with your asset
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .contentShape(Rectangle()) // Make full row tappable
            .onTapGesture {
                onTap()
            }
            
            // MARK: - Expanded Content
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)
                
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
                                    
                                    // Separator logic
                                    if index < subs.count - 1 {
                                        Divider()
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 240) // Limit height to ~3 items
                        .scrollDisabled(subs.count <= 3) // Disable scroll if few items
                    } else {
                        // No Subscriptions Empty State
                        Text("No subscriptions assigned")
                            .font(.appRegular(14))
                            .foregroundColor(.gray)
                            .padding(24)
                    }
                    
                    Divider()
                    
                    // Add New Subscription Button
                    Button(action: {
                        print("Add New Subscription tapped for \(member.nickName ?? "")")
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add New")
                                .font(.appRegular(14))
                                .underline()
                        }
                        .foregroundColor(Color.navyBlueCTA700)
                        .padding(.vertical, 16)
                    }
                }
                .background(Color.white)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        // Border
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
    }
}
