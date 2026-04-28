//
//  SharedImageManager.swift
//  Subzillo
//
//  Created by Antigravity on 27/01/26.
//

import SwiftUI

class SharedImageManager: ObservableObject {
    static let shared = SharedImageManager()
    @Published var sharedImage: UIImage? = nil
    
    private let appGroupIdentifier = Constants.appGroupID

    func checkSharedImage() {
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            if let imageData = sharedDefaults.data(forKey: "sharedImageData"),
               let image = UIImage(data: imageData) {
                self.sharedImage = image
                // Clear after reading so we don't process it again
                sharedDefaults.removeObject(forKey: "sharedImageData")
                sharedDefaults.synchronize()
            }
        }
    }
}
