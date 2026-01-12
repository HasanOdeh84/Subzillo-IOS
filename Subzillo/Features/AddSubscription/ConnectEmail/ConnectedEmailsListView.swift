//
//  ConnectedEmailsListView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 10/01/26.
//

import SwiftUI

struct ConnectedEmailsListView: View {
    
    //MARK: - Properties
    @StateObject private var viewModel = ConnectedEmailsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var activeEmailId     : UUID? = nil
    @State private var isScrollDisabled : Bool = false
    
    var placeholder: String?
    
    //MARK: - body
    var body: some View {
        VStack(spacing: 19) {
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: goBack) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: - Title
                    Text("Connect Email")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    // MARK: - SubTitle
                    Text("Auto-detect from email")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutral500)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 0)
            .padding(.bottom, 20)

            // MARK: - Search Bar
            HStack {
                Image("search")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
                    .padding(.leading, 16)
                
                TextField(LocalizedStringKey(placeholder ?? "Search Email"), text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.trailing, 10)
                    .foregroundColor(Color.neutralMain700)
            }
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue500, lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // MARK: - Email List
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredEmails) { email in
                        SwipeableEmailRow(
                            email           : email,
                            activeEmailId   : $activeEmailId,
                            isScrollDisabled: $isScrollDisabled,
                            onDelete: {
                                withAnimation {
                                    viewModel.deleteEmail(email)
                                }
                            },
                            onSync: {
                                viewModel.syncEmail(email)
                            },
                            onView: {
                                viewModel.viewEmail(email)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .scrollDisabled(isScrollDisabled)
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .background(Color.neutralBg100)
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
}

#Preview {
    ConnectedEmailsListView()
}
