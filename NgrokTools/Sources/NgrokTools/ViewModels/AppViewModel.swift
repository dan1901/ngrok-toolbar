import Foundation
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var activeTunnelCount = 0
    @Published var showSettings = false
    @Published var authError: String?

    let dashboardViewModel = DashboardViewModel()
    let pollingManager = PollingManager()

    private let keychainService = KeychainService()
    private var didInitialize = false
    @AppStorage("pollingInterval") private var pollingInterval: Double = 30.0
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true

    func initialize() {
        guard !didInitialize else { return }
        didInitialize = true
        // Priority: 1) Keychain saved API key, 2) ngrok config api_key field
        if let apiKey = keychainService.read(), !apiKey.isEmpty {
            setupWithToken(apiKey)
        } else if let apiKey = ConfigParser.detectAPIKey() {
            keychainService.save(token: apiKey)
            setupWithToken(apiKey)
        } else {
            authError = "ngrok API Key가 필요합니다.\nauthtoken이 아닌 API Key를 입력해주세요.\nhttps://dashboard.ngrok.com/api-keys"
            showSettings = true
        }

        if notificationsEnabled {
            NotificationService.shared.requestPermission()
        }
    }

    func setupWithToken(_ token: String) {
        let client = NgrokAPIClient(token: token)
        dashboardViewModel.configure(with: client)
        isAuthenticated = true
        authError = nil
        startPolling()
    }

    func startPolling() {
        pollingManager.updateInterval(pollingInterval)
        pollingManager.start { [weak self] in
            Task { @MainActor in
                await self?.refreshAndDetectChanges()
            }
        }
        Task { await refreshAndDetectChanges() }
    }

    func stopPolling() {
        pollingManager.stop()
    }

    private func refreshAndDetectChanges() async {
        let oldTunnelIDs = dashboardViewModel.tunnels.map(\.id)

        await dashboardViewModel.refresh()

        // If we get an auth error, prompt for API key
        if let error = dashboardViewModel.errorMessage,
           error.contains("authtoken") || error.contains("ERR_NGROK_206") || error.contains("401") {
            isAuthenticated = false
            authError = "잘못된 토큰입니다. ngrok API Key를 입력해주세요.\nhttps://dashboard.ngrok.com/api-keys"
            stopPolling()
            showSettings = true
            return
        }

        let newTunnelIDs = dashboardViewModel.tunnels.map(\.id)
        activeTunnelCount = newTunnelIDs.count

        guard notificationsEnabled else { return }

        let added = PollingManager.detectAdded(old: oldTunnelIDs, new: newTunnelIDs)
        let removed = PollingManager.detectRemoved(old: oldTunnelIDs, new: newTunnelIDs)

        for id in added {
            if let tunnel = dashboardViewModel.tunnels.first(where: { $0.id == id }) {
                NotificationService.shared.notifyTunnelConnected(url: tunnel.publicURL)
            }
        }

        for id in removed {
            NotificationService.shared.notifyTunnelDisconnected(url: id)
        }
    }

    func reloadTokenAndConnect() {
        stopPolling()
        if let apiKey = keychainService.read(), !apiKey.isEmpty {
            setupWithToken(apiKey)
        }
    }

    func cleanup() {
        stopPolling()
    }
}
