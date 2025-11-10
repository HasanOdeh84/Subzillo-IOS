//
//  ManualEntryViewModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/11/25.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct DatePickerPopup: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    var onDone: (Date) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented, uiViewController.presentedViewController == nil else { return }

        // Create alert controller
        let alert = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)

        // Create picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = selectedDate
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        // Add picker to alert's view
        alert.view.addSubview(datePicker)

        // Constrain picker to alert.view with Auto Layout
        // You can tweak constants (width & height) to taste.
        let pickerHeight: CGFloat = 200
        let alertWidth: CGFloat = 320 // target alert width — tweak if needed

        // Activate constraints
        NSLayoutConstraint.activate([
            // center picker horizontally in alert
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            // pin top a bit below title area
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            // fixed height
            datePicker.heightAnchor.constraint(equalToConstant: pickerHeight),
            // ensure the picker doesn't exceed alert width (leading/trailing padding)
            datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: alert.view.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(lessThanOrEqualTo: alert.view.trailingAnchor, constant: -8),

            // Force alert width so the picker fits
            alert.view.widthAnchor.constraint(equalToConstant: alertWidth)
        ])

        // Add Cancel and Done actions
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            isPresented = false
        })

        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            selectedDate = datePicker.date
            onDone(datePicker.date)
            isPresented = false
        })

        // Present alert
        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true)
        }
    }
}
