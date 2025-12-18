//
//  Extensions.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import Foundation
extension Encodable {
  func encodePrint() -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
      let jsonData = try encoder.encode(self)
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
      }
    } catch {
      print("Error encoding JSON: \(error)")
    }
    return nil
  }
}

// For String
extension Optional where Wrapped == String {
  var orEmpty: String {
    return self ?? ""
  }
}

extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    func formattedDate(from inputFormat: String = "yyyy-MM-dd",
                       to outputFormat: String = "MMM d, yyyy") -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        guard let date = inputFormatter.date(from: self) else { return self }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat
        return outputFormatter.string(from: date)
    }
    
    func normalizedPhoneNumber() -> String {
        return self.filter { $0.isNumber }
    }
}

func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%02d:%02d", minutes, seconds)
}

// Array safe subscript to avoid index out of range
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
