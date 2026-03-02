//
//  AddFamilyMemberBSView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 10/11/25.
//

import Foundation
import SwiftUI

struct AddFamilyMemberBottomSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    var header                            : String?
    var description                       : String?
    var buttonName                        : String?
    var buttonImg                         : String? = "profile_add"
    @State var selectedCurrency           : Currency?
    @State var selectedCountry            : Country?
    @State var phoneNumber                : String = ""
    @State var nickName                   : String = ""
    @State var selectedColor              : String = "#76869E"
    @State var isEdit                     = false
    let action                            : (String, String, String, String) -> Void
    @StateObject private var toastManager = ToastManager()
    
    //MARK: - body
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top, 12)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text(LocalizedStringKey(header ?? ""))
                        .font(.appSemiBold(24))
                        .foregroundStyle(.neutralMain700)
                        .padding(.top, 24)
                        .multilineTextAlignment(.center)
                    
                    Text(LocalizedStringKey(description ?? ""))
                        .font(.appRegular(16))
                        .foregroundStyle(.grayClr)
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        ReusableTextField2(placeholder: "Nickname",
                                         text: $nickName,
                                         header: "Family Nickname")
                            .padding(.top, 20)
                        
                        PhoneNumberField(phoneNumber: $phoneNumber,
                                         header: "Family Member phone number",
                                         placeholder: "000 000 000",
                                         selectedCurrency: $selectedCurrency,
                                         selectedCountry: $selectedCountry,
                                         isCountry: true,
                                         fromFamily: true,
                                         countryCode: selectedCountry?.dialCode ?? "")
                            .addDoneButton {}
                        
                        VStack(alignment: .leading, spacing: 12) {
                            (
                                Text("Color ")
                                    .font(.caption)
                                    .foregroundColor(Color.neutralMain700)
                                +
                                Text("(To distinguish color family subscriptions)")
                                    .foregroundColor(Color.neutral500)
                            )
                            .font(.caption)
                            
                            ColorPickerGrid(selectedColor: $selectedColor)
                            // Removed duplicate ColorPickerGrid
                        }
                        
                        GradientBorderButton(title: buttonName ?? "Save",
                                           isBtn: true,
                                           buttonImage: buttonImg) {
                            handleSave()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .modifier(ToastModifier(toast: toastManager))
    }
    
    private func handleSave() {
        let countryCode = selectedCountry?.dialCode ?? ""
        let colorHex = selectedColor
        
        if isEdit {
            let input = EditFamilyMemberRequest(familyMemberId: "",
                                                nickName: nickName.trimmed,
                                                phoneNumber: phoneNumber,
                                                countryCode: countryCode,
                                                color: colorHex)
            if let errorMessage = ProfileValidations.shared.editfamilyMember(input: input) {
                toastManager.showToast(message: errorMessage, style: .error)
            } else {
                action(nickName, phoneNumber, countryCode, colorHex)
                dismiss()
            }
        } else {
            let input = AddFamilyMemberRequest(userId: Constants.getUserId(),
                                               nickName: nickName.trimmed,
                                               phoneNumber: phoneNumber,
                                               countryCode: countryCode,
                                               color: colorHex)
            if let errorMessage = ProfileValidations.shared.addfamilyMember(input: input) {
                toastManager.showToast(message: errorMessage, style: .error)
            } else {
                action(nickName, phoneNumber, countryCode, colorHex)
                dismiss()
            }
        }
    }
}
