//
//  PlanTypeBottomSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 02/01/26.
//

import SwiftUI

struct PlanTypeBottomSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPlanType           : String?
    var planTypeResponse                    : [String]?
    var header                              : String?
    var placeholder                         : String?
    @State private var searchText           = ""
    
    var filteredPlanTypes: [String] {
        if searchText.isEmpty {
            return planTypeResponse ?? []
        }
        return planTypeResponse?.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        } ?? []
    }
    
    let action                          : () -> Void
    @State private var contentHeight    : CGFloat = .zero
    
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
                .padding(.vertical,24)
            
            HStack {
                Image("search")
                    .frame(width: 20,height: 20)
                    .foregroundColor(.gray)
                    .padding(.leading,16)
                TextField(LocalizedStringKey(placeholder ?? ""), text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.trailing,10)
                    .foregroundColor(.whiteBlackBGnoPic)
            }
            .frame(height: 52)
            .background(.neutralBg100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue500, lineWidth: 1)
            )
            .padding(.horizontal,24)
            
            if filteredPlanTypes.count != 0{
                //                VStack(spacing: 0){
                //                    List(filteredPlanTypes, id: \.self) { planType in
                //                        VStack(spacing: 0) { // no unwanted spacing
                //                            Button {
                //                                selectedPlanType = planType
                //                                action()
                //                                dismiss()
                //                            } label: {
                //                                HStack {
                //                                    Text(planType)
                //                                        .font(.appRegular(16))
                //                                        .foregroundColor(.neutralMain700)
                //                                        .padding(.horizontal, 14)
                //                                        .frame(maxWidth: .infinity, alignment: .leading)
                //                                }
                //                                .frame(maxWidth: .infinity, minHeight: 56)
                //                                .contentShape(Rectangle())
                //                            }
                //                            .buttonStyle(.plain) // remove SwiftUI’s default button padding
                //
                //                            if planType != filteredPlanTypes.last {
                //                                Rectangle()
                //                                    .fill(Color.neutralDisabled200)
                //                                    .frame(height: 1)
                //                                    .padding(.horizontal, -20)
                //                            }
                //                        }
                //                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // remove default list padding
                //                        .listRowSeparator(.hidden)
                //                    }
                //                    .listStyle(.plain)
                //                }
                ScrollView{
                    VStack(spacing: 0) {
                        ForEach(filteredPlanTypes, id: \.self) { planType in
                            Button {
                                selectedPlanType = planType
                                action()
                                dismiss()
                            } label: {
                                HStack {
                                    Text(LocalizedStringKey(planType))
                                        .font(.appRegular(16))
                                        .foregroundColor(.neutralMain700)
                                        .padding(.horizontal, 14)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            if planType != filteredPlanTypes.last {
                                Rectangle()
                                    .fill(Color.neutralDisabled200)
                                    .frame(height: 1)
                            }
                        }
                    }
//                    .background(
//                        GeometryReader { geo in
//                            Color.clear
//                                .onAppear {
//                                    contentHeight = geo.size.height
//                                }
//                                .onChange(of: geo.size.height) { newHeight in
//                                    contentHeight = newHeight
//                                }
//                        }
//                    )
                    .background(.clear)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    .padding(24)
                }
            }else{
                Text("No data found")
                    .padding(30)
                    .foregroundStyle(Color.gray)
                    .font(.appRegular(16))
                Spacer()
            }
            //            Spacer()
        }
//        .frame(height: min(contentHeight + 200, UIScreen.main.bounds.height - 60)) // Dynamic height with max limit
//        .frame(minHeight: contentHeight + 200, maxHeight: min(contentHeight + 220, UIScreen.main.bounds.height - 60))
        .background(Color.neutralBg100.ignoresSafeArea(.all, edges: .all))
    }
}
