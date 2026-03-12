import SwiftUI

struct TunnelDetailView: View {
    let tunnel: Tunnel
    var onBack: () -> Void

    @State private var requests: [InspectRequest] = []
    @State private var localTunnel: LocalTunnel?
    @State private var isLoading = false
    @State private var isLive = true
    @State private var errorMessage: String?
    @State private var selectedRequest: InspectRequest?
    @State private var inspectAvailable = true
    @State private var inspectPort: Int?
    @State private var timer: Timer?

    private let service = LocalInspectService()
    private let refreshInterval: TimeInterval = 2.0

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if !inspectAvailable {
                unavailableView
            } else if isLoading && requests.isEmpty && localTunnel == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if let selected = selectedRequest {
                    requestDetailView(selected)
                } else {
                    mainContent
                }
            }
        }
        .task {
            // Find the inspect port that serves THIS tunnel
            if let port = await service.findInspectPort(forPublicURL: tunnel.publicURL) {
                inspectPort = port
                inspectAvailable = true
                await loadAll()
                startLiveTail()
            } else {
                inspectAvailable = false
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            Button(action: {
                if selectedRequest != nil {
                    selectedRequest = nil
                } else {
                    onBack()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.caption.bold())
            }
            .buttonStyle(.plain)

            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)

            Text(tunnel.publicURL)
                .font(.system(.caption, design: .monospaced))
                .lineLimit(1)

            Spacer()

            if inspectAvailable && selectedRequest == nil {
                Button(action: { isLive.toggle() }) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isLive ? .red : .gray)
                            .frame(width: 6, height: 6)
                        Text(isLive ? "LIVE" : "PAUSED")
                            .font(.system(.caption2, design: .monospaced))
                    }
                }
                .buttonStyle(.plain)

                Button(action: { Task { await loadAll() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Main Content (metrics + traffic)

    private var sortedRequests: [InspectRequest] {
        requests.sorted { a, b in
            // desc by start time (newest first)
            a.start > b.start
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Tunnel info (fixed, not scrollable)
            if let lt = localTunnel {
                tunnelInfoSection(lt)
                Divider()
            }

            // Traffic section (separate scroll)
            if requests.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Waiting for traffic...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("HTTP requests through this tunnel will appear here")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Text("Traffic (\(requests.count))")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)

                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(sortedRequests) { req in
                                    RequestRowView(request: req)
                                        .id(req.id)
                                        .onTapGesture { selectedRequest = req }
                                        .padding(.horizontal, 12)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        .onChange(of: requests.first?.id) { oldVal, newVal in
                            guard oldVal != newVal else { return }
                            if let firstId = sortedRequests.first?.id {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(firstId, anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tunnel Info

    private func tunnelInfoSection(_ lt: LocalTunnel) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                infoItem(icon: "arrow.right", label: "Forward", value: lt.config?.addr ?? "-")
                infoItem(icon: "lock.shield", label: "Proto", value: lt.proto.uppercased())
                if let conns = lt.metrics?.conns {
                    infoItem(icon: "link", label: "Conns", value: "\(conns.count)")
                }
                if let http = lt.metrics?.http {
                    infoItem(icon: "network", label: "Requests", value: "\(http.count)")
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.primary.opacity(0.04))
    }

    private func infoItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Request Detail

    private func requestDetailView(_ req: InspectRequest) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(req.request.method)
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(methodColor(req.request.method))
                        .cornerRadius(4)

                    Text(req.request.uri)
                        .font(.system(.caption, design: .monospaced))
                        .lineLimit(2)
                }

                if let resp = req.response {
                    HStack(spacing: 8) {
                        Text("\(resp.statusCode)")
                            .font(.system(.caption, design: .monospaced).bold())
                            .foregroundStyle(statusColor(resp.statusCode))
                        Text(resp.status)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(req.durationMs)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                Text("Request Headers")
                    .font(.caption.bold())
                headersList(req.request.headers)

                if let resp = req.response {
                    Divider()
                    Text("Response Headers")
                        .font(.caption.bold())
                    headersList(resp.headers)
                }

                if let raw = req.request.raw, !raw.isEmpty {
                    Divider()
                    Text("Request Body")
                        .font(.caption.bold())
                    bodyView(raw)
                }

                if let raw = req.response?.raw, !raw.isEmpty {
                    Divider()
                    Text("Response Body")
                        .font(.caption.bold())
                    bodyView(raw)
                }
            }
            .padding(12)
        }
    }

    private func headersList(_ headers: [String: [String]]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(headers.keys.sorted(), id: \.self) { key in
                if let values = headers[key] {
                    ForEach(values, id: \.self) { value in
                        HStack(alignment: .top, spacing: 4) {
                            Text(key + ":")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                            Text(value)
                                .font(.system(.caption2, design: .monospaced))
                                .lineLimit(3)
                        }
                    }
                }
            }
        }
    }

    private func bodyView(_ raw: String) -> some View {
        let body: String = {
            if let range = raw.range(of: "\r\n\r\n") {
                return String(raw[range.upperBound...])
            } else if let range = raw.range(of: "\n\n") {
                return String(raw[range.upperBound...])
            }
            return raw
        }()

        return Text(body.prefix(2000))
            .font(.system(.caption2, design: .monospaced))
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(6)
    }

    // MARK: - Unavailable

    private var unavailableView: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Inspect API not available")
                .foregroundStyle(.secondary)
            Text("ngrok inspect runs at 127.0.0.1:4040\nMake sure a tunnel is running locally")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Data Loading

    private func loadAll() async {
        guard let port = inspectPort else { return }
        isLoading = true
        defer { isLoading = false }

        if let tunnels = try? await service.fetchLocalTunnels(port: port) {
            localTunnel = tunnels.first(where: { $0.publicURL == tunnel.publicURL })
        }

        if let fetched = try? await service.fetchRequests(port: port) {
            requests = fetched
        }
    }

    private func startLiveTail() {
        guard let port = inspectPort else { return }
        let t = Timer(timeInterval: refreshInterval, repeats: true) { [self] _ in
            guard isLive else { return }
            Task { @MainActor in
                if let tunnels = try? await service.fetchLocalTunnels(port: port) {
                    localTunnel = tunnels.first(where: { $0.publicURL == tunnel.publicURL })
                }
                if let fetched = try? await service.fetchRequests(port: port) {
                    requests = fetched
                }
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    // MARK: - Helpers

    private func methodColor(_ method: String) -> Color {
        switch method.uppercased() {
        case "GET": return .blue
        case "POST": return .green
        case "PUT", "PATCH": return .orange
        case "DELETE": return .red
        default: return .gray
        }
    }

    private func statusColor(_ code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .blue
        case 400..<500: return .orange
        case 500...: return .red
        default: return .primary
        }
    }
}

struct RequestRowView: View {
    let request: InspectRequest

    var body: some View {
        HStack(spacing: 8) {
            Text(request.request.method)
                .font(.system(.caption2, design: .monospaced).bold())
                .foregroundStyle(.white)
                .frame(width: 40)
                .padding(.vertical, 2)
                .background(methodColor)
                .cornerRadius(3)

            Text(request.request.uri)
                .font(.system(.caption2, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            if let resp = request.response {
                Text("\(resp.statusCode)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(statusColor(resp.statusCode))
            }

            Text(request.durationMs)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .trailing)

            Text(request.timestampString)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.primary.opacity(0.04))
        .cornerRadius(4)
        .contentShape(Rectangle())
    }

    private var methodColor: Color {
        switch request.request.method.uppercased() {
        case "GET": return .blue
        case "POST": return .green
        case "PUT", "PATCH": return .orange
        case "DELETE": return .red
        default: return .gray
        }
    }

    private func statusColor(_ code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .blue
        case 400..<500: return .orange
        case 500...: return .red
        default: return .primary
        }
    }
}
