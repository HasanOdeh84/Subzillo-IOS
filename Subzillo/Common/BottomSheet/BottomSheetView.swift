//
//  BottomSheetView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 03/11/25.
//

import SwiftUI

struct BottomSheetView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    var header                              : String?
    @Binding var selectedCurrency           : Currency?
    @Binding var selectedCountry            : Country?
    @Binding var phoneNumber                : String
    
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
            
            PhoneNumberField(phoneNumber        : $phoneNumber,
                             header             : "Enter your phone number",
                             placeholder        : "000 000 000",
                             selectedCurrency   : $selectedCurrency,
                             selectedCountry    : $selectedCountry,
                             isCountry          : true)
            .padding(.vertical,36)
            
            GradientBorderButton(title: "Update",isBtn:true, buttonImage: "update") {
                Constants.FeatureConfig.performS4Action {
                }
                dismiss()
            }
            Spacer()
        }
        .padding(24)
    }
}
