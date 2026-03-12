import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            DashboardView(viewModel: viewModel)
        }
        .frame(width: 380, height: 480)
        .onAppear {
            let keychain = KeychainService()
            if let token = keychain.read() ?? ConfigParser.detectAuthtoken() {
                let client = NgrokAPIClient(token: token)
                viewModel.configure(with: client)
                Task { await viewModel.refresh() }
            }
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "network")
                .foregroundStyle(.blue)
            Text("ngrok Tools")
                .font(.headline)
            Spacer()
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            }
            Button(action: { showSettings.toggle() }) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
