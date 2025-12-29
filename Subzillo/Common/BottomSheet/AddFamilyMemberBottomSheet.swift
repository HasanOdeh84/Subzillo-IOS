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
    var header                            : String?
    var description                       : String?
    var buttonName                        : String?
    @State var selectedCurrency           : Currency?
    @State var selectedCountry            : Country?
    @State var phoneNumber                : String = ""
    @State var nickName                   : String = ""
    @State var selectedColor              : Color = Color.clear
    let action                            : (String, String, String, String) -> Void
    
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
                .multilineTextAlignment(.center)
            
            Text(LocalizedStringKey(description ?? ""))
                .font(.appRegular(16))
                .foregroundStyle(.grayClr)
                .padding(.top,10)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 24) {
                
                ReusableTextField2(placeholder   : "Nickname",
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
                
                (
                Text("Color ")
                    .font(.caption)
                    .foregroundColor(Color.neutralMain700)
                +
                Text("(To distinguish color family subscriptions)")
                    .foregroundColor(Color.neutral500)
                )
                .font(.caption)
                .padding(.bottom, -20)
                
                ColorPickerGrid(selectedColor: $selectedColor)
                
                GradientBorderButton(title          : buttonName ?? "Save",
                                     isBtn          : true,
                                     buttonImage    : "profile_add") {
                    let countryCode = selectedCountry?.dialCode ?? ""
                    let colorHex    = selectedColor.toHex() ?? "#0000FF"
                    action(nickName, phoneNumber, countryCode, colorHex)
                    dismiss()
                }
            }
            Spacer()
        }
        .padding(24)
    }
}
