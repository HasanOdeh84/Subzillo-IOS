import Foundation
import SwiftUI

class ConnectedEmailsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var connectedEmails: [ConnectedEmail] = []
    
    var filteredEmails: [ConnectedEmail] {
        if searchText.isEmpty {
            return connectedEmails
        } else {
            return connectedEmails.filter { $0.email.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    init() {
        // Mock data based on the provided image
        connectedEmails = [
            ConnectedEmail(email: "mahesh@gmail.com", date: "1/11/25", status: .syncing, provider: .gmail),
            ConnectedEmail(email: "mahesh@outlook.com", date: "1/11/25", status: .view, provider: .outlook),
            ConnectedEmail(email: "mahesh@outlook.com", date: "1/11/25", status: .sync, provider: .outlook)
        ]
    }
    
    func deleteEmail(_ email: ConnectedEmail) {
        connectedEmails.removeAll { $0.id == email.id }
    }
    
    func syncEmail(_ email: ConnectedEmail) {
        print("Syncing email: \(email.email)")
    }
    
    func viewEmail(_ email: ConnectedEmail) {
        print("Viewing email: \(email.email)")
    }
}
