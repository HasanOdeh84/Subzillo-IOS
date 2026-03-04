//
//  CategoriesBottomSheet.swift
//  Subzillo
//
//  Created by Ratna Kavya on 11/11/25.
//

import SwiftUI
struct CategoriesBottomSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory           : Category?
    var categoryResponse                    : [Category]?
    var header                              : String?
    var placeholder                         : String?
    @State private var searchText           = ""
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categoryResponse ?? []
        }
        return categoryResponse?.filter {
            $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
        } ?? []
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
            
            if filteredCategories.count != 0{
                VStack(spacing: 0){
                    List(filteredCategories, id: \.self) { category in
                        VStack(spacing: 0) { // no unwanted spacing
                            Button {
                                selectedCategory = category
                                dismiss()
                            } label: {
                                HStack {
                                    Text(LocalizedStringKey(category.name ?? ""))
                                        .font(.appRegular(16))
                                        .foregroundColor(.neutralMain700)
                                        .padding(.horizontal, 14)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain) // remove SwiftUI’s default button padding
                            
                            if category != filteredCategories.last {
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

#Preview {
    CategoriesBottomSheet(selectedCategory: .constant(nil))
}
