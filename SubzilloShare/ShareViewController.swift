//import UIKit
//import Social
//import MobileCoreServices
//
//class ShareViewController: UIViewController {
//    
//    private let appURLScheme = "subzillo://share"
//    private let appGroupIdentifier = "group.com.krify.Subzillo"
//    
//    private var sharedImageData: Data?
//    
//    private let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemBackground
//        view.layer.cornerRadius = 20
//        view.clipsToBounds = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let imageView: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFit
//        iv.backgroundColor = .secondarySystemBackground
//        iv.layer.cornerRadius = 12
//        iv.clipsToBounds = true
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        return iv
//    }()
//    
//    private let uploadButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Upload", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 12
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let cancelButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Cancel", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadSharedImage()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        
//        view.addSubview(containerView)
//        containerView.addSubview(imageView)
//        containerView.addSubview(uploadButton)
//        containerView.addSubview(cancelButton)
//        
//        NSLayoutConstraint.activate([
//            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            containerView.widthAnchor.constraint(equalToConstant: 300),
//            containerView.heightAnchor.constraint(equalToConstant: 400),
//            
//            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
//            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
//            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
//            imageView.heightAnchor.constraint(equalToConstant: 250),
//            
//            uploadButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
//            uploadButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
//            uploadButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
//            uploadButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            cancelButton.topAnchor.constraint(equalTo: uploadButton.bottomAnchor, constant: 10),
//            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
//        ])
//        
//        uploadButton.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
//        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
//    }
//    
//    private func loadSharedImage() {
//        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
//              let attachment = extensionItem.attachments?.first else { return }
//        
//        if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
//            attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { [weak self] (data, error) in
//                guard let self = self else { return }
//                
//                if let url = data as? URL {
//                    self.sharedImageData = try? Data(contentsOf: url)
//                } else if let image = data as? UIImage {
//                    self.sharedImageData = image.jpegData(compressionQuality: 0.8)
//                }
//                
//                if let data = self.sharedImageData {
//                    DispatchQueue.main.async {
//                        self.imageView.image = UIImage(data: data)
//                    }
//                }
//            }
//        }
//    }
//    
//    @objc private func didTapUpload() {
//        if let data = sharedImageData {
//            saveImageToAppGroup(data: data)
//            redirectToMainApp()
//        }
//        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
//    }
//    
//    @objc private func didTapCancel() {
//        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
//    }
//    
//    private func saveImageToAppGroup(data: Data) {
//        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
//            sharedDefaults.set(data, forKey: "sharedImageData")
//            sharedDefaults.synchronize()
//        }
//    }
//    
//    private func redirectToMainApp() {
//        if let url = URL(string: appURLScheme) {
//            var responder: UIResponder? = self
//            while responder != nil {
//                if let application = responder as? UIApplication {
//                    application.open(url, options: [:], completionHandler: nil)
//                    break
//                }
//                responder = responder?.next
//            }
//        }
//    }
//}

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    
    private let appURLScheme = "subzillo://share"
//    private let appGroupIdentifier = "group.com.krify.Subzillo"
    private let appGroupIdentifier = "group.com.subzillo.app"

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachment = extensionItem.attachments?.first else {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }

        if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
            attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { [weak self] (data, error) in
                guard let self = self else { return }
                
                var imageData: Data?
                if let url = data as? URL {
                    imageData = try? Data(contentsOf: url)
                } else if let image = data as? UIImage {
                    imageData = image.jpegData(compressionQuality: 0.8)
                }
                
                if let data = imageData {
                    self.saveImageToAppGroup(data: data)
                    self.redirectToMainApp()
                }
                
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    }

    private func saveImageToAppGroup(data: Data) {
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.set(data, forKey: "sharedImageData")
            sharedDefaults.synchronize()
        }
    }

    private func redirectToMainApp() {
        if let url = URL(string: appURLScheme) {
            var responder: UIResponder? = self
            while responder != nil {
                if let application = responder as? UIApplication {
                    application.open(url, options: [:], completionHandler: nil)
                    break
                }
                responder = responder?.next
            }
        }
    }
}
