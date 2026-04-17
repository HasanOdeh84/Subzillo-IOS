// DebugLogger.swift
// Thread-safe in-memory log buffer.
// Writes to Xcode console AND stores entries for the in-app debug panel.

import Foundation
import Combine

final class DebugLogger: ObservableObject {

    static let shared = DebugLogger()

    @Published private(set) var entries: [LogEntry] = []

    private let maxEntries = 300
    private let queue = DispatchQueue(label: "com.subzillo.debuglog", qos: .utility)

    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: String
        let tag: String
        let message: String

        var display: String { "[\(timestamp)] [\(tag)] \(message)" }
    }

    private static let fmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()

    // MARK: - Log

    func log(_ message: String, tag: String = "APP") {
        let ts = Self.fmt.string(from: Date())
        let entry = LogEntry(timestamp: ts, tag: tag, message: message)
        print("[\(ts)][\(tag)] \(message)")      // Xcode console
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.entries.append(entry)
            if self.entries.count > self.maxEntries {
                self.entries.removeFirst(self.entries.count - self.maxEntries)
            }
        }
    }

    func clear() {
        DispatchQueue.main.async { self.entries = [] }
    }
}

// MARK: - Convenience global

func dlog(_ message: String, tag: String = "APP") {
    DebugLogger.shared.log(message, tag: tag)
}
