import ServiceManagement

@MainActor
final class LaunchAtLoginService: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            if isEnabled {
                register()
            } else {
                unregister()
            }
        }
    }

    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    private func register() {
        do {
            try SMAppService.mainApp.register()
        } catch {
            isEnabled = false
        }
    }

    private func unregister() {
        do {
            try SMAppService.mainApp.unregister()
        } catch {
            isEnabled = true
        }
    }
}
