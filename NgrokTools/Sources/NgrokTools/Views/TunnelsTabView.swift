import SwiftUI

struct TunnelsTabView: View {
    let tunnels: [Tunnel]
    let isLoading: Bool
    @ObservedObject var formVM: TunnelFormViewModel
    var onRefresh: () -> Void = {}

    @State private var selectedTunnel: Tunnel?
    @State private var stoppingTunnelIds: Set<String> = []

    var body: some View {
        VStack(spacing: 0) {
            if let tunnel = selectedTunnel {
                TunnelDetailView(tunnel: tunnel, onBack: {
                    selectedTunnel = nil
                })
            } else {
                tunnelListContent
            }
        }
    }

    private var tunnelListContent: some View {
        VStack(spacing: 0) {
            if isLoading && tunnels.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if tunnels.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "network.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No active tunnels")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(tunnels) { tunnel in
                            TunnelCardView(
                                tunnel: tunnel,
                                isStopping: stoppingTunnelIds.contains(tunnel.id),
                                onStop: {
                                    Task { await stopTunnel(tunnel) }
                                }
                            )
                            .onTapGesture {
                                if !stoppingTunnelIds.contains(tunnel.id) {
                                    selectedTunnel = tunnel
                                }
                            }
                            .cursor(.pointingHand)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                }
            }

            Divider()
            NewTunnelView(formVM: formVM, onTunnelStarted: onRefresh)
                .padding(12)
        }
    }

    private func stopTunnel(_ tunnel: Tunnel) async {
        stoppingTunnelIds.insert(tunnel.id)
        defer {
            stoppingTunnelIds.remove(tunnel.id)
        }

        var stopped = false

        // 1) Try local ngrok API
        let inspectService = LocalInspectService()
        do {
            try await inspectService.stopTunnel(publicURL: tunnel.publicURL)
            stopped = true
        } catch {
            print("[StopTunnel] Local API failed: \(error)")
        }

        // 2) Fallback: stop via TunnelLauncher (locally launched)
        if !stopped, let forwardsTo = tunnel.forwardsTo,
           let port = extractPort(from: forwardsTo) {
            if TunnelLauncher.shared.isRunning(port: port) {
                TunnelLauncher.shared.stopTunnel(port: port)
                stopped = true
            }
        }

        // 3) Last resort: kill ngrok processes matching the port
        if !stopped, let forwardsTo = tunnel.forwardsTo,
           let port = extractPort(from: forwardsTo) {
            killNgrokProcess(port: port)
            stopped = true
        }

        // Refresh after delay to let API catch up
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        onRefresh()
    }

    private func extractPort(from forwardsTo: String) -> Int? {
        if let colonRange = forwardsTo.range(of: ":", options: .backwards) {
            let portStr = forwardsTo[colonRange.upperBound...]
            return Int(portStr)
        }
        return nil
    }

    private func killNgrokProcess(port: Int) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        process.arguments = ["-f", "ngrok.*\(port)"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try? process.run()
        process.waitUntilExit()
    }
}

struct TunnelCardView: View {
    let tunnel: Tunnel
    var isStopping: Bool = false
    var onStop: (() -> Void)?

    @State private var showStopConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                Text(tunnel.publicURL)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                Spacer()

                Button(action: { showStopConfirm = true }) {
                    if isStopping {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Image(systemName: "stop.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.8))
                    }
                }
                .buttonStyle(.plain)
                .disabled(isStopping)
                .help("Stop tunnel")

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Button(action: copyURL) {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Copy URL")
            }

            HStack(spacing: 12) {
                Label(tunnel.proto.uppercased(), systemImage: "lock.shield")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label(tunnel.region.uppercased(), systemImage: "globe")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let forwardsTo = tunnel.forwardsTo {
                    Label(forwardsTo, systemImage: "arrow.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color.primary.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .cornerRadius(8)
        .alert("Stop Tunnel?", isPresented: $showStopConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Stop", role: .destructive) {
                onStop?()
            }
        } message: {
            Text("Terminate \(tunnel.publicURL)?")
        }
    }

    private func copyURL() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(tunnel.publicURL, forType: .string)
    }
}

extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
