//
//  UnifiedMediaPicker.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 10/10/25.
//

import SwiftUI
import PhotosUI
import UIKit
import UniformTypeIdentifiers

struct UnifiedMediaPicker: UIViewControllerRepresentable {
    let source: MediaSource
    @Binding var isPresented: Bool
    let onImagePicked: (UIImage) -> Void
    let onDocumentPicked: (URL) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        switch source {
        case .library:
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
            
        case .camera:
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = false
            picker.delegate = context.coordinator
            return picker
            
        case .document:
            let types = [UTType.image, UTType.pdf, UTType.text, UTType.data]
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
            picker.delegate = context.coordinator
            return picker
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UINavigationControllerDelegate,
                       PHPickerViewControllerDelegate,
                       UIImagePickerControllerDelegate,
                       UIDocumentPickerDelegate {
        let parent: UnifiedMediaPicker
        init(_ parent: UnifiedMediaPicker) { self.parent = parent }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            parent.isPresented = false
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let img = image as? UIImage {
                        DispatchQueue.main.async { self.parent.onImagePicked(img) }
                    }
                }
            }
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            parent.isPresented = false
            if let img = info[.originalImage] as? UIImage {
                parent.onImagePicked(img)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            parent.isPresented = false
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            controller.dismiss(animated: true)
            parent.isPresented = false
            if let url = urls.first {
                parent.onDocumentPicked(url)
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
            parent.isPresented = false
        }
    }
}
