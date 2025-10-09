//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI

struct ProfileView: View {
    @Binding var path           : NavigationPath
    @StateObject var loginVM    = LoginViewModel()
    @StateObject var profileVM  = ProfileViewModel()
    
    var body: some View {
        VStack{
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
            Button("Update user info"){
                let input = UpdateUserInfoRequest(userId        : Constants.getUserId(),
                                                  fullName      : "alekya",
                                                  email         : "alekhya@krify.com",
                                                  type          : 1,
                                                  phoneNumber   : "9676442388",
                                                  countryCode   : "91")
                profileVM.updateUserInfo(input: input)
            }
            Button("Update password"){
                let input = UpdatePasswordRequest(userId            : Constants.getUserId(),
                                                  currentPassword   : "Krify@123",
                                                  newPassword       : "krify@123")
                profileVM.updatePassword(input: input)
            }
        }
    }
}

#Preview {
    ProfileView(path: .constant(NavigationPath()))
}
