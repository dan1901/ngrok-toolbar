import SwiftUI

enum DashboardTab: String, CaseIterable {
    case tunnels = "Tunnels"
    case sessions = "Sessions"
    case endpoints = "Endpoints"
    case domains = "Domains"

    var icon: String {
        switch self {
        case .tunnels: return "network"
        case .sessions: return "server.rack"
        case .endpoints: return "link"
        case .domains: return "globe"
        }
    }
}

struct DashboardView: View {
    @State private var selectedTab: DashboardTab = .tunnels
    @ObservedObject var viewModel: DashboardViewModel
    @StateObject private var tunnelFormVM = TunnelFormViewModel()

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider()
            tabContent
        }
        .onAppear {
            Task { await viewModel.refresh() }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                    Task { await viewModel.refresh() }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.caption)
                        Text(tab.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(selectedTab == tab ? Color.accentColor.opacity(0.2) : Color.white.opacity(0.001))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            Spacer()
            Button(action: { Task { await viewModel.refresh() } }) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                    .animation(viewModel.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
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
            TunnelsTabView(tunnels: viewModel.tunnels, isLoading: viewModel.isLoading, formVM: tunnelFormVM, onRefresh: {
                Task { await viewModel.refresh() }
            })
        case .sessions:
            SessionsTabView(sessions: viewModel.sessions, isLoading: viewModel.isLoading, onRestart: viewModel.restartSession, onStop: viewModel.stopSession)
        case .endpoints:
            EndpointsTabView(endpoints: viewModel.endpoints, isLoading: viewModel.isLoading, onDelete: viewModel.deleteEndpoint)
        case .domains:
            DomainsTabView(domains: viewModel.domains, isLoading: viewModel.isLoading)
        }
    }
}
