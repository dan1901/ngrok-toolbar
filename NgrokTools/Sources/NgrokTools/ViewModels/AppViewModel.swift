import Foundation
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var activeTunnelCount = 0
    @Published var showSettings = false

    let dashboardViewModel = DashboardViewModel()
    let pollingManager = PollingManager()

    private let keychainService = KeychainService()
    @AppStorage("pollingInterval") private var pollingInterval: Double = 30.0
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true

    private var previousTunnelIDs: [String] = []

    func initialize() {
        // Try to detect token from CLI config or keychain
        if let token = keychainService.read() {
            setupWithToken(token)
        } else if let token = ConfigParser.detectAuthtoken() {
            keychainService.save(token: token)
            setupWithToken(token)
        } else {
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
        startPolling()
    }

    func startPolling() {
        pollingManager.updateInterval(pollingInterval)
        pollingManager.start { [weak self] in
            Task { @MainActor in
                await self?.refreshAndDetectChanges()
            }
        }
        // Initial fetch
        Task { await refreshAndDetectChanges() }
    }

    func stopPolling() {
        pollingManager.stop()
    }

    private func refreshAndDetectChanges() async {
        let oldTunnelIDs = dashboardViewModel.tunnels.map(\.id)

        await dashboardViewModel.refresh()

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

        if let error = dashboardViewModel.errorMessage {
            NotificationService.shared.notifyError(message: error)
        }
    }

    func cleanup() {
        stopPolling()
    }
}
