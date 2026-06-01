//
//  UploadView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 20/05/26.
//
import SwiftUI
import AVFoundation
import Photos

enum PickerType: Int {
    case camera = 1
    case gallery = 2
}

struct UploadView: View {
    
    //MARK: - Properties
    @State private var showCameraPicker         = false
    @State private var showGalleryPicker        = false
    @State private var selectedImage            : UIImage? = nil
    @State private var pickerSource             : PickerType = .gallery
    @State private var isCamera                 = false
    @State private var showPermissionAlert      = false
    @State private var showPreview              = false
    @StateObject var uploadImageVM              = UploadImageViewModel()
    @StateObject var profileVM                  = ProfileViewModel()
    @State private var showLocalLoader          = false
    @State var isUploading                      : Bool = false
    @State private var showRedirectionAlert     = false
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack{
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                CircleBackButton {
                    goBack()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Upload screenshot")
                        .font(.geistBold(16))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                }
                
                Spacer()
                
                // MARK: - Empty Space
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal,20)
            .padding(.top, 10)
            
            ScrollView{
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        // MARK: - Header
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 0) {
                                Text("Snap a ")
                                    .font(.geistSemiBold(26))
                                    .foregroundColor(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                    )
                                
                                Text(" bank alert")
                                    .font(.jetBrainsSemiBoldItalic(26))
                                    .italic()
                                    .foregroundStyle(
                                        themeManager.accentGradient
                                    )
                                
                                //                        Text("bank alert")
                                //                            .font(.geistSemiBold(26))
                                //                            .italic()
                                //                            .overlay(
                                //                                themeManager.accentGradient
                                //                                    .mask(
                                //                                        Text("bank alert")
                                //                                            .font(.geistSemiBold(26))
                                //                                            .italic()
                                //                                    )
                                //                            )
                                //                            .foregroundColor(.clear)
                                
                            }
                            .multilineTextAlignment(.center)
                            
                            Text("SMS, push, or email — Subzi extracts the details.")
                                .font(.geistRegular(13))
                                .foregroundColor(
                                    Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                                )
                        }
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // MARK: - Upload Box
                        VStack(spacing: 12) {
                            Button {
                                galleryAction()
                            } label: {
                                ZStack {
                                    // MARK: - Striped Background
                                    Image(colorScheme == .dark ? "stripePatternBackgroundDark" : "stripePatternBackground")
                                    
                                    //                            // MARK: - Dashed Border
                                    //                            RoundedRectangle(cornerRadius: 24)
                                    //                                .stroke(
                                    //                                    themeManager.black_white.opacity(0.14),
                                    //                                    style: StrokeStyle(
                                    //                                        lineWidth: 2,
                                    //                                        dash: [8]
                                    //                                    )
                                    //                                )
                                    
                                    // MARK: - Content
                                    VStack(spacing: 12) {
                                        // MARK: - Camera Icon
                                        ZStack {
                                            themeManager.accentGradient
                                            
                                            Image("cameraIcon")
                                                .frame(width:28,height: 28)
                                        }
                                        .frame(width: 64, height: 64)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 20)
                                        )
                                        .shadow(
                                            color: themeManager.selectedAccent.senColor.opacity(0.55),
                                            radius: 15,
                                            y: 10
                                        )
                                        
                                        // MARK: - Title
                                        Text("Tap to choose image")
                                            .font(.geistSemiBold(15))
                                            .foregroundColor(
                                                Color("TextPrimary_ 0E101A_F4F1FB")
                                            )
                                        
                                        // MARK: - Subtitle
                                        Text("PNG · JPG · HEIC")
                                            .font(.jetBrainsMedium(11))
                                            .tracking(0.5)
                                            .foregroundColor(
                                                Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                                            )
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .aspectRatio(4/5, contentMode: .fit)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 24)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        
                        // MARK: - Buttons
                        VStack(spacing: 10) {
                            // MARK: - Camera Button
                            Button {
                                cameraAction()
                            } label: {
                                HStack(spacing: 8) {
                                    Image("cameraIcon")
                                        .frame(width:18,height: 18)
                                    
                                    Text("Camera")
                                        .font(.geistBold(15))
                                        .foregroundColor(
                                            Color.white
                                        )
                                }
                                .foregroundColor(themeManager.white_white4)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    themeManager.accentGradient
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                                .shadow(
                                    color: themeManager.selectedAccent.senColor.opacity(0.55),
                                    radius: 12,
                                    y: 8
                                )
                            }
                            
                            // MARK: - Bottom Buttons
                            HStack(spacing: 10) {
                                // Gallery
                                Button {
                                    galleryAction()
                                } label: {
                                    HStack(spacing: 7) {
                                        Image("galleryIcon")
                                            .frame(width:16,height: 16)
                                        Text("Gallery")
                                            .font(.geistSemiBold(14))
                                            .foregroundColor(
                                                Color("TextPrimary_ 0E101A_F4F1FB")
                                            )
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(themeManager.white_white4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                themeManager.black_white.opacity(0.08),
                                                lineWidth: 1
                                            )
                                    )
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 14)
                                    )
                                    .shadow(
                                        color: themeManager.black_white.opacity(0.15),
                                        radius: 4,
                                        y: 2
                                    )
                                }
                                
                                // Apple SS
                                Button {
                                    applessAction()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image("gridIconNew")
                                            .frame(width:14,height: 14)
                                        Text("Apple SS")
                                            .font(.geistSemiBold(13))
                                    }
                                    .foregroundColor(
                                        themeManager.selectedAccent.senColor
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        themeManager.accentGradient.opacity(0.133)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                themeManager.selectedAccent.senColor.opacity(0.27),
                                                lineWidth: 1
                                            )
                                    )
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 14)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                    }
                    
                    /* if showLocalLoader {
                     ScanningImageLoaderView()
                     .transition(.opacity)
                     .zIndex(10)
                     }*/
                }
                .fullScreenCover(isPresented: $showCameraPicker) {
                    ImagePicker(sourceType: .camera, selectedImage: $selectedImage, isAllowsEditing: false)
                        .edgesIgnoringSafeArea(.all)
                        .ignoresSafeArea()
                }
                .sheet(isPresented: $showGalleryPicker) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                }
                .onChange(of: selectedImage) { image in
                    if let image = image {
                        if pickerSource == .camera  {
                            // Directly upload for camera or chatbot, skip preview
                            uploadImage()
                            //selectedImage = nil // Reset so gallery can still work after
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
                            //selectedImage = nil
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
                            // AppIntentRouter.shared.pop()
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
                        //AppIntentRouter.shared.pop()
                    }, title                        : (pickerSource == .camera  ? "We need camera access to add subscriptions by take photo".localized : "We need gallery access to add subscriptions by image upload".localized ),
                                    type            : pickerSource == .camera  ? "camera" : "gallery",
                                    value           : pickerSource == .camera  ? "Tap Camera".localized : "Tap Photos".localized,
                                    icon            : isCamera == true ? "camePer" : "galleryPer",
                                    hideManualBtn   : false)
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.height(490)])
                }
                .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
                    showCameraPicker = false
                    showGalleryPicker = false
                    uploadImageVM.showErrorPopup = false
                    showPermissionAlert = false
                }
                .onAppear{
                    // Reset internal selectedImage when appearing
                    selectedImage = nil
                }
                .sheet(isPresented: $showRedirectionAlert) {
                    AppstoreRedirectionSheet()
                        .presentationDragIndicator(.hidden)
                        .presentationDetents([.height(360)])
                }
            }
        }
        .applyAppBackground()
        
        if showLocalLoader {
            //ScanningImageLoaderView()
            ZStack {
                // Fullscreen Loader
                ScanningImageLoaderView(selectedImage:selectedImage)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
            }
//            .applyAppBackground()
            .transition(.opacity)
            .zIndex(100)
        }
    }
    
    //MARK: - Button actions
    private func applessAction() {
        //Constants.shared.OpenSubscriptionsInAppStore()
        showRedirectionAlert = true
    }
    
    private func cameraAction() {
        isCamera = true
        checkCameraPermission()
    }
    
    private func galleryAction() {
        isCamera = false
        checkPhotoLibraryPermission()
    }
    private func goBack() {
        AppIntentRouter.shared.pop()
    }
    
    // MARK: - Permission Checks
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            pickerSource = .camera
            showCameraPicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        pickerSource = .camera
                        showCameraPicker = true
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
            pickerSource = .gallery
            showGalleryPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        pickerSource = .gallery
                        showGalleryPicker = true
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
    
    private func imageHeightForSheet(_ image: UIImage) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 40
        let aspectRatio = image.size.height / image.size.width
        let imageHeight = screenWidth * aspectRatio
        // Add some padding + capsule area
        return imageHeight + 150 + 50
    }
    
    // MARK: - Api
    private func onApi()
    {
        isUploading = false
        if uploadImageVM.showErrorPopup != true {
            //AppIntentRouter.shared.pop()
        }
        // LoaderManager.shared.hideLoader()
        showLocalLoader = false
    }
    
    private func onUpdateProfile()
    {
        isUploading = false
        if profileVM.isProfileUpdate {
            //AppIntentRouter.shared.pop()
        }
        // LoaderManager.shared.hideLoader()
        showLocalLoader = false
    }
    
    private func uploadImage()
    {
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            
            // onImageSelected?(image)
            isUploading = true
            // LoaderManager.shared.showLoader()
            showLocalLoader = true
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
}
