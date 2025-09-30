//
//  NetworkMonitor.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared   = NetworkMonitor()
    let monitor         = NWPathMonitor()
    let queue           = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected = false
    @Published var connectionType: NWPath.Status = .unsatisfied // More detailed status

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async { // Update UI on the main thread
                self.isConnected = path.status == .satisfied
                self.connectionType = path.status
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
