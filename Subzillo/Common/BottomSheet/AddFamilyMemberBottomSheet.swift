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
    var idVal                             : String?
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
   // let action                            : (String, String, String, String) -> Void
    @StateObject private var toastManager = ToastManager()
    @StateObject var manualVM               = ManualEntryViewModel()
    @StateObject var familyMembersVM        = FamilyMembersViewModel()
    
    //MARK: - body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(LocalizedStringKey(header ?? ""))
                        .font(.geistBold(16))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                }
                
                Spacer()
                
                // MARK: - Empty Space
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal,20)
            .padding(.top, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    Text(LocalizedStringKey(description ?? ""))
                        .font(.jetBrainsBold(11))
                        .foregroundStyle(.textPrimary0E101AF4F1FB.opacity(0.6))
                        .padding(.vertical, 20)
                        .lineSpacing(1.5)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth:.infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        ReusableTextField2(placeholder: "Nickname",
                                         text: $nickName,
                                         header: "Family Nickname")
                            .padding(.top, 10)
                        
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
                                    .font(.jetBrainsMedium(11))
                                    .foregroundColor(.textPrimary0E101AF4F1FB.opacity(0.5))
                                +
                                Text("(To distinguish color family subscriptions)")
                                    .foregroundColor(.textPrimary0E101AF4F1FB.opacity(0.5))
                            )
                            .font(.jetBrainsMedium(11))
                            .textCase(.uppercase)
                            .lineSpacing(1.5)
                            
                            ColorPickerGrid(selectedColor: $selectedColor)
                            // Removed duplicate ColorPickerGrid
                        }
                        .padding(.top, 10)
                        
                        
                        GradientBgButton(
                            title       : buttonName ?? "Save",
                            isSolid     : true,
                            showChevron : false,
                            icon        : "plusicon",
                            iconOnLeft  : false
                        ) {
                            handleSave()
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 24)
            }
        }
        .keyboardAdaptive()
        .applyAppBackground()
        .modifier(ToastModifier(toast: toastManager))
        .onChange(of: manualVM.isAddFamilyMember) { value in
            if value{
                AppIntentRouter.shared.pop()
            }
        }
        .onChange(of: familyMembersVM.isEdit) { value in
            if value == true{
                AppIntentRouter.shared.pop()
            }
        }
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
                toastManager.showToast(message: errorMessage.localized, style: .error)
            } else {
               // action(nickName, phoneNumber, countryCode, colorHex)
                let input = EditFamilyMemberRequest(familyMemberId        : idVal ?? "",
                                                    nickName              : nickName.trimmed,
                                                    phoneNumber           : phoneNumber,
                                                    countryCode           : countryCode,
                                                    color                 : colorHex)
                familyMembersVM.editFamilyMember(input: input)
            }
        } else {
            let input = AddFamilyMemberRequest(userId: Constants.getUserId(),
                                               nickName: nickName.trimmed,
                                               phoneNumber: phoneNumber,
                                               countryCode: countryCode,
                                               color: colorHex)
            if let errorMessage = ProfileValidations.shared.addfamilyMember(input: input) {
                toastManager.showToast(message: errorMessage.localized, style: .error)
            } else {
                //action(nickName, phoneNumber, countryCode, colorHex)
                
                let input = AddFamilyMemberRequest(userId       : Constants.getUserId(),
                                                   nickName     : nickName.trimmed,
                                                   phoneNumber  : phoneNumber,
                                                   countryCode  : countryCode,
                                                   color        : colorHex)
                manualVM.addfamilyMember(input: input)

            }
        }
    }
}
