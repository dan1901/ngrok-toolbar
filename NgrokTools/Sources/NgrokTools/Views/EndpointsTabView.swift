import SwiftUI

struct EndpointsTabView: View {
    let endpoints: [Endpoint]
    let isLoading: Bool
    let onDelete: (String) async -> Void

    var body: some View {
        Group {
            if isLoading && endpoints.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if endpoints.isEmpty {
                emptyState
            } else {
                endpointList
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "link")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No endpoints")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var endpointList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(endpoints) { endpoint in
                    EndpointCardView(endpoint: endpoint, onDelete: onDelete)
                }
            }
            .padding(12)
        }
    }
}

struct EndpointCardView: View {
    let endpoint: Endpoint
    let onDelete: (String) async -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if let url = endpoint.url {
                    Text(url)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(1)
                }
                Spacer()
                Button(action: { showDeleteConfirm = true }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .help("Delete")
            }

            HStack(spacing: 12) {
                if let proto = endpoint.proto {
                    Label(proto.uppercased(), systemImage: "lock.shield")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let upstream = endpoint.upstreamURL {
                    Label(upstream, systemImage: "arrow.right")
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
        .alert("Delete Endpoint?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task { await onDelete(endpoint.id) }
            }
        } message: {
            Text("This endpoint will be permanently deleted.")
        }
    }
}
