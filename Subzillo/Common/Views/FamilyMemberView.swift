//
//  FamilyMemberView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 03/11/25.
//

import SwiftUI

struct FamilyMember: Identifiable {
    var id = UUID()
    var nickname: String = ""
    var phoneNumber: String = ""
    var color: Color
    var selectedCurrency : Currency?
}

struct FamilyMemberView: View {
    @Binding var member: FamilyMember
    let action      : () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack{
                Text("Family Member 1")
                    .font(.appRegular(16))
                    .foregroundColor(.appNeutralMain700)
                Spacer()
                Button(action: action) {
                    Image("cancel")
                }
            }
            Rectangle()
                .fill(Color.border)
                .frame(height: 2)
                .padding(.horizontal,-18)
                .padding(.top,-8)
            
            ReusableTextField(placeholder   : "Nickname",
                              text          : $member.nickname,
                              header        : "Family Nickname")
            .padding(.top,-8)
            
//            PhoneNumberField(phoneNumber        : $member.phoneNumber,
//                             header             : "Family Member phone number",
//                             placeholder        : "000 000 000",
//                             selectedCurrency   : $member.selectedCurrency)
            
            Text("Color (To distinguish color family subscriptions)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, -20)
            
            ColorPickerGrid(selectedColor: $member.color)
        }
        .padding(18)
        .background(.appBlackWhite)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct ColorPickerGrid: View {
    let colors: [Color] = [.neutral500, .purple500, .blue600, .green, .orange, .red]
    @Binding var selectedColor: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack {
                ForEach(colors, id: \.self) { color in
                    Rectangle()
                        .frame(width: 45, height: 48)
                        .foregroundStyle(color)
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

#Preview {
    FamilyMemberView(
        member: .constant(
            FamilyMember(
                nickname: "John Doe",
                phoneNumber: "9876543210",
                color: .blue
            )
        ), action: { print("Button tapped!") }
    )
}
