//
//  AddFamilyMemberBSView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 10/11/25.
//

import Foundation
import SwiftUICore

struct AddFamilyMemberBottomSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    var header                              : String?
    @Binding var selectedCurrency           : Currency?
    @Binding var selectedCountry            : Country?
    @Binding var phoneNumber                : String
    @Binding var nickName                   : String
    @Binding var familyColor                : Color
    let action                              : () -> Void
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
            
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(24))
                .foregroundStyle(.neutralMain700)
                .padding(.top,24)
            
            Text("Sed ex elit scelerisque Nullam turpis viverra")
                .font(.appRegular(16))
                .foregroundStyle(.gray)
                .padding(.top,10)
            
            VStack(alignment: .leading, spacing: 24) {
                
                ReusableTextField(placeholder   : "Nickname",
                                  text          : $nickName,
                                  header        : "Family Nickname")
                .padding(.top,20)
                
                PhoneNumberField(phoneNumber        : $phoneNumber,
                                 header             : "Family Member phone number",
                                 placeholder        : "000 000 000",
                                 selectedCurrency   : $selectedCurrency,
                                 selectedCountry    : $selectedCountry,
                                 isCountry          : true)
                .addDoneButton{
                }
                
                Text("Color (To distinguish color family subscriptions)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, -20)
                
                ColorPickerGrid(selectedColor: $familyColor)
                
                GradientBorderButton(title: "Save",isBtn:true, buttonImage: "profile_add") {
                    ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                    action()
                    dismiss()
                }
            }
            Spacer()
        }
        .padding(24)
    }
}
