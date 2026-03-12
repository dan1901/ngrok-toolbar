import Foundation

final class TunnelLauncher {
    static let shared = TunnelLauncher()

    private var processes: [Int: Process] = [:]
    private var outputPipes: [Int: Pipe] = [:]

    func findNgrokPath() -> String? {
        let candidates = [
            "/opt/homebrew/bin/ngrok",
            "/usr/local/bin/ngrok",
            "/usr/bin/ngrok",
        ]

        for path in candidates {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return nil
    }

    @discardableResult
    func startTunnel(port: Int, proto: String = "http", domain: String? = nil) throws -> Process {
        guard let ngrokPath = findNgrokPath() else {
            throw TunnelLauncherError.ngrokNotFound
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: ngrokPath)

        var args = [proto]
        if let domain = domain, !domain.isEmpty {
            args.append("--url=\(domain)")
        }
        args.append(String(port))
        args.append("--log=stdout")
        process.arguments = args

        // ngrok needs pipes, not /dev/null
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        // Set environment with PATH so ngrok can find its config
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
        process.environment = env

        try process.run()

        processes[port] = process
        outputPipes[port] = outPipe

        // Check if process exits immediately (error case)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            if let p = self?.processes[port], !p.isRunning {
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                let errMsg = String(data: errData, encoding: .utf8) ?? "Unknown error"
                print("[TunnelLauncher] ngrok exited early: \(errMsg)")
            }
        }

        return process
    }

    func stopTunnel(port: Int) {
        if let process = processes[port], process.isRunning {
            process.terminate()
        }
        processes.removeValue(forKey: port)
        outputPipes.removeValue(forKey: port)
    }

    func isRunning(port: Int) -> Bool {
        return processes[port]?.isRunning == true
    }

    func runningPorts() -> [Int] {
        return processes.filter { $0.value.isRunning }.map { $0.key }
    }

    func stopAll() {
        for (_, process) in processes where process.isRunning {
            process.terminate()
        }
        processes.removeAll()
        outputPipes.removeAll()
    }
}

enum TunnelLauncherError: LocalizedError {
    case ngrokNotFound

    var errorDescription: String? {
        switch self {
        case .ngrokNotFound:
            return "ngrok CLI not found. Install: brew install ngrok"
        }
    }
}
