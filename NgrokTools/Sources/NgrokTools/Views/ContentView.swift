import SwiftUI

struct ContentView: View {
    @ObservedObject var appViewModel: AppViewModel
    let isDetached: Bool

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
        .frame(
            minWidth: isDetached ? 360 : 380,
            idealWidth: isDetached ? 420 : 380,
            minHeight: isDetached ? 400 : 480,
            idealHeight: isDetached ? 560 : 480
        )
        .frame(width: isDetached ? nil : 380, height: isDetached ? nil : 480)
        .sheet(isPresented: $appViewModel.showSettings, onDismiss: {
            appViewModel.reloadTokenAndConnect()
        }) {
            SettingsView()
        }
        .onAppear {
            appViewModel.initialize()
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

            // Detach / Attach button
            Button(action: {
                NotificationCenter.default.post(name: .toggleDetach, object: nil)
            }) {
                Image(systemName: isDetached ? "menubar.arrow.down.rectangle" : "macwindow.on.rectangle")
                    .font(.system(size: 13))
            }
            .buttonStyle(.plain)
            .help(isDetached ? "Back to toolbar" : "Open in window")

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
                .foregroundStyle(.orange)
            Text("API Key Required")
                .font(.headline)
            if let error = appViewModel.authError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            Text("authtoken != API Key")
                .font(.caption2)
                .foregroundStyle(.red)
            Button("Open Settings") {
                appViewModel.showSettings = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
