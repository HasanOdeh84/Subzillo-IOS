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
    @Binding var isUploading                    : Bool
    @State var fromProfile                      : Bool = false
    @StateObject var profileVM                  = ProfileViewModel()
    @State private var showLocalLoader          = false
    @State private var showPreview              = false
    var onDelegate                              : (() -> Void)?
    @State var permissionBottomTitle            : String = ""
    
    //MARK: - body
    var body: some View {
        ZStack {
            
            VStack {
                Capsule()
                    .fill(Color.grayCapsule)
                    .frame(width: 150, height: 5)
                    .padding(.bottom, 24)
                    .padding(.top, 0)
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    HStack {
                        Spacer()
                        Text(LocalizedStringKey(fromProfile ? "Profile Picture" : "Upload a Screenshot"))
                            .font(.appSemiBold(24))
                            .foregroundColor(Color.neutralMain700)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    
                    //                Text(LocalizedStringKey("Upload a screenshot from your bank email to automatically detect subscription payments."))
                    //                    .font(.appRegular(16))
                    //                    .foregroundColor(Color.gray)
                    
                    VStack(spacing: 0) {
                        UploadItem(title: LocalizedStringKey("Take Photo"),
                                   subTitle: LocalizedStringKey("Capture a new picture using your camera"),
                                   image: "camera", imageColor: Color.high, action: cameraAction)
                        Divider()
                            .overlay(Color.neutral300Border)
                        UploadItem(title: LocalizedStringKey("Choose from Gallery"),
                                   subTitle: LocalizedStringKey("Select an existing photo from your device"),
                                   image: "gallery", imageColor: Color.warning, action: galleryAction)
                        //                    Divider()
                        //                        .overlay(Color.neutral300Border)
                        //                    UploadItem(title: "Paste Text", subTitle: "Copy and paste notification text", image: "text-creation", imageColor: Color.purple100, action: pastTextAction)
                        if !fromProfile{
                            Divider()
                                .overlay(Color.neutral300Border)
                            UploadItem(title: LocalizedStringKey("Take Screenshot"),
                                       subTitle: LocalizedStringKey("Take Screenshot for subscriptions"),
                                       image: "screenshot", imageColor: Color.purple100, action: openSubscriptionsAction)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: fromProfile ? 160 : 240)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    if !fromProfile{
                        GradienCustomeView(title: "Privacy Notice", subTitle: "We only parse the content you provide to detect subscription payments. No data is stored permanently.", imageName: "privacyIcon")
                            .padding(.bottom, 0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
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
            .onChange(of: selectedImage) { image in
                if image != nil {
                    showPreview = true
                }
            }
            .sheet(isPresented: $showPreview) {
                if let image = selectedImage {
                    ImagePreviewView(image: image, onConfirm: {
                        uploadImage()
                    }, onCancel: {
                        selectedImage = nil
                    })
                    //                    .presentationDetents([.fraction(0.8), .large])
                    .background(Color.clear)
                    .presentationDetents([.height(imageHeightForSheet(image))])
                    .presentationDragIndicator(.hidden)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .onChange(of: uploadImageVM.hideLoader) { _ in onApi() }
            .onChange(of: profileVM.isProfileUpdate) { _ in onUpdateProfile() }
            .sheet(isPresented: $uploadImageVM.showErrorPopup, onDismiss: {
                isUploading = false
                showLocalLoader = false
            }) {
                UploadErrorImageSheet(
                    onDelegate: {
                        dismiss()
                    },
                    onDismiss: {
                        isUploading = false
                        showLocalLoader = false
                    }
                )
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(560)])
            }
            .sheet(isPresented: $showPermissionAlert) {
                PermissionSheet(onDelegate: {
                    dismiss()
                }, title                        : fromProfile ? (isCamera ? "We need camera access to update profile photo" : "We need gallery access to update profile photo") : (isCamera ? "We need camera access to add subscriptions by take photo" : "We need gallery access to add subscriptions by image upload" ),
                                type            : isCamera == true ? "camera" : "gallery",
                                value           : isCamera == true ? "Tap Camera" : "Tap Photos",
                                hideManualBtn   : fromProfile ? true : false)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(fromProfile ? 530 : 580)])
            }
            .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
                showImagePicker = false
                uploadImageVM.showErrorPopup = false
                showPermissionAlert = false
            }
            .onAppear{
                originalImage = nil
//                if fromProfile{
//                    if isCamera{
//                        permissionBottomTitle = "We need camera access to update profile photo"
//                    }else{
//                        permissionBottomTitle = "We need camera access to add subscriptions by take photo"
//                    }
//                }else{
//                    if isCamera{
//                        permissionBottomTitle = "We need gallery access to update profile photo"
//                    }else{
//                        permissionBottomTitle = "We need gallery access to add subscriptions by image upload"
//                    }
//                }
            }
            if showLocalLoader {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    VStack {
                        LottieView(name: LoaderManager.shared.animationName, loopMode: .loop)
                            .frame(width: 100, height: 100)
                    }
                }
            }
        }
    }
    
    private func imageHeightForSheet(_ image: UIImage) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 40
        let aspectRatio = image.size.height / image.size.width
        let imageHeight = screenWidth * aspectRatio
        // Add some padding + capsule area
        return imageHeight + 150 + 50
    }
    
    private func onApi()
    {
        isUploading = false
        if uploadImageVM.showErrorPopup != true {
            dismiss()
        }
        // LoaderManager.shared.hideLoader()
        showLocalLoader = false
    }
    
    private func onUpdateProfile()
    {
        isUploading = false
        if profileVM.isProfileUpdate {
            dismiss()
            onDelegate?()
        }
        // LoaderManager.shared.hideLoader()
        showLocalLoader = false
    }
    
    private func uploadImage()
    {
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            
            originalImage = image
            isUploading = true
            // LoaderManager.shared.showLoader()
            showLocalLoader = true
            let timestamp = Int(Date().timeIntervalSince1970)
            let filename = "image_\(timestamp).jpg"
            if fromProfile{
                profileVM.updateProfileImage(input: UpdateProfileImageRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
                    fieldName   : "profile",
                    fileName    : filename,
                    mimeType    : "image/jpeg",
                    fileData    : imageData
                )])
            }else{
                uploadImageVM.imageSubscription(input: UpdateProfileImageRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
                    fieldName   : "screenshot",
                    fileName    : filename,
                    mimeType    : "image/jpeg",
                    fileData    : imageData
                )])
            }
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

//MARK: - UploadErrorImageSheet
struct UploadErrorImageSheet: View {
    
    //MARK: - Properties
    var isImage     = true
    var onDelegate  : (() -> Void)?
    var onDismiss   : (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.vertical, 24)
            
            VStack(alignment: .center, spacing: 8) {
                
                Image(isImage ? "ErrorImageIcon" : "no_mail")
                    .frame(width: 84, height: 84)
                    .padding(.bottom, 16)
                
                Text(LocalizedStringKey(isImage ? "Couldn't Read Image" : "No Subscriptions Found"))
                    .font(.appSemiBold(24))
                    .foregroundColor(Color.neutralMain700)
                
                Text(LocalizedStringKey(isImage ? "We couldn't extract subscription details from this image. Try these tips:" : "We scanned your recent emails but didn't find any subscription receipts."))
                    .font(.appRegular(18))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(spacing: 16) {
                    Image("bulb-charging")
                        .frame(width: 24, height: 24)
                    Text(LocalizedStringKey(isImage ? "Ensure text is clear and well-lit" : "Recurring payment receipts"))
                        .font(.appRegular(16))
                        .foregroundColor(Color.neutralMain700)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(spacing: 16) {
                    Image("image-crop")
                        .frame(width: 24, height: 24)
                    Text(LocalizedStringKey(isImage ? "Crop to show only the relevant text" : "Subscription confirmations"))
                        .font(.appRegular(16))
                        .foregroundColor(Color.neutralMain700)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !isImage{
                    HStack(spacing: 16) {
                        Image("book-03")
                            .frame(width: 24, height: 24)
                        Text(LocalizedStringKey(isImage ? "Make sure text is in English" : "Billing notifications"))
                            .font(.appRegular(16))
                            .foregroundColor(Color.neutralMain700)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            //            .padding(isImage ? 24 : 0)
            //            if isImage{
            //                .padding(24)
            //            }else{
            //                .padding(.top, 24)
            //                .padding(.horizontal, 24)
            //            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, isImage ? 24 : 0)
            
            if isImage{
                CustomButton(title: "Retry", buttonImage: "refresh", action: onRetryAction)
            }
            
            GradientBorderButton(title: "Add Manually Instead", isBtn: true, buttonImage: "text-creation1", action: onManualAction, backgroundColor: .whiteBlackBG)
                .padding(.vertical, 24)
        }
        .padding(.horizontal, 20)
    }
    
    //MARK: - Button actions
    private func onManualAction() {
        onDelegate?()
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
        }
    }
    
    private func onRetryAction() {
        onDismiss?()
        dismiss()
    }
}

struct UploadItem: View {
    var title                   : LocalizedStringKey
    var subTitle                : LocalizedStringKey
    var image                   : String
    var imageColor              : Color
    var action                  : () -> Void
    var isEmail                 = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if isEmail{
                    Image(image)
                        .frame(width: 48, height: 48)
                        .background(imageColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }else{
                    Image(image)
                        .frame(width: 48, height: 48)
                    //                    .background(imageColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.appSemiBold(16))
                        .foregroundColor(.neutralMain700)
                    
                    Text(subTitle)
                        .font(.appRegular(12))
                        .foregroundColor(.neutral500)
                        .multilineTextAlignment(.leading)
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
                VStack(alignment: .leading, spacing: 5) {
                    instructionRow(number: "1.", text: LocalizedStringKey("Take a screenshot of the required subscription."))
                    instructionRow(number: "2.", text: LocalizedStringKey("Come back to the “Upload Screenshot” screen."))
                    instructionRow(number: "3.", text: LocalizedStringKey("Click on Choose from Gallery."))
                    instructionRow(number: "4.", text: LocalizedStringKey("Select the screenshot you just captured."))
                }
            }
            
            CustomButton(title: "Continue", buttonImage: "", action: onContinueAction)
                .padding(.vertical, 24)
        }
        .padding(.horizontal, 24)
    }
    
    //MARK: - User defined methods
    func instructionRow(number: String, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 3) {
            Text(number)
                .font(.appRegular(18))
                .foregroundColor(Color.neutralMain700)
                .frame(width: 22, alignment: .leading)
            
            Text(text)
                .font(.appRegular(18))
                .foregroundColor(Color.neutralMain700)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    //MARK: - Button actions
    
    private func onContinueAction() {
        //        dismiss()
        Constants.shared.OpenSubscriptionsInAppStore()
    }
}

