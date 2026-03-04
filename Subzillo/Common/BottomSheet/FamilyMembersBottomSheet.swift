import SwiftUI

struct FamilyMembersBottomSheet: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMembers    : [ListFamilyMembersResponseData]
    var members                     : [ListFamilyMembersResponseData]
    @State private var searchText   = ""
    @State private var contentHeight: CGFloat = .zero
    
    var filteredMembers: [ListFamilyMembersResponseData] {
        if searchText.isEmpty {
            return members
        }
        return members.filter {
            ($0.nickName ?? "")
                .localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            // Drag Indicator
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top, 24)
            
            ScrollView(showsIndicators: false) {
                // Header
                Text("Select Family Members")
                    .font(.appRegular(24))
                    .foregroundColor(.neutralMain700)
                    .padding(.vertical, 24)
                
                // Search Bar
                HStack {
                    Image("search")
                        .frame(width: 20, height: 20)
                        .padding(.leading, 16)
                    
                    TextField(LocalizedStringKey("Search Member"), text: $searchText)
                        .textFieldStyle(.plain)
                        .padding(.trailing, 10)
                }
                .frame(height: 52)
                .background(.neutralBg100)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue500, lineWidth: 1)
                )
                .padding(.horizontal, 24)
                
                // List
                if !filteredMembers.isEmpty {
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredMembers, id: \.self) { member in
                                Button {
                                    toggleSelection(member)
                                } label: {
                                    HStack(spacing: 14) {
                                        
                                        Image(
                                            isSelected(member)
                                            ? "Checkmark"
                                            : "UnCheckmark"
                                        )
                                        
                                        Text(LocalizedStringKey(member.nickName ?? ""))
                                            .font(.appRegular(16))
                                            .foregroundColor(.neutralMain700)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                    .frame(maxWidth: .infinity, minHeight: 56)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                if member.id != filteredMembers.last?.id {
                                    Rectangle()
                                        .fill(Color.neutralDisabled200)
                                        .frame(height: 1)
                                        .padding(.horizontal, -20)
                                }
                            }
                        }
                        .background(.clear)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neutral300Border, lineWidth: 1)
                        )
                        .padding(24)
                    }
                    //                .frame(height: min(contentHeight + 100, 400)) // Dynamic height with max limit
                    
                } else {
                    Text("No data found")
                        .font(.appRegular(16))
                        .foregroundColor(.gray)
                        .padding(30)
                    
                    Spacer()
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Ok")
                        .font(.appSemiBold(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.blueMain700)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
//            .background(
//                GeometryReader { geo in
//                    Color.clear
//                        .onAppear {
//                            contentHeight = geo.size.height
//                        }
//                        .onChange(of: geo.size.height) { newHeight in
//                            contentHeight = newHeight
//                        }
//                }
//            )
        }
//        .frame(height: min(contentHeight + 50, UIScreen.main.bounds.height - 60)) // Dynamic height with max limit
        //        .fixedSize(horizontal: false, vertical: true)
    }
    
    // MARK: - Selection Logic
    private func toggleSelection(_ member: ListFamilyMembersResponseData) {
        if let index = selectedMembers.firstIndex(where: { $0.id == member.id }) {
            selectedMembers.remove(at: index)
        } else {
            selectedMembers.append(member)
        }
    }
    
    private func isSelected(_ member: ListFamilyMembersResponseData) -> Bool {
        selectedMembers.contains(where: { $0.id == member.id })
    }
}
