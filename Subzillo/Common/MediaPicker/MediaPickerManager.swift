//
//  MediaPickerManager.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 10/10/25.
//

import SwiftUI
import PhotosUI
import UIKit
import UniformTypeIdentifiers

final class MediaPickerManager: ObservableObject {
    static let shared = MediaPickerManager()
    
    @Published var showActionSheet = false
    @Published var showPicker = false
    @Published var currentSource: MediaSource = .library
    @Published var allowDocumentOption: Bool = false
    
    @Published var showErrorAlert = false
    var errorMessage = ""
    
    // Completion closures
    var onImageDataPicked: ((UIImage?, Data, String, String) -> Void)? // Data, filename, mimeType
    var onDocumentDataPicked: ((URL?,Data, String, String) -> Void)? // Data, filename, mimeType
    
    func present(allowDocument: Bool = false,
                 onImageData: ((UIImage?, Data, String, String) -> Void)? = nil,
                 onDocumentData: ((URL?, Data, String, String) -> Void)? = nil) {
        self.allowDocumentOption = allowDocument
        self.onImageDataPicked = onImageData
        self.onDocumentDataPicked = onDocumentData
        showActionSheet = true
    }
    
    // MARK: - Choices
    func chooseCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            currentSource = .camera
            showPicker = true
        } else {
            errorMessage = "Camera not available on this device."
            showErrorAlert = true
        }
    }
    
    func chooseLibrary() {
        currentSource = .library
        showPicker = true
    }
    
    func chooseDocument() {
        currentSource = .document
        showPicker = true
    }
    
    // MARK: - Handle Picked
    func handlePicked(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let filename = "image_\(Int(Date().timeIntervalSince1970)).jpg"
        let mimeType = "image/jpeg"
        onImageDataPicked?(image,data, filename, mimeType)
        onImageDataPicked = nil
    }
    
    func handlePicked(document url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let filename = url.lastPathComponent
            let mimeType = mimeTypeFrom(url: url)
            onDocumentDataPicked?(url, data, filename, mimeType)
            onDocumentDataPicked = nil
        } catch {
            errorMessage = "Unable to read file data."
            showErrorAlert = true
        }
    }
    
    // MIME type helper
    private func mimeTypeFrom(url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "pdf": return "application/pdf"
        case "txt": return "text/plain"
        default: return "application/octet-stream"
        }
    }
}
