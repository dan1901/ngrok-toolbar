import Foundation

struct GitHubRelease: Codable {
    let tagName: String
    let htmlUrl: String
    let body: String?

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlUrl = "html_url"
        case body
    }
}

@MainActor
final class UpdateChecker: ObservableObject {
    static let currentVersion = "1.0.4"
    private static let repoURL = "https://api.github.com/repos/dan1901/ngrok-toolbar/releases/latest"

    @Published var latestVersion: String?
    @Published var releaseURL: String?
    @Published var releaseNotes: String?
    @Published var isChecking = false
    @Published var hasUpdate = false
    @Published var errorMessage: String?

    func checkForUpdates() async {
        isChecking = true
        errorMessage = nil
        defer { isChecking = false }

        guard let url = URL(string: Self.repoURL) else { return }

        do {
            var request = URLRequest(url: url)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 10

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "릴리스 정보를 가져올 수 없습니다"
                return
            }

            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            let remoteVersion = release.tagName.hasPrefix("v")
                ? String(release.tagName.dropFirst())
                : release.tagName

            latestVersion = remoteVersion
            releaseURL = release.htmlUrl
            releaseNotes = release.body
            hasUpdate = isNewer(remote: remoteVersion, current: Self.currentVersion)
        } catch {
            errorMessage = "업데이트 확인 실패: \(error.localizedDescription)"
        }
    }

    private func isNewer(remote: String, current: String) -> Bool {
        let remoteParts = remote.split(separator: ".").compactMap { Int($0) }
        let currentParts = current.split(separator: ".").compactMap { Int($0) }

        for i in 0..<max(remoteParts.count, currentParts.count) {
            let r = i < remoteParts.count ? remoteParts[i] : 0
            let c = i < currentParts.count ? currentParts[i] : 0
            if r > c { return true }
            if r < c { return false }
        }
        return false
    }
}
