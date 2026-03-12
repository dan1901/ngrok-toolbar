import SwiftUI

struct SessionsTabView: View {
    let sessions: [TunnelSession]
    let isLoading: Bool
    let onRestart: (String) async -> Void
    let onStop: (String) async -> Void

    var body: some View {
        Group {
            if isLoading && sessions.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if sessions.isEmpty {
                emptyState
            } else {
                sessionList
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "server.rack")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No active sessions")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sessionList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(sessions) { session in
                    SessionCardView(session: session, onRestart: onRestart, onStop: onStop)
                }
            }
            .padding(12)
        }
    }
}

struct SessionCardView: View {
    let session: TunnelSession
    let onRestart: (String) async -> Void
    let onStop: (String) async -> Void

    @State private var showStopConfirm = false
    @State private var isProcessing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                Text(session.ip)
                    .font(.system(.body, design: .monospaced))
                Spacer()
                actionButtons
            }

            HStack(spacing: 12) {
                if let version = session.agentVersion {
                    Label("v\(version)", systemImage: "app.badge")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Label(session.region.uppercased(), systemImage: "globe")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let os = session.os {
                    Label(os, systemImage: "desktopcomputer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .alert("Stop Session?", isPresented: $showStopConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Stop", role: .destructive) {
                Task {
                    isProcessing = true
                    await onStop(session.id)
                    isProcessing = false
                }
            }
        } message: {
            Text("This will stop the agent session at \(session.ip).")
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button(action: {
                Task {
                    isProcessing = true
                    await onRestart(session.id)
                    isProcessing = false
                }
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .help("Restart")
            .disabled(isProcessing)

            Button(action: { showStopConfirm = true }) {
                Image(systemName: "stop.circle")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .help("Stop")
            .disabled(isProcessing)
        }
    }
}
