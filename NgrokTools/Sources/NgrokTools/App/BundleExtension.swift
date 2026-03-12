import Foundation

private class BundleToken {}

extension Bundle {
    /// Custom resource bundle resolver that checks multiple paths
    /// to support both development builds and Homebrew app bundle installs.
    static let appModule: Bundle = {
        let bundleName = "NgrokTools_NgrokTools.bundle"

        let candidates = [
            // App bundle: .app/Contents/Resources/
            Bundle.main.resourceURL?.appendingPathComponent(bundleName),
            // SPM default: .app/ root (Bundle.main.bundleURL)
            Bundle.main.bundleURL.appendingPathComponent(bundleName),
            // Alongside the executable
            Bundle(for: BundleToken.self).bundleURL.appendingPathComponent(bundleName),
            // Executable directory parent (for CLI usage)
            Bundle.main.executableURL?.deletingLastPathComponent().appendingPathComponent(bundleName),
        ]

        for candidate in candidates {
            if let path = candidate?.path, let bundle = Bundle(path: path) {
                return bundle
            }
        }

        fatalError("could not load resource bundle: searched \(candidates.compactMap { $0?.path })")
    }()
}
