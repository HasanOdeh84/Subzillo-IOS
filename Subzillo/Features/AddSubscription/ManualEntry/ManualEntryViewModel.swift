//
//  ManualEntryViewModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/11/25.
//

import Combine
import SwiftUI
import SwiftUICore
import UIKit

class ManualEntryViewModel: ObservableObject {
    
    private var subscriptions                       = Set<AnyCancellable>()
    var apiReference                                = NetworkRequest.shared
    @Published var addSubscriptionResponse          : AddSubscriptionResponseData?
    @Published var listUserCardsResponse            : [ListUserCardsResponseData]?
    @Published var listFamilyMembersResponse        : [ListFamilyMembersResponseData]?
    @Published var servicesList                     : [GetServiceProvidersListData]?
    @Published var providerData                     : FetchProviderData?
    @Published var isLoading                        : Bool = false
    private let router                              : AppIntentRouter
    private let sessionManager                      : SessionManager
    @Published var isManualEntrySuccess             : Bool?
    @Published var isEditEntrySuccess               : Bool?
    
    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared){
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func addSubscription(input:AddSubscriptionRequest) {
        addSubscriptionResponse = nil
        isManualEntrySuccess = false
        apiReference.postApi(endPoint: APIEndpoint.addSubscription, method: .POST,token: authKey,body: input,showLoader: true, responseType: AddSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.addSubscription)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            if response.data != nil {
                self.addSubscriptionResponse = response.data
            }
            //            else{
            //                ToastManager.shared.showToast(message: response.message ?? "")
            //            }
            self.isManualEntrySuccess = true
        }
        .store(in: &self.subscriptions)
    }
    
    func addSubscriptionSiri(input:AddSubscriptionRequest) async -> Bool {
        await withCheckedContinuation { continuation in
            apiReference.postApi(endPoint: APIEndpoint.addSubscription, method: .POST,token: authKey,body: input,showLoader: true, responseType: AddSubscriptionResponse.self)
                .sink { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.handleError(error, endPoint: APIEndpoint.addSubscription)
                        
                        continuation.resume(returning: false)   // failed
                    }
                } receiveValue: { [weak self] response in
                    PrintLogger.modelLog(response, type: .response, isInput: false)
                    
                    continuation.resume(returning: true)  // success
                }
                .store(in: &self.subscriptions)
        }
    }
    
    func listUserCards(input:ListUserCardsRequest) {
        apiReference.postApi(endPoint: APIEndpoint.listUserCards, method: .POST,token: authKey,body: input,showLoader: true, responseType: ListUserCardsResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.listUserCards)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            listUserCardsResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func listFamilyMembers(input:ListFamilyMembersRequest, showLoader:Bool = false) {
        apiReference.postApi(endPoint: APIEndpoint.listFamilyMembers, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: ListFamilyMembersResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.listFamilyMembers)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            listFamilyMembersResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func addCard(input:AddCardRequest) {
        apiReference.postApi(endPoint: APIEndpoint.addCard, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.addCard)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
        }
        .store(in: &self.subscriptions)
    }
    
    func getServiceProvidersList() {
        apiReference.getApi(endPoint: APIEndpoint.getServiceProvidersList, token: authKey, responseType: GetServiceProvidersListResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.getServiceProvidersList)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.servicesList = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func fetchProviderData(input:FetchProviderDataRequest) {
        apiReference.postApi(endPoint: APIEndpoint.fetchProviderData, method: .POST,token: authKey,body: input,showLoader: true, responseType: FetchProviderDataResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.fetchProviderData)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.providerData = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func editSubscription(input:EditSubscriptionRequest) {
        addSubscriptionResponse = nil
        isEditEntrySuccess = false
        apiReference.postApi(endPoint: APIEndpoint.editSubscription, method: .POST,token: authKey,body: input,showLoader: true, responseType: AddSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.editSubscription)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            if response.data != nil {
                self.addSubscriptionResponse = response.data
            }
            //            else{
            //                ToastManager.shared.showToast(message: response.message ?? "")
            //            }
            self.isEditEntrySuccess = true
        }
        .store(in: &self.subscriptions)
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}

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
        let alert = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
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

struct ExpiryDatePopup: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedDate: String
    var onDone: (String) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented, uiViewController.presentedViewController == nil else { return }
        
        let alert = UIAlertController(title: "Select Expiry Date", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        // Setup UIDatePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Add picker to alert
        alert.view.addSubview(datePicker)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            datePicker.heightAnchor.constraint(equalToConstant: 150),
            alert.view.widthAnchor.constraint(equalToConstant: 300)
        ])
        
        // Cancel & Done buttons
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            isPresented = false
        })
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yy"
            let formatted = formatter.string(from: datePicker.date)
            selectedDate = formatted
            onDone(formatted)
            isPresented = false
        })
        
        // Present the alert
        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true)
        }
    }
}
