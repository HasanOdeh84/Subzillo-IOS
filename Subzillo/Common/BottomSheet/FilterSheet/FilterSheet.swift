//
//  FilterSheet.swift
//  Subzillo
//
//  Created by Ratna Kavya on 18/11/25.
//

import SwiftUI

struct FilterSheet: View {
    
    //MARK: - Properties
    var onDelegate: ((FilterModel) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State var filterData   : FilterModel = FilterModel()
    @State var isClear      = false
    
    //MARK: - body
    var body: some View {
        VStack {
            ZStack{
                Capsule()
                    .fill(Color.grayCapsule)
                    .frame(width: 150, height: 5)
                    .padding(.vertical, 24)
                    .frame(alignment: .center)
                
                if !(filterData.includeFamilySubscriptions == false && filterData.includeExpiredSubscriptions == false && filterData.costOrder == .none && filterData.renewalDateOrder == .none){
                    HStack{
                        Spacer()
                        Button{
                            filterData      = FilterModel(includeFamilySubscriptions : false,
                                                          includeExpiredSubscriptions: false,
                                                          costOrder                  : .none,
                                                          renewalDateOrder           : .none)
                            isClear = true
                        }label: {
                            HStack{
                                Text("Clear")
                                    .font(.appSemiBold(18))
                                    .foregroundColor(.navyBlueCTA700)
                                Image("discardIcon")
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        filterData.includeFamilySubscriptions.toggle()
                    } label: {
                        HStack(spacing: 14) {
                            Image(filterData.includeFamilySubscriptions == true ? "Checkmark" : "UnCheckmark")
                            Text("Include family subscriptions")
                                .font(.appRegular(16))
                                .foregroundColor(.neutralMain700)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 24)
                    }
                    Button {
                        filterData.includeExpiredSubscriptions.toggle()
                    } label: {
                        HStack(spacing: 14) {
                            Image(filterData.includeExpiredSubscriptions == true ? "Checkmark" : "UnCheckmark")
                            Text("Include Expired subscriptions")
                                .font(.appRegular(16))
                                .foregroundColor(.neutralMain700)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 24)
                    }
                }
                DashedHorizontalDivider(dash: [3,3])
                
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        filterData.costOrder = .desc
                    } label: {
                        HStack(spacing: 14) {
                            Image(filterData.costOrder == .desc ? "SelectedRadio" : "UnSelectedRadio")
                            Text("Descending order by cost")
                                .font(.appRegular(16))
                                .foregroundColor(.neutralMain700)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 24)
                    }
                    Button {
                        filterData.costOrder = .asc
                    } label: {
                        HStack(spacing: 14) {
                            Image(filterData.costOrder == .asc ? "SelectedRadio" : "UnSelectedRadio")
                            Text("Ascending order by cost")
                                .font(.appRegular(16))
                                .foregroundColor(.neutralMain700)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 24)
                    }
                }
                DashedHorizontalDivider(dash: [3,3])
                
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        filterData.renewalDateOrder = .desc
                    } label: {
                        HStack(spacing: 14) {
                            Image(filterData.renewalDateOrder == .desc ? "SelectedRadio" : "UnSelectedRadio")
                            Text("Descending order by renewal date")
                                .font(.appRegular(16))
                                .foregroundColor(.neutralMain700)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 24)
                    }
                    Button {
                        filterData.renewalDateOrder = .asc
                    } label: {
                        HStack(spacing: 14) {
                            Image(filterData.renewalDateOrder == .asc ? "SelectedRadio" : "UnSelectedRadio")
                            Text("Ascending order by renewal date")
                                .font(.appRegular(16))
                                .foregroundColor(.neutralMain700)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 24)
                    }
                }
            }
            .padding(.bottom, 24)
            
            CustomButton(title: "Apply", action: onApplyAction)
        }
        .padding(.horizontal, 40)
    }
    
    //MARK: - Button actions
    private func onApplyAction() {
        if isClear{
            filterData = FilterModel(includeFamilySubscriptions : false,
                                     includeExpiredSubscriptions: false,
                                     costOrder                  : .none,
                                     renewalDateOrder           : .none)
        }
        onDelegate?(filterData)
        dismiss()
    }
}

//MARK: - SheetHeaderView
struct SheetHeaderView: View {
    var clearAction: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 5)
            
            HStack {
                Spacer()
                Button(action: clearAction) {
                    HStack(spacing: 4) {
                        Text("Clear")
                            .foregroundColor(.blue)
                            .font(.system(size: 16, weight: .medium))
                        
                        Image(systemName: "xmark")
                            .foregroundColor(.blue)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
            }
        }
    }
}
