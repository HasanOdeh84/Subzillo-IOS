//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI

struct ProfileView: View {
    
    //MARK: - Properties
    @StateObject var loginVM                = LoginViewModel()
    @StateObject var profileVM              = ProfileViewModel()
    @EnvironmentObject var picker           : MediaPickerManager
    @State private var selectedImage        : UIImage?
    @State private var selectedDocumentName : String?
    @StateObject private var commonApiVM    = CommonAPIViewModel()
    @EnvironmentObject var router           : AppIntentRouter
    @State var appVersion = ""
    @State var buildNumber = ""
    
    //MARK: - Body
    var body: some View {
        VStack{
            Spacer()
            CustomButton(title: "Logout") {
                AlertManager.shared.showAlert(
                    title       : "Logout",
                    message     : "Are you sure you want to logout?",
                    cancelText  : "Cancel",
                    okAction    : {
                        loginVM.logout(input: LogoutRequest(userId: Constants.getUserId()))
                    }
                )
            }
            .padding(20)
//            Button("Update user info"){
//                let input = UpdateUserInfoRequest(userId        : Constants.getUserId(),
//                                                  fullName      : "alekya",
//                                                  email         : "alekhya@krify.com",
//                                                  type          : 1,
//                                                  phoneNumber   : "9676442388",
//                                                  countryCode   : "91")
//                profileVM.updateUserInfo(input: input)
//            }
//            Button("Update password"){
//                let input = UpdatePasswordRequest(userId            : Constants.getUserId(),
//                                                  currentPassword   : "Krify@123",
//                                                  newPassword       : "krify@123")
//                profileVM.updatePassword(input: input)
//            }
//            if let image = selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 250)
//                    .cornerRadius(10)
//            }
//            
//            if let doc = selectedDocumentName {
//                Text("Selected document: \(doc)")
//                    .font(.footnote)
//                    .foregroundColor(.gray)
//            }
//                        
//            Button("camera image picker") {
//                picker.present(allowDocument: false,onImageData: {image, data, filename, mimeType in
//                    profileVM.updateProfileImage(input: UpdateProfileImageRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
//                        fieldName   : "profile",
//                        fileName    : filename,
//                        mimeType    : mimeType,//"image/jpeg",
//                        fileData    : data
//                    )])
//                    selectedImage = image
//                })
//            }
            
//            Spacer()
            
            /* picker with document
            Button("camera image document picker") {
                picker.present(allowDocument: true,
                               onImageData: { image, data, filename, mimeType in
                    profileVM.updateProfileImage(input: UpdateProfileImageRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
                        fieldName   : "profile",
                        fileName    : filename,
                        mimeType    : mimeType,
                        fileData    : data
                    )])
                    selectedImage = image
                },
                               onDocumentData: {url, data, filename, mimeType in
                    selectedDocumentName = url?.lastPathComponent
                })
            }
            Spacer()
            */
            
//            Button("Image subscription") {
//                picker.present(allowDocument: false,onImageData: {image, data, filename, mimeType in
//                    profileVM.imageSubscription(input: ImageSubscriptionRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
//                        fieldName   : "screenshot",
//                        fileName    : filename,
//                        mimeType    : mimeType,
//                        fileData    : data
//                    )])
//                    selectedImage = image
//                })
//            }
//            
//            Button("get categories api"){
//                commonApiVM.getCategories()
//            }
            
            Spacer()
            HStack(spacing: 4) {
                Text("Version \(appVersion)")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Text("Build \(buildNumber)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 120)
        }
        .background(MediaPickerHost().allowsHitTesting(false)) // host
        .onAppear{
            appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        }
    }
}

#Preview {
    ProfileView()
}
