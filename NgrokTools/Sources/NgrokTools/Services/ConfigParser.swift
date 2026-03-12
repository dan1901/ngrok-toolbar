import Foundation

enum ConfigParser {
    static func parseAuthtoken(from yamlContent: String) -> String? {
        for line in yamlContent.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("authtoken:") {
                let value = trimmed
                    .replacingOccurrences(of: "authtoken:", with: "")
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))

                return value.isEmpty ? nil : value
            }
        }
        return nil
    }

    static func configPathCandidates() -> [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return [
            "\(home)/Library/Application Support/ngrok/ngrok.yml",
            "\(home)/.ngrok2/ngrok.yml",
            "\(home)/.config/ngrok/ngrok.yml",
        ]
    }

    static func detectAuthtoken() -> String? {
        let fileManager = FileManager.default

        for path in configPathCandidates() {
            guard fileManager.fileExists(atPath: path),
                  let content = try? String(contentsOfFile: path, encoding: .utf8)
            else { continue }

            if let token = parseAuthtoken(from: content) {
                return token
            }
        }
        return nil
    }
}
