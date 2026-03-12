import Foundation
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var tunnels: [Tunnel] = []
    @Published var sessions: [TunnelSession] = []
    @Published var endpoints: [Endpoint] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var tunnelService: TunnelService?
    private var sessionService: SessionService?
    private var endpointService: EndpointService?

    func configure(with client: NgrokAPIClient) {
        tunnelService = TunnelService(client: client)
        sessionService = SessionService(client: client)
        endpointService = EndpointService(client: client)
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        async let t = tunnelService?.listTunnels()
        async let s = sessionService?.listSessions()
        async let e = endpointService?.listEndpoints()

        do {
            tunnels = try await t ?? []
            sessions = try await s ?? []
            endpoints = try await e ?? []
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func restartSession(_ id: String) async {
        do {
            try await sessionService?.restartSession(id: id)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopSession(_ id: String) async {
        do {
            try await sessionService?.stopSession(id: id)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteEndpoint(_ id: String) async {
        do {
            try await endpointService?.deleteEndpoint(id: id)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
