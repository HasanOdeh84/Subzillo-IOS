// ContentView.swift

import SwiftUI

struct ContentView: View {

    @StateObject private var chatVM    = ChatViewModel()
    @State private var showDebugLog    = false

    var body: some View {
        NavigationStack {
            ChatView(viewModel: chatVM)
                .navigationTitle("Subzillo AI")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button {
                                showDebugLog = true
                            } label: {
                                Label("Debug Logs", systemImage: "terminal")
                            }
                            Divider()
                            Button(role: .destructive) {
                                NavigationMemory.shared.clearAll()
                                DebugLogger.shared.log("✅ Navigation memory cleared", tag: "MEMORY")
                            } label: {
                                Label("Clear Saved Routes", systemImage: "trash.circle")
                            }
                        } label: {
                            Image(systemName: "bolt.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showDebugLog = true
                        } label: {
                            Image(systemName: "terminal")
                                .foregroundColor(.secondary)
                        }
                    }
                }
        }
        .sheet(isPresented: $showDebugLog) {
            DebugLogView()
        }
    }
}

// MARK: - Debug Log Panel

struct DebugLogView: View {

    @ObservedObject private var logger = DebugLogger.shared
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var filtered: [DebugLogger.LogEntry] {
        guard !searchText.isEmpty else { return logger.entries }
        let q = searchText.lowercased()
        return logger.entries.filter { $0.display.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List(filtered) { entry in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(entry.tag)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(tagColor(entry.tag).opacity(0.2))
                                .foregroundColor(tagColor(entry.tag))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            Text(entry.timestamp)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Text(entry.message)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                    }
                    .id(entry.id)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Filter logs…")
                .onChange(of: logger.entries.count) {
                    if let last = filtered.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
                .onAppear {
                    if let last = filtered.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .navigationTitle("Debug Log (\(logger.entries.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(role: .destructive) {
                            logger.clear()
                        } label: {
                            Label("Clear Logs", systemImage: "trash")
                        }
                        Button(role: .destructive) {
                            NavigationMemory.shared.clearAll()
                            logger.log("⚠️ All navigation memory cleared", tag: "MEMORY")
                        } label: {
                            Label("Clear All Memory", systemImage: "brain.slash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func tagColor(_ tag: String) -> Color {
        switch tag {
        case "STEP":   return .blue
        case "CLAUDE": return .purple
        case "TEXT":   return .green
        case "ELEM":   return .orange
        case "ACTION": return .red
        case "URL":    return .teal
        case "MEMORY": return .brown
        case "ERROR":  return .red
        default:       return .secondary
        }
    }
}

#Preview {
    ContentView()
}
