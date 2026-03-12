import SwiftUI

struct NewTunnelView: View {
    @ObservedObject var formVM: TunnelFormViewModel
    var onTunnelStarted: () -> Void

    private let protocols = ["http", "tcp", "tls"]

    var body: some View {
        VStack(spacing: 8) {
            // Header with history toggle
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.green)
                Text("New Tunnel")
                    .font(.subheadline.bold())
                Spacer()
                if !formVM.history.isEmpty {
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { formVM.showHistory.toggle() } }) {
                        HStack(spacing: 3) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.caption)
                            Text("History")
                                .font(.caption)
                        }
                        .foregroundStyle(formVM.showHistory ? Color.accentColor : Color.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            // History list
            if formVM.showHistory {
                historySection
            }

            // Input row
            HStack(spacing: 6) {
                Picker("", selection: $formVM.proto) {
                    ForEach(protocols, id: \.self) { p in
                        Text(p.uppercased()).tag(p)
                    }
                }
                .labelsHidden()
                .frame(width: 80)

                TextField("Port", text: $formVM.port)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 0.5)
                    )
                    .frame(width: 65)

                TextField("Domain (optional)", text: $formVM.domain)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 0.5)
                    )

                Button(action: { formVM.startTunnel(onStarted: onTunnelStarted) }) {
                    if formVM.isLaunching {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "play.fill")
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(formVM.port.isEmpty || formVM.isLaunching)
            }

            if let error = formVM.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if let success = formVM.successMessage {
                Text(success)
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding(10)
        .background(Color.primary.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green.opacity(0.3), lineWidth: 0.5)
        )
        .cornerRadius(8)
    }

    private var historySection: some View {
        VStack(spacing: 4) {
            ForEach(formVM.history) { item in
                HStack(spacing: 6) {
                    Button(action: { formVM.applyHistoryItem(item) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(item.displayLabel)
                                .font(.system(.caption, design: .monospaced))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.primary.opacity(0.04))
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .cursor(.pointingHand)

                    // Quick launch button
                    Button(action: {
                        formVM.applyHistoryItem(item)
                        formVM.startTunnel(onStarted: onTunnelStarted)
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                    .help("Launch immediately")

                    Button(action: { formVM.removeHistoryItem(item) }) {
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                    .help("Remove from history")
                }
            }

            if formVM.history.count > 1 {
                Button(action: { formVM.clearHistory() }) {
                    Text("Clear All")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}
