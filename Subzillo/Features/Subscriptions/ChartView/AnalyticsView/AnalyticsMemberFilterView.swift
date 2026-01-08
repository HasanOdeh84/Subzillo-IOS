
import SwiftUI

struct AnalyticsMemberFilterView: View {
    let members = ["All", "Me", "Wife", "Fatemah", "Son", "Harry"]
    @State private var selectedMember = "All"
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(members, id: \.self) { member in
                    Button {
                        withAnimation {
                            selectedMember = member
                        }
                    } label: {
                        Text(member)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .foregroundColor(selectedMember == member ? .white : .blueMain700)
                            .background(
                                Capsule()
                                    .fill(selectedMember == member ? Color.blueMain700 : Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.neutral300Border, lineWidth: selectedMember == member ? 0 : 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
