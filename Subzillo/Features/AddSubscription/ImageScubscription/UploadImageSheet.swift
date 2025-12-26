//
//  UploadImageSheet.swift
//  Subzillo
//
//  Created by Ratna Kavya on 13/11/25.
//

import SwiftUI
import AVFoundation
import Photos

struct UploadImageSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker          = false
    @State private var selectedImage            : UIImage? = nil
    @State private var pickerSource             : UIImagePickerController.SourceType = .photoLibrary
    @StateObject var uploadImageVM              = UploadImageViewModel()
    @State private var showPermissionAlert      = false
    @State private var isCamera                 = false
    @State private var showRedirectionAlert     = false
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.bottom, 24)
                .padding(.top, 0)
            
            VStack(alignment: .leading, spacing: 24) {
                
                HStack {
                    Spacer()
                    Text(LocalizedStringKey("Upload a Screenshot"))
                        .font(.appSemiBold(24))
                        .foregroundColor(Color.neutralMain700)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                
//                Text(LocalizedStringKey("Upload a screenshot from your bank email to automatically detect subscription payments."))
//                    .font(.appRegular(16))
//                    .foregroundColor(Color.gray)
                
                VStack(spacing: 0) {
                    UploadItem(title: "Take Photo", subTitle: "Capture bank notification on screen", image: "camera", imageColor: Color.high, action: cameraAction)
                    Divider()
                        .overlay(Color.neutral300Border)
                    UploadItem(title: "Choose from Gallery", subTitle: "Select existing screenshot", image: "gallery", imageColor: Color.warning, action: galleryAction)
                    //                    Divider()
                    //                        .overlay(Color.neutral300Border)
                    //                    UploadItem(title: "Paste Text", subTitle: "Copy and paste notification text", image: "text-creation", imageColor: Color.purple100, action: pastTextAction)
                    Divider()
                        .overlay(Color.neutral300Border)
                    UploadItem(title: "Take Screenshot", subTitle: "Take Screenshot for subscriptions", image: "screenshot", imageColor: Color.purple100, action: openSubscriptionsAction)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 240)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neutral300Border, lineWidth: 1)
                )
                
                GradienCustomeView(title: "Privacy Notice", subTitle: "We only parse the content you provide to detect subscription payments. No data is stored permanently.", imageName: "privacyIcon")
                    .padding(.bottom, 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 0)
        }
        .padding(0)
        .sheet(isPresented: $showImagePicker) {
            if pickerSource == .camera {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea()
            } else {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
        }
        .sheet(isPresented: $showRedirectionAlert) {
            AppstoreRedirectionSheet()
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(450)])
        }
        .onChange(of: selectedImage) { _ in uploadImage() }
        .onChange(of: uploadImageVM.hideLoader) { _ in onApi() }
        .sheet(isPresented: $uploadImageVM.showErrorPopup) {
            UploadErrorImageSheet(
                onDelegate: {
                    dismiss()
                }
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(560)])
        }
        .sheet(isPresented: $showPermissionAlert) {
            PermissionSheet(onDelegate: {
                dismiss()
            }, title: isCamera == true ? "We need camera access to add subscriptions by uploading screenshots" : "We need gallery access to add subscriptions by uploading screenshots", type: isCamera == true ? "camera" : "gallery", value: isCamera == true ? "Tap Camera" : "Tap Photos")
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(580)])
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            showImagePicker = false
            uploadImageVM.showErrorPopup = false
            showPermissionAlert = false
        }
        .onAppear{
            originalImage = nil
        }
        .modifier(LoaderModifier())
    }
    
    private func onApi()
    {
        if uploadImageVM.showErrorPopup != true {
            dismiss()
        }
        LoaderManager.shared.hideLoader()
    }
    
    private func uploadImage()
    {
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            
            originalImage = image
            LoaderManager.shared.showLoader()
            let timestamp = Int(Date().timeIntervalSince1970)
            let filename = "image_\(timestamp).jpg"
            uploadImageVM.imageSubscription(input: UpdateProfileImageRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
                fieldName   : "screenshot",
                fileName    : filename,
                mimeType    : "image/jpeg",
                fileData    : imageData
            )])
        }
    }
    
    // MARK: - Permission Checks
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            pickerSource = .camera
            showImagePicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        pickerSource = .camera
                        showImagePicker = true
                    } else {
                        showPermissionDenied(message: "Camera access is denied. Please enable it in Settings.")
                    }
                }
            }
        default:
            showPermissionDenied(message: "Camera access is denied. Please enable it in Settings.")
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            pickerSource = .photoLibrary
            showImagePicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        pickerSource = .photoLibrary
                        showImagePicker = true
                    } else {
                        showPermissionDenied(message: "Photo Library access is denied. Please enable it in Settings.")
                    }
                }
            }
        default:
            showPermissionDenied(message: "Photo Library access is denied. Please enable it in Settings.")
        }
    }
    
    private func showPermissionDenied(message: String) {
        showPermissionAlert = true
    }
    
    //MARK: - Button actions
    private func privacyAction() {
    }
    
    private func cameraAction() {
        isCamera = true
        //pickerSource = .camera
        //showImagePicker = true
        checkCameraPermission()
    }
    
    private func galleryAction() {
        isCamera = false
        //pickerSource = .photoLibrary
        //showImagePicker = true
        checkPhotoLibraryPermission()
    }
    
    private func openSubscriptionsAction() {
//        dismiss()
        showRedirectionAlert = true
    }
    
    private func pastTextAction() {
        dismiss()
        AppIntentRouter.shared.navigate(to: .pasteTextView)
    }
}

struct UploadErrorImageSheet: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.vertical, 24)
            
            VStack(alignment: .center, spacing: 8) {
                
                Image("ErrorImageIcon")
                    .frame(width: 84, height: 84)
                    .padding(.bottom, 16)
                
                Text(LocalizedStringKey("Couldn't Read Image"))
                    .font(.appSemiBold(24))
                    .foregroundColor(Color.neutralMain700)
                
                Text(LocalizedStringKey("We couldn't extract subscription details from this image. Try these tips:"))
                    .font(.appRegular(18))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(spacing: 16) {
                    Image("bulb-charging")
                        .frame(width: 24, height: 24)
                    Text(LocalizedStringKey("Ensure text is clear and well-lit"))
                        .font(.appRegular(16))
                        .foregroundColor(Color.neutralMain700)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(spacing: 16) {
                    Image("image-crop")
                        .frame(width: 24, height: 24)
                    Text(LocalizedStringKey("Crop to show only the relevant text"))
                        .font(.appRegular(16))
                        .foregroundColor(Color.neutralMain700)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                //                HStack(spacing: 16) {
                //                    Image("book-03")
                //                        .frame(width: 24, height: 24)
                //                    Text(LocalizedStringKey("Make sure text is in English"))
                //                        .font(.appRegular(16))
                //                        .foregroundColor(Color.neutralMain700)
                //                        .frame(maxWidth: .infinity, alignment: .leading)
                //                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            
            CustomButton(title: "Retry", buttonImage: "refresh", action: onRetryAction)
            
            GradientBorderButton(title: "Add Manually Instead", isBtn: true, buttonImage: "text-creation1", action: onManualAction, backgroundColor: .whiteBlackBG)
                .padding(.vertical, 24)
        }
        .padding(.horizontal, 20)
    }
    
    //MARK: - Button actions
    private func onManualAction() {
        onDelegate?()
        dismiss()
        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
    }
    
    private func onRetryAction() {
        dismiss()
    }
}

struct UploadItem: View {
    var title                   : String
    var subTitle                : String
    var image                   : String
    var imageColor              : Color
    var action                  : () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(image)
                    .frame(width: 48, height: 48)
//                    .background(imageColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.appSemiBold(16))
                        .foregroundColor(.neutralMain700)
                    
                    Text(subTitle)
                        .font(.appRegular(12))
                        .foregroundColor(.neutral500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("arrow-right-01-round")
                    .renderingMode(.template)
                    .foregroundColor(.secondaryNavyBlue400)
                    .frame(width: 24, height: 24)
                
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .frame(height: 80)
        }
    }
}

struct AppstoreRedirectionSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.vertical, 24)
            
            VStack(alignment: .leading, spacing: 15) {
                
                Text(LocalizedStringKey("You will be redirected to the subscription list in Appstore."))
                    .font(.appSemiBold(24))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey("Please follow these steps carefully:"))
                    .font(.appRegular(18))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 5){
                    Text(LocalizedStringKey("1. Take a screenshot of the required subscription."))
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutralMain700)
                    Text(LocalizedStringKey("2. Come back to the “Upload Screenshot” screen."))
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutralMain700)
                    Text(LocalizedStringKey("3. Click on Choose from Gallery."))
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutralMain700)
                    Text(LocalizedStringKey("4. Select the screenshot you just captured."))
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutralMain700)
                }
            }
            
            CustomButton(title: "Continue", buttonImage: "", action: onContinueAction)
                .padding(.vertical, 24)
        }
        .padding(.horizontal, 24)
    }
    
    //MARK: - Button actions
    
    private func onContinueAction() {
//        dismiss()
        Constants.shared.OpenSubscriptionsInAppStore()
    }
}
