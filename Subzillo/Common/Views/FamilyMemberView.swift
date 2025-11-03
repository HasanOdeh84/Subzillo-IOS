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
    var color: Color? = nil
}

struct FamilyMemberView: View {
    @Binding var member: FamilyMember

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ReusableTextField(placeholder: "Nickname", text: $member.nickname)
//            PhoneNumberField(phoneNumber: $member.phoneNumber, selectedCurrency: <#Binding<Currency?>#>)
            Text("Color (To distinguish color family subscriptions)")
                .font(.caption)
                .foregroundColor(.gray)
            ColorPickerGrid(selectedColor: $member.color)
        }
        .padding()
        .background(Color(.systemGray5).opacity(0.7))
        .cornerRadius(12)
    }
}

struct ColorPickerGrid: View {
    let colors: [Color] = [.purple, .blue, .green, .yellow, .red]
    @Binding var selectedColor: Color?

    var body: some View {
        HStack {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle().stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedColor = color
                    }
            }
        }
    }
}

//#Preview {
//    FamilyMemberView()
//}
