import Foundation

enum ConfigParser {
    static func parseValue(key: String, from yamlContent: String) -> String? {
        for line in yamlContent.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("\(key):") {
                let value = trimmed
                    .replacingOccurrences(of: "\(key):", with: "")
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))

                return value.isEmpty ? nil : value
            }
        }
        return nil
    }

    static func parseAuthtoken(from yamlContent: String) -> String? {
        return parseValue(key: "authtoken", from: yamlContent)
    }

    static func parseAPIKey(from yamlContent: String) -> String? {
        return parseValue(key: "api_key", from: yamlContent)
    }

    static func configPathCandidates() -> [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return [
            "\(home)/Library/Application Support/ngrok/ngrok.yml",
            "\(home)/.ngrok2/ngrok.yml",
            "\(home)/.config/ngrok/ngrok.yml",
        ]
    }

    static func detectAPIKey() -> String? {
        let fileManager = FileManager.default

        for path in configPathCandidates() {
            guard fileManager.fileExists(atPath: path),
                  let content = try? String(contentsOfFile: path, encoding: .utf8)
            else { continue }

            if let apiKey = parseAPIKey(from: content) {
                return apiKey
            }
        }
        return nil
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
