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
    var isChatBot                               = false
    var onDelegate                              : (() -> Void)?
    var onImageSelected                         : ((UIImage) -> Void)?
    @State var permissionBottomTitle            : String = ""
    @EnvironmentObject var themeManager         : ThemeManager
    
    //MARK: - body
    var body: some View {
        ZStack {
            
            VStack {
                Capsule()
                    .fill(Color.capsuleBlack12White14)
                    .frame(width: 40, height: 5)
                    .padding(.bottom, 24)
                    .padding(.top, 0)
                
                Image("profilePic_new")
                    .renderingMode(.template)
                    .foregroundStyle(themeManager.accentGradient)
                    .frame(width: 80, height: 80)
                    .padding(.bottom, 18)
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    HStack {
                        Spacer()
                        if isChatBot{
                            Text("Choose an image")
                                .font(.geistSemiBold(16))
                                .foregroundColor(Color.textPrimary0E101AF4F1FB)
                                .multilineTextAlignment(.center)
                        }else{
                            Text(fromProfile ? "Profile Picture" : "Upload a Screenshot")
                                .font(.geistSemiBold(24))
                                .foregroundColor(Color.textPrimary0E101AF4F1FB)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    
                    //                Text(LocalizedStringKey("Upload a screenshot from your bank email to automatically detect subscription payments."))
                    //                    .font(.appRegular(16))
                    //                    .foregroundColor(Color.gray)
                    
                    VStack(spacing: 12) {
                        UploadItem(title: "Take Photo",
                                   subTitle: "Capture a new picture using your camera",
                                   image: "cameraIcon", imageColor: Color.high, action: cameraAction)
                        //                        Divider()
                        //                            .overlay(Color.neutral300Border)
                        UploadItem(title: "Choose from Gallery",
                                   subTitle: "Select an existing photo from your device",
                                   image: "gallery_new", imageColor: Color.warning, action: galleryAction)
                        //                    Divider()
                        //                        .overlay(Color.neutral300Border)
                        //                    UploadItem(title: "Paste Text", subTitle: "Copy and paste notification text", image: "text-creation", imageColor: Color.purple100, action: pastTextAction)
                        //                        if !fromProfile && !isChatBot{
                        //                            Divider()
                        //                                .overlay(Color.neutral300Border)
                        //                            UploadItem(title: "Take Screenshot",
                        //                                       subTitle: "Take Screenshot for subscriptions",
                        //                                       image: "screenshot", imageColor: Color.purple100, action: openSubscriptionsAction)
                        //                        }
                    }
                    //                    .frame(maxWidth: .infinity, alignment: .leading)
                    //                    .frame(height: fromProfile || isChatBot ? 160 : 240)
                    //                    .cornerRadius(12)
                    //                    .overlay(
                    //                        RoundedRectangle(cornerRadius: 12)
                    //                            .stroke(Color.neutral300Border, lineWidth: 1)
                    //                    )
                    //                    if !fromProfile{
                    //                        GradienCustomeView(title: "Privacy Notice", subTitle: "We only parse the content you provide to detect subscription payments. No data is stored permanently.", imageName: "privacyIcon")
                    //                            .padding(.bottom, 0)
                    //                            .frame(maxWidth: .infinity, alignment: .leading)
                    //                            .fixedSize(horizontal: false, vertical: true)
                    //                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 0)
                
            }
            .padding(0)
            .sheet(isPresented: $showImagePicker) {
                if pickerSource == .camera {
                    ImagePicker(sourceType: .camera, selectedImage: $selectedImage, isAllowsEditing: fromProfile ? true : false)
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
                if let image = image {
                    if isCamera || isChatBot {
                        // Directly upload for camera or chatbot, skip preview
                        uploadImage()
                        selectedImage = nil // Reset so gallery can still work after
                    } else {
                        showPreview = true
                    }
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
                .presentationDetents([.height(540)])
            }
            .sheet(isPresented: $showPermissionAlert) {
                PermissionSheet(onDelegate: {
                    dismiss()
                }, title                        : fromProfile ? (isCamera ? "We need camera access to update profile photo".localized : "We need gallery access to update profile photo".localized) : (isCamera ? "We need camera access to add subscriptions by take photo".localized : "We need gallery access to add subscriptions by image upload".localized ),
                                type            : isCamera == true ? "camera" : "gallery",
                                value           : isCamera == true ? "Tap Camera".localized : "Tap Photos".localized,
                                icon            : isCamera == true ? "camePer" : "galleryPer",
                                hideManualBtn   : fromProfile ? true : false)
                .presentationDragIndicator(.hidden)
//                .presentationDetents([.height(fromProfile ? 500 : 560)])
                .presentationDetents([.height(490)])
            }
            .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
                showImagePicker = false
                uploadImageVM.showErrorPopup = false
                showPermissionAlert = false
            }
            .onAppear{
                // Reset internal selectedImage when appearing
                selectedImage = nil
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
                    // Invisible shield to block interactions while loader is active
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .opacity(showLocalLoader ? 1 : 0)
                    
                    VStack(spacing: 12) {
                        LottieView(name: LoaderManager.shared.animationName, loopMode: .loop)
                            .frame(width: 100, height: 100)
                    }
                    .opacity(showLocalLoader ? 1 : 0)
                    .scaleEffect(showLocalLoader ? 1.0 : 0.8)
                }
                //                .animation(.easeInOut(duration: 0.3), value: showLocalLoader)
                .allowsHitTesting(showLocalLoader)
                //                ZStack {
                //                    Color.black.opacity(0.5)
                //                        .ignoresSafeArea()
                //                    VStack {
                //                        LottieView(name: LoaderManager.shared.animationName, loopMode: .loop)
                //                            .frame(width: 100, height: 100)
                //                    }
                //                }
            }
        }
        .background(.bottomBGFFFFFF120A1F)
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
            
            onImageSelected?(image)
            isUploading = true
            // LoaderManager.shared.showLoader()
            showLocalLoader = true
            let timestamp = Int(Date().timeIntervalSince1970)
            let filename = "image_\(timestamp).jpg"
            if isChatBot {
                isUploading = false
                showLocalLoader = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                    onDelegate?()
                }
            } else if fromProfile{
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
    var isImage         = true
    var fromEmailSync   : Bool = false
    var onDelegate      : (() -> Void)?
    var onDismiss       : (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager : ThemeManager
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(themeManager.textPrimaryDark_white07)
                .frame(width: 40, height: 4)
                .padding(.vertical, 16)
            
            VStack(alignment: .center, spacing: 8) {
                
                Image(isImage ? "ErrorImageIcon" : "no_mail")
                    .renderingMode(.template)
                    .foregroundStyle(themeManager.accentGradient)
                    .frame(width: 80, height: 80)
//                    .padding(.bottom, 18)
                
                Text(isImage ? "Couldn't Read Image" : "No Subscriptions Found")
                    .font(.geistSemiBold(16))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                
                Text(isImage ? "We couldn't extract subscription details from this image. Try these tips:" : "We scanned your recent emails but didn't find any subscription receipts.")
                    .font(.geistMedium(12))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(spacing: 16) {
                    Image("bulb-charging")
                        .renderingMode(.template)
                        .foregroundStyle(themeManager.selectedAccent.senColor)
                        .frame(width: 24, height: 24)
                    Text(isImage ? "Ensure text is clear and well-lit" : "Recurring payment receipts")
                        .font(.geistRegular(14))
                        .foregroundColor(themeManager.black_white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(spacing: 16) {
                    Image("image-crop")
                        .renderingMode(.template)
                        .foregroundStyle(themeManager.selectedAccent.senColor)
                        .frame(width: 24, height: 24)
                    Text(isImage ? "Crop to show only the relevant text" : "Subscription confirmations")
                        .font(.geistRegular(14))
                        .foregroundColor(themeManager.black_white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !isImage{
                    HStack(spacing: 16) {
                        Image("book-03")
                            .renderingMode(.template)
                            .foregroundStyle(themeManager.selectedAccent.senColor)
                            .frame(width: 24, height: 24)
                        Text(isImage ? "Make sure text is in English" : "Billing notifications")
                            .font(.geistRegular(14))
                            .foregroundColor(themeManager.black_white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(themeManager.textPrimaryLight1_white8)
            )
            .overlay {
                
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        Color.textPrimary0E101AF4F1FB
                            .opacity(0.08),
                        lineWidth: 1
                    )
            }
            .cornerRadius(18)
            .padding(.vertical, 20)
            
            if isImage{
                
                GradientBgButton(
                    title       : "Retry",
                    isSolid     : true,
                    showChevron : false,
                    icon        : "refresh",
                    iconOnLeft  : false,
                    action      : onRetryAction
                )
            }
            
            GradientBorderButtonNew(title: "Add Manually Instead", isBtn: true, buttonImage: "plusicon", action: onManualAction, backgroundColor: themeManager.selectedAccent.senColor)
                .padding(.vertical, 10)
        }
        .padding(.horizontal, 20)
        .background(.bottomBGFFFFFF120A1F)
    }
    
    //MARK: - Button actions
    private func onManualAction() {
        if fromEmailSync{
            onDelegate?()
            dismiss()
        }else{
            onDelegate?()
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
            }
        }
    }
    
    private func onRetryAction() {
        onDismiss?()
        dismiss()
    }
}

struct UploadItemNew: View {
    
    var title: LocalizedStringKey
    var subTitle: LocalizedStringKey
    var image: String
    var backgroundColor: Color
    var action: () -> Void
    @EnvironmentObject var themeManager     : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        Button(action: action) {
            
            HStack(spacing: 14) {
                
                Image(image)
                    .frame(width: 48, height: 48)
                    .background(colorScheme == .dark ? themeManager.black_white.opacity(0.08) : backgroundColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(title)
                        .font(.geistSemiBold(15))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                    
                    Text(subTitle)
                        .font(.geistRegular(12))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                        )
                        //.lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if colorScheme == .dark
                {
                    Image("backGrayright1")
                        .frame(width: 16, height: 16)
                }
                else{
                    Image("rightArrow1")
                        .frame(width: 16, height: 16)
                }
            }
            .padding(16)
        }
    }
}
struct UploadItem: View {
    var title                   : LocalizedStringKey
    var subTitle                : LocalizedStringKey
    var image                   : String
    var imageColor              : Color
    var action                  : () -> Void
    var isEmail                 = false
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                //                if isEmail{
                //                    Image(image)
                //                        .frame(width: 48, height: 48)
                //                        .background(imageColor)
                //                        .clipShape(RoundedRectangle(cornerRadius: 8))
                //                }else{
                //                    Image(image)
                //                        .frame(width: 48, height: 48)
                //                    //                    .background(imageColor)
                //                        .clipShape(RoundedRectangle(cornerRadius: 8))
                //                }
                ZStack {
                    themeManager.accentGradient
                    
                    Image(image)
                        .frame(width:24,height: 24)
                }
                .frame(width: 47, height: 47)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
                //                .shadow(
                //                    color: themeManager.selectedAccent.senColor.opacity(0.55),
                //                    radius: 15,
                //                    y: 10
                //                )
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.geistBold(12))
                        .foregroundColor(.textPrimary0E101AF4F1FB)
                    
                    Text(subTitle)
                        .font(.geistRegular(12))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("arrow-right-01-round")
                    .frame(width: 20, height: 20)
                
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .frame(height: 72)
            .background(themeManager.white_white4)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.textPrimary0E101AF4F1FB.opacity(0.10), lineWidth: 1)
            )
        }
    }
}

struct AppstoreRedirectionSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager : ThemeManager
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(themeManager.textPrimaryDark_white07)
                .frame(width: 40, height: 4)
                .padding(.vertical, 16)
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("You will be redirected to the subscription list in Appstore.")
                    .font(.geistSemiBold(16))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Please follow these steps carefully:")
                        .font(.geistBold(12))
                        .foregroundColor(themeManager.black_white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        instructionRow(number: "1.", text: "Take a screenshot of the required subscription.")
                        instructionRow(number: "2.", text: "Come back to the “Upload Screenshot” screen.")
                        instructionRow(number: "3.", text: "Click on Choose from Gallery.")
                        instructionRow(number: "4.", text: "Select the screenshot you just captured.")
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(themeManager.textPrimaryLight1_white8)
                )
                .overlay {
                    
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.08),
                            lineWidth: 1
                        )
                }
                .cornerRadius(18)
                .padding(.vertical, 20)
            }
            
            GradientBgButton(
                title       : "Continue",
                isSolid     : true,
                showChevron : false,
                action      : onContinueAction
            )
        }
        .padding(.horizontal, 20)
        .applyAppBackground()
    }
    
    //MARK: - User defined methods
    func instructionRow(number: String, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 3) {
            Text(number)
                .font(.geistRegular(12))
                .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                .frame(width: 22, alignment: .leading)
            
            Text(text)
                .font(.geistRegular(12))
                .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    //MARK: - Button actions
    
    private func onContinueAction() {
        //        dismiss()
        Constants.shared.OpenSubscriptionsInAppStore()
    }
}

