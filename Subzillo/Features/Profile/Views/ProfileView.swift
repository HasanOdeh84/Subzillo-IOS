//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI

struct ProfileView: View {
    @Binding var path : NavigationPath
    @StateObject var loginVM = LoginViewModel()
    
    var body: some View {
        CustomButton(title: "Logout") {
            AlertManager.shared.showAlert(
                title       : "Logout",
                message     : "Are you sure you want to logout?",
                cancelText  : "Cancel",
                okAction    : {
                    loginVM.logout(input: LogoutRequest(userId: Constants.getUserId()),
                                   path : $path)
                }
            )
        }
    }
}

#Preview {
    ProfileView(path: .constant(NavigationPath()))
}
