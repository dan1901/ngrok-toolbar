import Foundation

struct TunnelHistoryItem: Codable, Identifiable, Equatable {
    var id: String { "\(proto):\(port):\(domain ?? "")" }
    let port: Int
    let proto: String
    let domain: String?
    let lastUsed: Date

    var displayLabel: String {
        var label = "\(proto.uppercased()) :\(port)"
        if let d = domain, !d.isEmpty {
            label += " → \(d)"
        }
        return label
    }
}

@MainActor
final class TunnelFormViewModel: ObservableObject {
    @Published var port: String = ""
    @Published var domain: String = ""
    @Published var proto: String = "http"
    @Published var isLaunching = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var history: [TunnelHistoryItem] = []
    @Published var showHistory = false

    let launcher = TunnelLauncher.shared
    private let historyKey = "tunnelHistory"
    private let maxHistory = 10

    init() {
        loadHistory()
    }

    func startTunnel(onStarted: @escaping () -> Void) {
        guard let portNum = Int(port), portNum > 0, portNum <= 65535 else {
            errorMessage = "Invalid port (1-65535)"
            return
        }

        isLaunching = true
        errorMessage = nil
        successMessage = nil

        do {
            let process = try launcher.startTunnel(
                port: portNum,
                proto: proto,
                domain: domain.isEmpty ? nil : domain
            )

            saveToHistory(port: portNum, proto: proto, domain: domain.isEmpty ? nil : domain)

            let savedPort = port
            let savedDomain = domain
            port = ""
            domain = ""

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                if process.isRunning {
                    self?.successMessage = "Tunnel started on port \(savedPort)" + (savedDomain.isEmpty ? "" : " (\(savedDomain))")
                    self?.isLaunching = false
                    onStarted()
                } else {
                    self?.errorMessage = "ngrok exited unexpectedly. Check if port \(savedPort) is available."
                    self?.isLaunching = false
                }
            }

            // Retry refresh — ngrok API registration can take a few seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                onStarted()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                onStarted()
            }
        } catch {
            errorMessage = error.localizedDescription
            isLaunching = false
        }
    }

    func applyHistoryItem(_ item: TunnelHistoryItem) {
        port = String(item.port)
        proto = item.proto
        domain = item.domain ?? ""
        showHistory = false
    }

    func removeHistoryItem(_ item: TunnelHistoryItem) {
        history.removeAll { $0.id == item.id }
        persistHistory()
    }

    func clearHistory() {
        history.removeAll()
        persistHistory()
    }

    private func saveToHistory(port: Int, proto: String, domain: String?) {
        // Remove duplicate if exists
        history.removeAll { $0.port == port && $0.proto == proto && $0.domain == domain }

        let item = TunnelHistoryItem(port: port, proto: proto, domain: domain, lastUsed: Date())
        history.insert(item, at: 0)

        if history.count > maxHistory {
            history = Array(history.prefix(maxHistory))
        }

        persistHistory()
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let items = try? JSONDecoder().decode([TunnelHistoryItem].self, from: data) else {
            return
        }
        history = items
    }

    private func persistHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
}
