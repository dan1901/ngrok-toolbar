import SwiftUI

enum DashboardTab: String, CaseIterable {
    case tunnels = "Tunnels"
    case sessions = "Sessions"
    case endpoints = "Endpoints"

    var icon: String {
        switch self {
        case .tunnels: return "network"
        case .sessions: return "server.rack"
        case .endpoints: return "link"
        }
    }
}

struct DashboardView: View {
    @State private var selectedTab: DashboardTab = .tunnels
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider()
            tabContent
        }
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    HStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.caption)
                        Text(tab.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            Spacer()
            Button(action: { Task { await viewModel.refresh() } }) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .tunnels:
            TunnelsTabView(tunnels: viewModel.tunnels, isLoading: viewModel.isLoading)
        case .sessions:
            SessionsTabView(sessions: viewModel.sessions, isLoading: viewModel.isLoading, onRestart: viewModel.restartSession, onStop: viewModel.stopSession)
        case .endpoints:
            EndpointsTabView(endpoints: viewModel.endpoints, isLoading: viewModel.isLoading, onDelete: viewModel.deleteEndpoint)
        }
    }
}
