//
//  BillingCycleBottomSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 03/12/25.
//

import SwiftUI

struct BillingCycleBottomSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedBilling            : ManualDataInfo?
    var header                              : String?
    var placeholder                         : String?
    @State private var searchText           = ""
    
    @State private var billingData = [
        ManualDataInfo(id: "1", title: "Daily", subtitle: "Every 24 hours"),
        ManualDataInfo(id: "2", title: "Weekly", subtitle: "Every 7 Days"),
        ManualDataInfo(id: "3", title: "Monthly", subtitle: "Every 30 Days"),
        ManualDataInfo(id: "4", title: "Quarterly", subtitle: "Every 90 Days"),
        ManualDataInfo(id: "5", title: "Biannually", subtitle: "Every 180 Days"),
        ManualDataInfo(id: "6", title: "Yearly", subtitle: "Every 360 Days")
    ]
    
    var filteredCategories: [ManualDataInfo] {
        if searchText.isEmpty {
            return billingData
        }
        return billingData.filter {
            $0.title?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top, 24)
            
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(24))
                .foregroundColor(.neutralMain700)
                .padding(.top,24)
            
//            HStack {
//                Image("search")
//                    .frame(width: 20,height: 20)
//                    .foregroundColor(.gray)
//                    .padding(.leading,16)
//                TextField(LocalizedStringKey(placeholder ?? ""), text: $searchText)
//                    .textFieldStyle(PlainTextFieldStyle())
//                    .padding(.trailing,10)
//                    .foregroundColor(.whiteBlackBGnoPic)
//            }
//            .frame(height: 52)
//            .background(.neutralBg100)
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.blue500, lineWidth: 1)
//            )
//            .padding(.horizontal,24)
            
            if filteredCategories.count != 0{
                VStack(spacing: 0){
                    List(filteredCategories, id: \.self) { billing in
                        VStack(spacing: 0) { // no unwanted spacing
                            Button {
                                selectedBilling = billing
                                dismiss()
                            } label: {
                                HStack {
                                    Text(billing.title ?? "")
                                        .font(.appRegular(16))
                                        .foregroundColor(.neutralMain700)
                                        .padding(.horizontal, 14)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain) // remove SwiftUI’s default button padding
                            
                            if billing != filteredCategories.last {
                                Rectangle()
                                    .fill(Color.neutralDisabled200)
                                    .frame(height: 1)
                                    .padding(.horizontal, -20)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // remove default list padding
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
                .background(.clear)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neutral300Border, lineWidth: 1)
                )
                .padding(24)
            }else{
                Text("No data found")
                    .padding(30)
                    .foregroundStyle(Color.gray)
                    .font(.appRegular(16))
                Spacer()
            }
        }
    }
}
