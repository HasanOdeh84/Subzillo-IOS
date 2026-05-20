//
//  StringExtension.swift
//  Subzillo
//
//  Created by swathipriya pattem on 09/02/26.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func htmlToAttributedString() -> AttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            let nsAttributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            
            return AttributedString(nsAttributedString)
        } catch {
            print("HTML parsing error:", error)
            return nil
        }
    }
    
    func daysDifferenceFromToday(
        format: String = "d/M/yyyy"
    ) -> Int? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let targetDate = formatter.date(from: self) else {
            return nil
        }
        
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        
        return calendar.dateComponents(
            [.day],
            from: today,
            to: target
        ).day
    }
    
    var billingCycleShortForm: String {
        
        switch self.lowercased() {
            
        case "daily":
            return "da"
            
        case "weekly":
            return "we"
            
        case "monthly":
            return "mo"
            
        case "quarterly":
            return "qu"
            
        case "biannually":
            return "bi"
            
        case "yearly":
            return "ye"
            
        default:
            return ""
        }
    }
}
