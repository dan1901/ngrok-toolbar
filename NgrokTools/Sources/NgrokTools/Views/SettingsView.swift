import SwiftUI

struct SettingsView: View {
    @AppStorage("pollingInterval") private var pollingInterval: Double = 30.0
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @State private var tokenInput: String = ""
    @State private var currentToken: String = ""
    @State private var showTokenSaved = false
    @Environment(\.dismiss) private var dismiss

    private let keychain = KeychainService()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)

            tokenSection
            Divider()
            pollingSection
            Divider()
            notificationSection
            Divider()
            aboutSection

            Spacer()
        }
        .padding(20)
        .frame(width: 380, height: 420)
        .onAppear {
            if let token = keychain.read() {
                currentToken = String(token.prefix(8)) + "..."
            }
        }
    }

    private var tokenSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("API Key", systemImage: "key")
                .font(.headline)

            Text("authtoken이 아닌 API Key가 필요합니다")
                .font(.caption)
                .foregroundStyle(.orange)

            Button("API Key 발급 페이지 열기") {
                if let url = URL(string: "https://dashboard.ngrok.com/api-keys") {
                    NSWorkspace.shared.open(url)
                }
            }
            .font(.caption)

            if !currentToken.isEmpty {
                HStack {
                    Text(currentToken)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Delete") {
                        keychain.delete()
                        currentToken = ""
                    }
                    .foregroundStyle(.red)
                }
            }

            HStack {
                SecureField("Enter ngrok API Key", text: $tokenInput)
                    .textFieldStyle(.roundedBorder)
                Button("Save") {
                    guard !tokenInput.isEmpty else { return }
                    keychain.save(token: tokenInput)
                    currentToken = String(tokenInput.prefix(8)) + "..."
                    tokenInput = ""
                    showTokenSaved = true
                }
                .disabled(tokenInput.isEmpty)
            }

            if showTokenSaved {
                Text("API Key saved! Close settings and reopen the app.")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
    }

    private var pollingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Polling Interval", systemImage: "timer")
                .font(.headline)

            HStack {
                Slider(value: $pollingInterval, in: 10...60, step: 5)
                Text("\(Int(pollingInterval))s")
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 40)
            }
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Notifications", systemImage: "bell")
                .font(.headline)

            Toggle("Enable system notifications", isOn: $notificationsEnabled)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ngrok Tools v1.0.0")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("macOS Menu Bar App for ngrok management")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
