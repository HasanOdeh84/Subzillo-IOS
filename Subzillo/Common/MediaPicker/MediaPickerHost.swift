//
//  MediaPickerHost.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 10/10/25.
//

import SwiftUI

struct MediaPickerHost: View {
    @EnvironmentObject var manager: MediaPickerManager
    
    var body: some View {
        Color.clear
            .confirmationDialog("Select Media", isPresented: $manager.showActionSheet, titleVisibility: .visible) {
                
                Button("Camera") { manager.chooseCamera() }
                Button("Gallery") { manager.chooseLibrary() }
                
                if manager.allowDocumentOption {
                    Button("Document") { manager.chooseDocument() }
                }
                
                Button("Cancel", role: .cancel) {}
            }
            .alert(isPresented: $manager.showErrorAlert) {
                Alert(title: Text("Error"),
                      message: Text(manager.errorMessage),
                      dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: Binding(get: { manager.showPicker },
                                        set: { manager.showPicker = $0 })) {
                UnifiedMediaPicker(
                    source: manager.currentSource,
                    isPresented: $manager.showPicker,
                    onImagePicked: { img in manager.handlePicked(image: img) },
                    onDocumentPicked: { url in manager.handlePicked(document: url) }
                )
            }
    }
}
