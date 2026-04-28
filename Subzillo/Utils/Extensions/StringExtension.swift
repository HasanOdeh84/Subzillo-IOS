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
}
