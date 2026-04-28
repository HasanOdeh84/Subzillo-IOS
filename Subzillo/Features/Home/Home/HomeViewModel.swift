//
//  HomeViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 13/11/25.
//

import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    
    private var subscriptions               = Set<AnyCancellable>()
    var apiReference                        = NetworkRequest.shared
    private let router                      : AppIntentRouter
    @Published var homeResponse             : HomeResponseData?
    @Published var homeYearGraphResponse    : HomeYearlyGraphData?
    @Published var apiError                 : APIError? = nil
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func home(input: HomeRequest) {
        self.apiError = nil
        apiReference.postApi(endPoint: APIEndpoint.home, method: .POST,token: authKey,body: input,showLoader: true, responseType: HomeResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.home)
                    self?.apiError = error
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self?.homeResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func homeYearlyGraph(input: HomeYearlyGraphRequest) {
        self.homeYearGraphResponse = nil
        apiReference.postApi(endPoint: APIEndpoint.homeYearlyGraph, method: .POST,token: authKey,body: input,showLoader: true, responseType: HomeYearlyGraphResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.homeYearlyGraph)
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self?.homeYearGraphResponse = response.data
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
