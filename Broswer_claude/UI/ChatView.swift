// ChatView.swift

import SwiftUI

struct ChatView: View {

    @ObservedObject var viewModel: ChatViewModel
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { msg in
                            MessageBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .onChange(of: viewModel.messages.count) {
                    if let last = viewModel.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()
            inputBar
        }
        .sheet(isPresented: $viewModel.showBrowser) {
            NavigationStack {
                BrowserView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask me about your subscriptions…", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .focused($inputFocused)
                .disabled(viewModel.isProcessing)
                .onSubmit { viewModel.send() }

            Button {
                inputFocused = false
                viewModel.send()
            } label: {
                Image(systemName: viewModel.isProcessing ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(viewModel.isProcessing ? .red : .blue)
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty && !viewModel.isProcessing)
            .onTapGesture {
                if viewModel.isProcessing { viewModel.cancelTask() }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {

    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top) {
            if message.sender == .user { Spacer(minLength: 50) }

            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 6) {
                // Plain text part
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(bubbleColor)
                        .foregroundColor(textColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .textSelection(.enabled)
                }

                // Rich subscription card (if available)
                if let fields = message.subscriptionData {
                    SubscriptionCard(fields: fields)
                }
            }

            if message.sender != .user { Spacer(minLength: 50) }
        }
    }

    private var bubbleColor: Color {
        switch message.sender {
        case .user:      return .blue
        case .assistant: return Color(.secondarySystemBackground)
        case .system:    return Color(.tertiarySystemBackground)
        }
    }

    private var textColor: Color {
        message.sender == .user ? .white : .primary
    }
}

// MARK: - Subscription Card

struct SubscriptionCard: View {

    let fields: ExtractedFields

    private var statusColor: Color {
        switch fields.status?.lowercased() {
        case "active":     return .green
        case "cancelled":  return .red
        case "trial":      return .orange
        default:           return .secondary
        }
    }

    private var priceDisplay: String {
        guard let p = fields.price else { return "" }
        var result = p
        if let cycle = fields.billingCycle {
            result += " / \(cycle.lowercased())"
        }
        // Only prepend currency CODE when the price doesn't already carry a symbol
        // (avoids "USD $200" when price is already "$200")
        let hasSymbol = ["$","€","£","¥","₹","₩","₽","₺","₴","৳","฿","₫"].contains { p.contains($0) }
        if let curr = fields.currency, !result.uppercased().contains(curr), !hasSymbol {
            result = "\(curr) \(result)"
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)

                Text(fields.serviceName ?? "Subscription")
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)

                Spacer()

                if let status = fields.status {
                    Text(status)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.15))
                        .foregroundColor(statusColor)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 16)

            // ── Details ─────────────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {

                if let plan = fields.plan {
                    CardRow(icon: "star.fill", iconColor: .purple, label: "Plan", value: plan)
                }

                if !priceDisplay.isEmpty {
                    CardRow(icon: "banknote.fill", iconColor: .green, label: "Amount", value: priceDisplay, valueWeight: .bold)
                }

                if let date = fields.billingDate {
                    CardRow(icon: "calendar", iconColor: .orange, label: "Next Payment", value: date)
                }

                if let payment = fields.paymentMethod {
                    CardRow(icon: "creditcard", iconColor: .blue, label: "Payment", value: payment)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .padding(.vertical, 2)
    }
}

// MARK: - Card Row

struct CardRow: View {

    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    var valueWeight: Font.Weight = .regular

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(minWidth: 90, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .fontWeight(valueWeight)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChatView(viewModel: ChatViewModel())
            .navigationTitle("Subzillo AI")
            .navigationBarTitleDisplayMode(.inline)
    }
}
