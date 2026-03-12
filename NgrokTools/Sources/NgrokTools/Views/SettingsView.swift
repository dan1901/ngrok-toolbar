import SwiftUI

struct SettingsView: View {
    @AppStorage("pollingInterval") private var pollingInterval: Double = 30.0
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @State private var tokenInput: String = ""
    @State private var currentToken: String = ""
    @State private var showTokenSaved = false
    @StateObject private var updateChecker = UpdateChecker()
    @StateObject private var launchAtLogin = LaunchAtLoginService()
    @Environment(\.dismiss) private var dismiss

    private let keychain = KeychainService()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    tokenSection
                    Divider()
                    pollingSection
                    Divider()
                    notificationSection
                    Divider()
                    generalSection
                    Divider()
                    aboutSection
                }
                .padding(.bottom, 20)
            }
        }
        .padding(20)
        .frame(width: 380, height: 520)
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

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("General", systemImage: "gear")
                .font(.headline)

            Toggle("시스템 시작 시 자동 실행", isOn: $launchAtLogin.isEnabled)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("About", systemImage: "info.circle")
                .font(.headline)

            HStack {
                Text("Version")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("v\(UpdateChecker.currentVersion)")
                    .font(.system(.body, design: .monospaced))
            }

            HStack {
                if updateChecker.isChecking {
                    ProgressView()
                        .controlSize(.small)
                    Text("확인 중...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if updateChecker.hasUpdate, let latest = updateChecker.latestVersion {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(.green)
                    Text("v\(latest) 업데이트 가능")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Spacer()
                    Button("다운로드") {
                        if let urlString = updateChecker.releaseURL,
                           let url = URL(string: urlString) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .controlSize(.small)
                } else if let error = updateChecker.errorMessage {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Spacer()
                } else if updateChecker.latestVersion != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("최신 버전입니다")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                if !updateChecker.isChecking {
                    Button("업데이트 확인") {
                        Task { await updateChecker.checkForUpdates() }
                    }
                    .controlSize(.small)
                }
            }

            if updateChecker.hasUpdate, let notes = updateChecker.releaseNotes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(6)
            }

            HStack(spacing: 12) {
                Button("GitHub") {
                    if let url = URL(string: "https://github.com/dan1901/ngrok-toolbar") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .font(.caption)

                Text("MIT License")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
