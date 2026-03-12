import Foundation

private class BundleToken {}

extension Bundle {
    /// Custom resource bundle resolver that checks multiple paths
    /// to support both development builds and Homebrew app bundle installs.
    static let appModule: Bundle = {
        let candidates = [
            // Standard app bundle: .app/Contents/Resources/
            Bundle.main.resourceURL?.appendingPathComponent("NgrokTools_NgrokTools.bundle"),
            // SPM default: .app/NgrokTools_NgrokTools.bundle
            Bundle.main.bundleURL.appendingPathComponent("NgrokTools_NgrokTools.bundle"),
            // Alongside executable
            Bundle(for: BundleToken.self).resourceURL?.appendingPathComponent("NgrokTools_NgrokTools.bundle"),
        ]

        for candidate in candidates {
            if let path = candidate?.path, let bundle = Bundle(path: path) {
                return bundle
            }
        }

        // Fallback to SPM-generated Bundle.module
        return Bundle.module
    }()
}
