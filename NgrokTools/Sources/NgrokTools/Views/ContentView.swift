import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            if appViewModel.isAuthenticated {
                DashboardView(viewModel: appViewModel.dashboardViewModel)
            } else {
                noTokenView
            }
        }
        .frame(width: 380, height: 480)
        .sheet(isPresented: $appViewModel.showSettings) {
            SettingsView()
        }
        .onAppear {
            appViewModel.initialize()
        }
        .onDisappear {
            appViewModel.cleanup()
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "network")
                .foregroundStyle(.blue)
            Text("ngrok Tools")
                .font(.headline)
            Spacer()
            if appViewModel.dashboardViewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            }
            Button(action: { appViewModel.showSettings.toggle() }) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var noTokenView: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No API token configured")
                .foregroundStyle(.secondary)
            Button("Open Settings") {
                appViewModel.showSettings = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
