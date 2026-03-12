import SwiftUI

struct TunnelsTabView: View {
    let tunnels: [Tunnel]
    let isLoading: Bool

    var body: some View {
        Group {
            if isLoading && tunnels.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if tunnels.isEmpty {
                emptyState
            } else {
                tunnelList
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "network.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No active tunnels")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tunnelList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(tunnels) { tunnel in
                    TunnelCardView(tunnel: tunnel)
                }
            }
            .padding(12)
        }
    }
}

struct TunnelCardView: View {
    let tunnel: Tunnel

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
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    private func copyURL() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(tunnel.publicURL, forType: .string)
    }
}
