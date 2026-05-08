import Foundation

struct QuickReplyDetector {
    
    static func detect(content: String) -> [String] {
        let text = content.lowercased()
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return [] }
        
        // 1. Switch Options
        let switchOptions = extractSwitchOptions(content: content)
        if !switchOptions.isEmpty {
            return switchOptions
        }
        
        // 2. Generic Reply Choices (from "Reply: Yes or No")
        let genericReplyChoices = extractReplyChoices(content: content)
        if genericReplyChoices.count >= 2 {
            return genericReplyChoices
        }
        
        // 3. Update or Add New
        if has(text: text, patterns: [
            "do you want to update the existing one or add this as a new entry",
            "update the existing one or add this as a new entry",
            "already have .* in your list"
        ], isRegex: true) {
            return ["Update", "Add new", "Cancel", "Skip"]
        }
        
        // 4. Yes/No patterns
        if has(text: text, patterns: [
            "reply with\\s+\\*\\*yes\\*\\*\\s+to start adding,\\s+or\\s+\\*\\*no\\*\\*\\s+to skip",
            "would you like to add your first one",
            "to continue, reply\\s+\\*\\*yes\\*\\*\\s+or\\s+\\*\\*no\\*\\*",
            "before deleting it, choose one option",
            "reply \\*\\*yes\\*\\* or \\*\\*delete\\*\\*",
            "reply \\*\\*no\\*\\* or \\*\\*keep\\*\\*",
            "\\bdid you want to save that one\\b",
            "\\bdo you want to save (?:that|this|it)\\b",
            "\\bwould you like me to save (?:that|this|it)\\b",
            "\\(\\s*yes\\s*\\/\\s*no\\s*\\)\\s*[:?]?$",
            "\\bshall i proceed with saving this\\b",
            "\\bshall i proceed\\b.*\\(\\s*yes\\s*\\/\\s*no\\s*\\)",
            "\\bproceed with saving\\b.*\\(\\s*yes\\s*\\/\\s*no\\s*\\)",
            "save anyway\\?"
        ], isRegex: true) {
            if has(text: text, patterns: ["save anyway\\?", "reply:\\s+\\*\\*save anyway\\*\\*"], isRegex: true) {
                return ["Save anyway", "Skip"]
            }
            return ["Yes", "No"]
        }
        
        // 5. Bulk adding
        if has(text: text, patterns: [
            "add all(?:\\s+at\\s+once)?",
            "one by one",
            "start adding these one by one"
        ], isRegex: true) {
            return ["Add one by one", "Add all at once", "Skip"]
        }
        
        if has(text: text, patterns: ["or say 'add all'", "which would you like to add: .*or say 'add all'"], isRegex: true) {
            return ["Add all at once", "Skip"]
        }
        
        // 6. Plan Options (Numbered list)
        if has(text: text, patterns: [
            "\\bwhich plan do you want\\b",
            "\\bwhich plan .* would you like to add\\b",
            "\\breply with a number\\b",
            "\\bselect the number\\b",
            "\\bavailable plans\\b"
        ], isRegex: true) {
            let planOptions = extractPlanOptions(content: content)
            if !planOptions.isEmpty {
                var options = planOptions
                options.append(contentsOf: ["Manual", "Skip"])
                return options
            }
        }
        
        // 7. Manual prompt
        if has(text: text, patterns: [
            "reply with a number, or say \\*\\*manual\\*\\*",
            "reply with a number, or say manual",
            "you can pick from the current list, or say \\*\\*manual\\*\\*",
            "you can pick from the current list, or say manual"
        ], isRegex: true) {
            return ["Manual", "Skip"]
        }
        
        return []
    }
    
    private static func has(text: String, patterns: [String], isRegex: Bool = false) -> Bool {
        for pattern in patterns {
            if isRegex {
                if text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil {
                    return true
                }
            } else {
                if text.localizedCaseInsensitiveContains(pattern) {
                    return true
                }
            }
        }
        return false
    }
    
    private static func extractSwitchOptions(content: String) -> [String] {
        let compact = content.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
        
        let pattern = "would you like to switch to\\s+(.+?)\\s+or\\s+finish with\\s+(.+?)\\s+first\\??"
        if let range = compact.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
            // Very basic capture group emulation for simplicity
            // In a real app we'd use NSRegularExpression for proper groups
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let nsString = compact as NSString
                let results = regex.matches(in: compact, options: [], range: NSRange(location: 0, length: nsString.length))
                if let result = results.first, result.numberOfRanges > 2 {
                    let target = nsString.substring(with: result.range(at: 1)).trimmingCharacters(in: .whitespaces)
                    let current = nsString.substring(with: result.range(at: 2)).trimmingCharacters(in: .whitespaces)
                    if !target.isEmpty && !current.isEmpty {
                        return ["Switch to \(target)", "Finish with \(current) first", "Cancel"]
                    }
                }
            }
        }
        
        let hasSwitch = compact.range(of: "would you like to switch", options: .caseInsensitive) != nil
        let hasFinish = compact.range(of: "\\bfinish\\b.*\\bfirst\\b", options: [.regularExpression, .caseInsensitive]) != nil
        if hasSwitch && hasFinish {
            return ["Switch", "Finish current first", "Cancel"]
        }
        
        return []
    }
    
    private static func extractReplyChoices(content: String) -> [String] {
        let lines = content.components(separatedBy: .newlines)
        guard let replyLine = lines.first(where: { $0.range(of: "^\\s*reply\\s*:", options: [.regularExpression, .caseInsensitive]) != nil }) else {
            return []
        }
        
        let right = replyLine.replacingOccurrences(of: "^\\s*reply\\s*:", with: "", options: [.regularExpression, .caseInsensitive]).trimmingCharacters(in: .whitespaces)
        if right.isEmpty { return [] }
        
        // Split by " or ", ",", and "/"
        let chunks = right.components(separatedBy: CharacterSet(charactersIn: ",/"))
            .flatMap { $0.components(separatedBy: " or ") }
            .map { normalizeChoiceLabel($0) }
            .filter { !$0.isEmpty }
        
        var unique: [String] = []
        for item in chunks {
            if !unique.contains(item) {
                unique.append(item)
            }
        }
        
        return Array(unique.prefix(6))
    }
    
    private static func normalizeChoiceLabel(_ raw: String) -> String {
        let cleaned = raw.replacingOccurrences(of: "\\*\\*", with: "", options: .regularExpression)
            .replacingOccurrences(of: "[().:?]+$", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        
        if cleaned.isEmpty { return "" }
        
        let low = cleaned.lowercased()
        switch low {
        case "add new": return "Add new"
        case "update": return "Update"
        case "cancel": return "Cancel"
        case "skip": return "Skip"
        case "manual": return "Manual"
        case "yes": return "Yes"
        case "no": return "No"
        default:
            return cleaned.prefix(1).uppercased() + cleaned.dropFirst()
        }
    }
    
    private static func extractPlanOptions(content: String) -> [String] {
        let lines = content.components(separatedBy: .newlines)
        var options: [String] = []
        
        let pattern = "^(\\d+)[\\)\\.]\\s+(.+)$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        
        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            let nsString = line as NSString
            let results = regex.matches(in: line, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if let result = results.first, result.numberOfRanges > 2 {
                let idx = nsString.substring(with: result.range(at: 1))
                let label = nsString.substring(with: result.range(at: 2)).trimmingCharacters(in: .whitespaces)
                if !label.isEmpty {
                    options.append("\(idx)) \(label)")
                }
            }
        }
        
        return Array(options.prefix(10))
    }
}
