import Foundation
import Network
import SwiftUI
import Combine
import UIKit

class NetworkRequest {
    
    // MARK: - Properties
    static let shared                       = NetworkRequest()
    private let urlSession                  = URLSession.shared
    private var subscriptions               = Set<AnyCancellable>()
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }()
    
    // MARK: - Create Endpoint
    private func createURL(with endpoint: String) -> URL? {
        guard let urlComponents = URLComponents(string: "\(baseurl)\(endpoint)")
        else { return nil }
        return urlComponents.url
    }
    
    //MARK: - API's
    func regenerateAccessAPI() -> Future<Void, APIError> {
        return Future<Void, APIError> { promise in
            self.getApi(endPoint    : .regenerateAccessToken,
                        token       : KeychainHelperApp.read(account: Constants.refreshKey) ?? "",
                        showLoader  : false,
                        responseType: RefreshTokenResponse.self)
            .sink { completion in
                if case let .failure(error) = completion {
                    promise(.failure(error))
                }
            } receiveValue: { refreshData in
                KeychainHelperApp.save(refreshData.data?.accessToken, account: Constants.authKey)
                KeychainHelperApp.save(refreshData.data?.refreshToken, account: Constants.refreshKey)
                promise(.success(()))
            }
            .store(in: &self.subscriptions)
        }
    }
    
    func getApi<T: Decodable>(
        endPoint    : APIEndpoint,
        token       : String,
        showLoader  : Bool = false,
        showErrorToast: Bool = true,
        extraParams : String? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
//        // Retry any pending subscribePlan before firing this request
//        if endPoint != .subscribePlan { PricingPlansViewModel.shared.retryIfNeeded() }
        return self.getRequest(endPoint: endPoint, token: token, showLoader: showLoader, showErrorToast: showErrorToast, extraParams: extraParams, responseType: responseType)
            .catch { error -> AnyPublisher<T, APIError> in
                if case .unauthorized = error {
                    if endPoint == .regenerateAccessToken{
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Session expired, Please login again.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        return Fail(error: .unauthorized).eraseToAnyPublisher()
                    }else{
                        return self.regenerateAccessAPI()
                            .flatMap {
                                return self.getRequest(endPoint: endPoint, token: authKey, showLoader: showLoader, showErrorToast: showErrorToast, extraParams: extraParams, responseType: responseType)
                            }
                            .eraseToAnyPublisher()
                    }
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func postApiData<U : Encodable>(
        endPoint    : APIEndpoint,
        method      : HTTPMethod,
        token       : String,
        body        : U?,
        showLoader  : Bool = false
    ) -> AnyPublisher<Data, APIError> {
        return self.postRequestData(endPoint: endPoint, method: method,token: token,body: body,showLoader: showLoader)
            .catch { error -> AnyPublisher<Data, APIError> in
                if case .unauthorized = error {
                    if endPoint == .regenerateAccessToken{
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Session expired, Please login again.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        return Fail(error: .unauthorized).eraseToAnyPublisher()
                    }else{
                        return self.regenerateAccessAPI()
                            .flatMap {
                                return self.postRequestData(endPoint: endPoint, method: method,token: authKey,body: body,showLoader: showLoader)
                            }
                            .eraseToAnyPublisher()
                    }
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func postApi<T: Decodable, U : Encodable>(
        endPoint    : APIEndpoint,
        method      : HTTPMethod,
        token       : String,
        body        : U?,
        showLoader  : Bool = false,
        responseType: T.Type,
        fromSiri    : Bool = false,
        fromVerifyOtpBottom    : Bool = false
    ) -> AnyPublisher<T, APIError> {
        return self.postRequest(endPoint: endPoint, method: method,token: token,body: body,showLoader: showLoader, responseType: responseType,fromSiri: fromSiri, fromVerifyOtpBottom: fromVerifyOtpBottom)
            .catch { error -> AnyPublisher<T, APIError> in
                if case .unauthorized = error {
                    if endPoint == .regenerateAccessToken{
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Session expired, Please login again.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        return Fail(error: .unauthorized).eraseToAnyPublisher()
                    }else{
                        return self.regenerateAccessAPI()
                            .flatMap {
                                return self.postRequest(endPoint: endPoint, method: method,token: authKey,body: body,showLoader: showLoader, responseType: responseType)
                            }
                            .eraseToAnyPublisher()
                    }
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func postMultipartApi<T: Decodable, U : Encodable>(
        endPoint    : APIEndpoint,
        method      : HTTPMethod,
        token       : String,
        body        : MultipartInput<U>?,
        showLoader: Bool = false,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
        return self.multiPartRequest(endPoint: endPoint, method: method,token: token,body: body,showLoader: showLoader, responseType: responseType)
            .catch { error -> AnyPublisher<T, APIError> in
                if case .unauthorized = error {
                    if endPoint == .regenerateAccessToken{
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Session expired, Please login again.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        return Fail(error: .unauthorized).eraseToAnyPublisher()
                    }else{
                        return self.regenerateAccessAPI()
                            .flatMap {
                                return self.multiPartRequest(endPoint: endPoint, method: method,token: authKey,body: body,showLoader: showLoader, responseType: responseType)
                            }
                            .eraseToAnyPublisher()
                    }
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Request
    func getRequest<T: Decodable>(
        endPoint    : APIEndpoint,
        token       : String,
        showLoader  : Bool = false,
        showErrorToast: Bool = true,
        extraParams : String? = nil,
        responseType: T.Type
    ) -> Future<T, APIError> { //A Future is a Combine publisher that emits one value or one failure, then completes. Then the subscription automatically completes (no more emissions)
        return Future<T, APIError> { [self] promise in
            
            NetworkMonitor.shared.waitForNetworkStatus {
                guard NetworkMonitor.shared.isConnected else {
                    DispatchQueue.main.async {
                        if AppState.shared.isLoggedIn{
                            SheetManager.shared.isOfflineSheetVisible = true
                        }else{
                            AlertManager.shared.showAlert(title: "No Internet Connection", message: "Please check your internet connection.")
                        }
                    }
                    return promise(.failure(.noInternetConnection))
                }
            }
            
            if showLoader{
                LoaderManager.shared.showLoader()
                // Retry any pending subscribePlan before firing this request
                if endPoint != .subscribePlan {
                    if Constants.FeatureConfig.isS4Enabled {
                    }
                }
            }
            var finalEndpoint : String = endPoint.rawValue
            if extraParams != nil || extraParams != ""{
                finalEndpoint = endPoint.rawValue + (extraParams ?? "")
            }
            guard let url = self.createURL(with: finalEndpoint)
            else {
                return promise(.failure(.badRequest))
            }
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.GET.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "Authorization")
            
            PrintLogger.log(type: .authToken, message: token)
            PrintLogger.log(type: .apiUrl, message: url.absoluteString)
            
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.responseError
                        }
                    }
                    print("Status Code : \(httpResponse.statusCode)")
                    switch httpResponse.statusCode {
                    case 400 : //Error case
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.badRequest
                        }
                    case 401:
                        throw APIError.unauthorized
                    case 500:
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.internalServerError
                        }
                    case 409: //Someone logged
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Someone logged in your account.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.someOneLoggedInElsewhere
                        }
                    case 403: //Account blocked
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Your account has been blocked by the admin",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.accountBlocked
                        }
                    case 404: //User not found
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "User not found.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.notFound
                        }
                    default:
                        return result.data
                    }
                }
                .decode(type: T.self,
                        decoder: self.jsonDecoder)
                .receive(on: RunLoop.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    LoaderManager.shared.hideLoader()
                    switch error {
                    case let urlError as URLError:
                        promise(.failure(.urlError(urlError)))
                    case let decodingError as DecodingError:
                        promise(.failure(.decodingError(decodingError)))
                    case let apiError as APIError:
                        if showErrorToast {
                            ToastManager.shared.showToast(message: apiError.localizedDescription,style: .error)
                        }
                        promise(.failure(apiError))
                    default:
                        promise(.failure(.unknown))
                    }
                }
            }
            receiveValue: {
                if showLoader {
                    LoaderManager.shared.hideLoader()
                }
                promise(.success($0))
            }
            .store(in: &self.subscriptions)
        }
    }
    
    func postRequestData<U : Encodable>(
        endPoint    : APIEndpoint,
        method      : HTTPMethod,
        token       : String,
        body        : U?,
        showLoader  : Bool = false
    ) -> Future<Data, APIError> {
        return Future<Data, APIError> { [self] promise in
            
            NetworkMonitor.shared.waitForNetworkStatus {
                guard NetworkMonitor.shared.isConnected else {
                    DispatchQueue.main.async {
                        if AppState.shared.isLoggedIn{
                            let allowedEndpoints: [APIEndpoint] = [
                                .listSubscriptions,
                                .getSubscriptionDetails,
                                .getServiceProvidersList,
                                .getUserInfo,
                                .getCategories,
                                .getPaymentMethods,
                                .listUserCards,
                                .listFamilyMembers,
                                .fetchProviderData
                            ]
                            if !allowedEndpoints.contains(endPoint) {
                                SheetManager.shared.isOfflineSheetVisible = true
                            }
                        }else{
                            AlertManager.shared.showAlert(title: "No Internet Connection", message: "Please check your internet connection.")
                        }
                    }
                    return promise(.failure(.noInternetConnection))
                }
            }
            
            if showLoader{
                LoaderManager.shared.showLoader()
                // Retry any pending subscribePlan before firing this request
                if endPoint != .subscribePlan {
                    if Constants.FeatureConfig.isS4Enabled {
                    }
                }
            }
            
            guard let url = self.createURL(with: endPoint.rawValue)
            else {
                return promise(.failure(.badRequest))
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "Authorization")
            if let body = body {
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    return promise(.failure(.badRequest))
                }
            }
            PrintLogger.log(type: .authToken, message: token)
            PrintLogger.log(type: .apiUrl, message: url.absoluteString)
            PrintLogger.modelLog(body, type: .inputParamenters)
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.responseError
                        }
                    }
                    print("Status Code : \(httpResponse.statusCode)")
                    
                    switch httpResponse.statusCode {
                    case 400 :
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.badRequest
                        }
                    case 401:
                        throw APIError.unauthorized
                    case 500:
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.internalServerError
                        }
                    case 409: //Someone logged
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Someone logged in your account.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.someOneLoggedInElsewhere
                        }
                    case 403: //Account blocked
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Your account has been blocked by the admin",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.accountBlocked
                        }
                    case 404: //User not found
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "User not found.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.notFound
                        }
                    default:
                        return result.data
                    }
                }
                .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    if showLoader {
                        LoaderManager.shared.hideLoader()
                    }
                    switch error {
                    case let urlError as URLError:
                        promise(.failure(.urlError(urlError)))
                    case let apiError as APIError:
                        ToastManager.shared.showToast(message: apiError.localizedDescription,style: .error)
                        promise(.failure(apiError))
                    default:
                        promise(.failure(.unknown))
                    }
                }
            }
            receiveValue: {
                if showLoader {
                    LoaderManager.shared.hideLoader()
                }
                promise(.success($0))
            }
            .store(in: &self.subscriptions)
        }
    }

    //MARK: - Post Request
    func postRequest<T: Decodable, U : Encodable>(
        endPoint    : APIEndpoint,
        method      : HTTPMethod,
        token       : String,
        body        : U?,
        showLoader  : Bool = false,
        responseType: T.Type,
        fromSiri    : Bool = false,
        fromVerifyOtpBottom: Bool = false
    ) -> Future<T, APIError> {
        return Future<T, APIError> { [self] promise in
            
            //            guard self.isConnected else {
            //                DispatchQueue.main.async {
            //                    AlertManager.shared.showAlert(title: "No Internet Connection", message: "Please check your internet connection.")
            //                }
            //                return promise(.failure(.noInternetConnection))
            //            }
            NetworkMonitor.shared.waitForNetworkStatus {
                guard NetworkMonitor.shared.isConnected else {
                    DispatchQueue.main.async {
                        //                        SheetManager.shared.isOfflineSheetVisible = true
                        // AlertManager.shared.showAlert(title: "No Internet Connection", message: "Please check your internet connection.")
                        if AppState.shared.isLoggedIn{
                            let allowedEndpoints: [APIEndpoint] = [
                                .listSubscriptions,
                                .getSubscriptionDetails,
                                .getServiceProvidersList,
                                .getUserInfo,
                                .getCategories,
                                .getPaymentMethods,
                                .listUserCards,
                                .listFamilyMembers,
                                .fetchProviderData
                            ]
                            if !allowedEndpoints.contains(endPoint) {
                                SheetManager.shared.isOfflineSheetVisible = true
                            }
                        }else{
                            AlertManager.shared.showAlert(title: "No Internet Connection", message: "Please check your internet connection.")
                        }
                    }
                    return promise(.failure(.noInternetConnection))
                }
            }
            
            if showLoader{
                LoaderManager.shared.showLoader()
                // Retry any pending subscribePlan before firing this request
                if endPoint != .subscribePlan {
                    if Constants.FeatureConfig.isS4Enabled {
                    }
                }
            }
            
            guard let url = self.createURL(with: endPoint.rawValue)
            else {
                return promise(.failure(.badRequest))
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "Authorization")
            if let body = body {
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    return promise(.failure(.badRequest))
                }
            }
            PrintLogger.log(type: .authToken, message: token)
            PrintLogger.log(type: .apiUrl, message: url.absoluteString)
            PrintLogger.modelLog(body, type: .inputParamenters)
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.responseError
                        }
                    }
                    print("Status Code : \(httpResponse.statusCode)")
                    
                    /*if let jsonObject = try? JSONSerialization.jsonObject(with: result.data, options: []),
                     let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                     let jsonString = String(data: prettyData, encoding: .utf8) {
                     print("📦 Response JSON:\n\(jsonString)")
                     } else if let rawString = String(data: result.data, encoding: .utf8) {
                     print("📦 Response (raw string):\n\(rawString)")
                     } else {
                     print("⚠️ Unable to decode response data.")
                     }*/
                    
                    switch httpResponse.statusCode {
                    case 400 :
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.badRequest
                        }
                    case 401:
                        throw APIError.unauthorized
                    case 500:
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.internalServerError
                        }
                    case 409: //Someone logged
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Someone logged in your account.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.someOneLoggedInElsewhere
                        }
                    case 403: //Account blocked
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Your account has been blocked by the admin",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.accountBlocked
                        }
                    case 404: //User not found
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "User not found.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.notFound
                        }
                    default:
                        return result.data
                    }
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    if showLoader {
                        LoaderManager.shared.hideLoader()
                    }
                    switch error {
                    case let urlError as URLError:
                        promise(.failure(.urlError(urlError)))
                    case let decodingError as DecodingError:
                        promise(.failure(.decodingError(decodingError)))
                    case let apiError as APIError:
//                        if !fromSiri{
//                            if endPoint != .fetchProviderData{
//                                if !fromVerifyOtpBottom{
//                                    if endPoint != .subscribePlan{
//                                        ToastManager.shared.showToast(message: apiError.localizedDescription,style: .error)
//                                    }
//                                }
//                            }
//                        }
                        if fromSiri || endPoint == .fetchProviderData || fromVerifyOtpBottom || endPoint == .subscribePlan || endPoint == .addCard{
                            
                        }else{
                            ToastManager.shared.showToast(message: apiError.localizedDescription,style: .error)
                        }
                        promise(.failure(apiError))
                    default:
                        promise(.failure(.unknown))
                    }
                }
            }
            receiveValue: {
                if showLoader {
                    LoaderManager.shared.hideLoader()
                }
                promise(.success($0))
            }
            .store(in: &self.subscriptions)
        }
    }
    
    //MARK: - Post Request
    func multiPartRequest<T: Decodable, U: Encodable>(
        endPoint    : APIEndpoint,
        method      : HTTPMethod,
        token       : String,
        body        : MultipartInput<U>?,
        showLoader  : Bool = false,
        responseType: T.Type
    ) -> Future<T, APIError> {
        return Future<T, APIError> { [self] promise in
            
            NetworkMonitor.shared.waitForNetworkStatus {
                guard NetworkMonitor.shared.isConnected else {
                    DispatchQueue.main.async {
                        //                        SheetManager.shared.isOfflineSheetVisible = true
                        //AlertManager.shared.showAlert(title: "No Internet Connection", message: "Please check your internet connection.")
                        if AppState.shared.isLoggedIn{
                            SheetManager.shared.isOfflineSheetVisible = true
                        }else{
                            AlertManager.shared.showAlert(title: "No Internet Connection", message: "Please check your internet connection.")
                        }
                    }
                    return promise(.failure(.noInternetConnection))
                }
            }
            
            if showLoader{
                LoaderManager.shared.showLoader()
                // Retry any pending subscribePlan before firing this request
                if endPoint != .subscribePlan {
                    if Constants.FeatureConfig.isS4Enabled {
                    }
                }
            }
            
            guard let url = self.createURL(with: endPoint.rawValue)
            else {
                return promise(.failure(.badRequest))
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "Authorization")
            if let body = body {
                do {
                    request.httpBody = try? createMultipartBody(with: body, boundary: boundary)
                }
            }
            PrintLogger.log(type: .authToken, message: token)
            PrintLogger.log(type: .apiUrl, message: url.absoluteString)
            PrintLogger.modelLog(body?.parameters, type: .inputParamenters)
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.responseError
                        }
                    }
                    print("Status Code : \(httpResponse.statusCode)")
                    switch httpResponse.statusCode {
                    case 400 :
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.badRequest
                        }
                    case 429 : //insufficient quota or quota exceeded cases
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.insufficientQuota
                        }
                    case 401:
                        throw APIError.unauthorized
                    case 500:
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.internalServerError
                        }
                    case 409: //Someone logged
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Someone logged in your account.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.someOneLoggedInElsewhere
                        }
                    case 403: //Account blocked
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "Your account has been blocked by the admin",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.accountBlocked
                        }
                    case 404: //User not found
                        DispatchQueue.main.async {
                            AlertManager.shared.showAlert(title: "", message: "User not found.",okAction: {
                                AppState.shared.logout()
                                AppIntentRouter.shared.navigate(to: .login)
                            })
                        }
                        if let error = self.extractAPIError(from: result.data, endPoint: endPoint) {
                            throw error
                        }else{
                            throw APIError.notFound
                        }
                    default:
                        return result.data
                    }
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        if showLoader {
                            LoaderManager.shared.hideLoader()
                        }
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.urlError(urlError)))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as APIError:
                            if endPoint == .imageSubscription || endPoint == .voiceSubscription{
                            }else{
                                ToastManager.shared.showToast(message: apiError.localizedDescription,style: .error)
                            }
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.unknown))
                        }
                    }
                }
            receiveValue: {
                if showLoader {
                    LoaderManager.shared.hideLoader()
                }
                promise(.success($0))
            }
            .store(in: &self.subscriptions)
        }
    }
    
    // MARK: - Error Helper
    private func extractAPIError(from data: Data, endPoint: APIEndpoint) -> APIError? {
        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            var finalMessage = apiError.message
            if let errors = apiError.errors, !errors.isEmpty {
                let errorText = errors.map { "\($0.key): \($0.value)" }
                    .joined(separator: ", ")
                finalMessage += " - \(errorText)"
            }
            PrintLogger.log(type: .error, message: "\(endPoint)-\(finalMessage)")
            return .apiError(apiError.message)
        }
        return nil
    }

    private func createMultipartBody<T: Encodable>(with input: MultipartInput<T>, boundary: String) throws -> Data {
        var body = Data()
        
        let encoder = JSONEncoder()
        let parametersData = try encoder.encode(input.parameters)
        let parametersDict = try JSONSerialization.jsonObject(with: parametersData, options: []) as? [String: Any] ?? [:]
        
        for (key, value) in parametersDict {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            
            // Handle arrays and other values differently
            if JSONSerialization.isValidJSONObject(value) {
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    body.append(Data("\(jsonString)\r\n".utf8))
                }
            } else if let number = value as? NSNumber, CFGetTypeID(number) == CFBooleanGetTypeID() {
                body.append(Data("\(number.boolValue)\r\n".utf8))
            } else {
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        
        for (index, obj) in input.fileInput.enumerated() {
            guard !obj.fileData.isEmpty else { continue }
            body.append(Data("--\(boundary)\r\n".utf8))
            //            body.append(Data("Content-Disposition: form-data; name=\"\(obj.fieldName)\"; filename=\"profileImage\(index).png\"\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(obj.fieldName)\"; filename=\"\(obj.fileName)\"\r\n".utf8))
            body.append(Data("Content-Type: \(obj.mimeType)\r\n\r\n".utf8))
            body.append(obj.fileData)
            body.append(Data("\r\n".utf8))
        }
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body
    }
}
