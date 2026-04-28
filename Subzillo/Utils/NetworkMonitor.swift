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
    static let shared                   = NetworkMonitor()
    let monitor                         = NWPathMonitor()
    let queue                           = DispatchQueue(label: "NetworkMonitorQueue")
    @Published var isConnected          = false
    @Published var connectionType       : NWPath.Status = .unsatisfied
    private var statusUpdateHandler     : ((Bool) -> Void)?
    private var isNetworkStatusKnown    = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async { // Update UI on the main thread
                self.isConnected = path.status == .satisfied
                self.connectionType = path.status
                self.isNetworkStatusKnown = true
                // Notify listeners that the network status has been updated
                self.statusUpdateHandler?(self.isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    func waitForNetworkStatus(completion: @escaping () -> Void) {
        if isNetworkStatusKnown {
            completion()
        } else {
            self.statusUpdateHandler = { isConnected in
                if isConnected {
                    completion()
                } else {
                    print("No network connection available.")
                }
            }
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
