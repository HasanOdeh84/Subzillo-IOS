//
//  ConnectedEmailsListView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 10/01/26.
//

import SwiftUI

/*
 1. Mails connection using oauth url
 2. Once the mails are connected, we can see those emails with sync status, we will get status for the sync, syncing and view from list api.
 3. Need to add the logos for the mails based on the status(gmail, microsoft, yahoo) from the connected emails list api.
 4. When we click on the view button, if we don't get any subscription data after syncing the mail then need to show the no subscription bottom sheet then backend will change the view status to sync status.
 5. If we discard all the subsriptions or save all or discard some and save some also, backend will change the view status to sync status. We will have discard api.
 6. Once the mail sync is successed then we will get the push notification, if we click on that we need to naviagate connected emails list screen.
 7. No original content.
 8. Delete should be hidden when email is syncing.
 */

struct ConnectedEmailsListView: View {
    
    //MARK: - Properties
    @StateObject private var viewModel      = ConnectedEmailsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var activeEmailId        : String? = nil
    @State private var isScrollDisabled     : Bool = false
    @State var isIntegrations               : Bool = false
    @State var showDeletePopup              : Bool = false
    @State var selectedEmail                : ListConnectedEmailsData?
    var placeholder                         : String?
    @State private var justAppeared         : Bool = false
    @State private var deleteSheetHeight    : CGFloat = .zero
    
    //MARK: - body
    var body: some View {
        VStack(spacing: 19) {
            // MARK: Header
            HStack(spacing: 8) {
                // MARK: back
                Button(action: goBack) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: Title
                    Text(isIntegrations ? "Integrations" : "Connected Email")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, isIntegrations ? 0 : 20)
                    
                    // MARK: SubTitle
                    if !isIntegrations{
                        Text("Auto-detect from email")
                            .font(.appRegular(18))
                            .foregroundColor(Color.neutral500)
                    }
                }
                Spacer()
                
                if isIntegrations{
                    Button(action: onAddAction) {
                        Text("Add")
                            .font(.appRegular(14))
                            .foregroundColor(.white)
                            .frame(width: 62, height: 27)
                            .background(Color.navyBlueCTA700)
                            .cornerRadius(5)
                    }
                }
                
            }
            .padding(.horizontal, 24)
            .padding(.top, isIntegrations ? 16 : 0)
            //            .padding(.bottom, 19)
            
            if viewModel.connectedEmails.count != 0{
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
                //            .padding(.bottom, 19)
            }
            
            if viewModel.filteredEmails.count != 0{
                
                // MARK: Email List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredEmails) { email in
                            //                        SwipeableEmailRow(
                            //                            email           : email,
                            //                            activeEmailId   : $activeEmailId,
                            //                            isScrollDisabled: $isScrollDisabled,
                            //                            onDelete: {
                            //                                withAnimation {
                            //                                    viewModel.deleteEmail(email)
                            //                                }
                            //                            },
                            //                            onSync: {
                            //                                viewModel.syncEmail(email)
                            //                            },
                            //                            onView: {
                            //                                viewModel.viewEmail(email)
                            //                            }
                            //                        )
                            SwipeableMailRow(email              : email,
                                             activeCardId       : $activeEmailId,
                                             isScrollDisabled   : $isScrollDisabled,
                                             onDelete           : {
                                selectedEmail = email
                                showDeletePopup = true
                            },              onSync   : {
                                viewModel.syncEmail(email)
                            },              onView   : {
                                viewModel.viewEmail(email)
                            }, isIntegrations: isIntegrations)
                        }
                    }
                    .padding(.top, 5)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .scrollDisabled(isScrollDisabled)
            }else{
                if viewModel.searchText == ""{
                    Spacer()
                    VStack(){
                        Image("noEmails")
                            .frame(width: 100, height: 100, alignment: .center)
                        Text("No emails Added Yet")
                            .padding(10)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.neutral800)
                            .font(.appBold(16))
                        
                        Text("Add a email to manage your subscriptions and payments easily.")
                            .padding(.horizontal, 10)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.grayText)
                            .font(.appRegular(16))
                    }
                    Spacer()
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .background(Color.neutralBg100)
        //MARK: OnAppear
        .onAppear{
            justAppeared = true
            listConnectedMailsApi()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                justAppeared = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshScreenData"))) { _ in
            if !justAppeared {
                listConnectedMailsApi()
            }
        }
        //MARK: No subscriptions found sheet
        .sheet(isPresented: $viewModel.showErrorPopup, onDismiss: {
            viewModel.listConnectedEmails(input: ListConnectedEmailsRequest(userId: Constants.getUserId()))
        }) {
            UploadErrorImageSheet(
                isImage     : false,
                onDelegate  : {
                },
                onDismiss   : {
                }
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(500)])
        }
        .sheet(isPresented: $showDeletePopup) {
            InfoAlertSheet(
                onDelegate: {
                    deleteEmailAction()
                }, title    : "Are you sure you want to delete the mail \(selectedEmail?.email ?? "")",
                subTitle    :"",
                imageName   : "del_red_big",
                buttonIcon  : "deleteIcon",
                buttonTitle : "Delete",
                imageSize   : 70
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
    }
    
    //MARK: - User defined methods
    func listConnectedMailsApi() {
        viewModel.listConnectedEmails(input: ListConnectedEmailsRequest(userId: Constants.getUserId()))
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
    
    private func onAddAction() {
        viewModel.navigate(to: .connectEmail)
    }
    
    private func deleteEmailAction() {
        withAnimation {
            if let email = selectedEmail{
                viewModel.deleteEmail(email)
            }
        }
    }
}
