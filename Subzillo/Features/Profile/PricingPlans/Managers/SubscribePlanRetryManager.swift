//
//  SubscribePlanRetryManager.swift
//  Subzillo
//

import Foundation
import Combine

final class SubscribePlanRetryManager {

    static let shared = SubscribePlanRetryManager()
    private init() {}

    private var subscriptions = Set<AnyCancellable>()
    private var isRetrying    = false
    var apiReference          = NetworkRequest.shared

    // MARK: - Public entry point

    func retryIfNeeded() {
        guard !isRetrying else { return }
        let hasFailed = Constants.getUserDefaultsBooleanValue(for: Constants.subscribeApiFail)
        guard hasFailed, let pending = loadPendingRequest() else { return }

        isRetrying = true
        print("[SubscribePlanRetryManager] Retrying pending subscribePlan...")

        apiReference
            .postApi(
                endPoint    : .subscribePlan,
                method      : .POST,
                token       : authKey,
                body        : pending,
                showLoader  : false,
                responseType: GeneralResponse.self
            )
            .sink { [weak self] completion in
                guard let self else { return }
                self.isRetrying = false
                if case .failure(let error) = completion {
                    print("[SubscribePlanRetryManager] Retry failed: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                print("[SubscribePlanRetryManager] Retry succeeded: \(response.message ?? "")")
                Constants.saveDefaults(value: false, key: Constants.subscribeApiFail)
                self.clearPendingRequest()
            }
            .store(in: &subscriptions)
    }

    // MARK: - Persistence helpers
    private func loadPendingRequest() -> SubscribePlanRequest? {
        guard let data = UserDefaults.standard.data(forKey: Constants.pendingSubscribePlan),
              let request = try? JSONDecoder().decode(SubscribePlanRequest.self, from: data) else {
            return nil
        }
        return request
    }

    private func clearPendingRequest() {
        Constants.removeDefaults(key: Constants.pendingSubscribePlan)
    }
}
