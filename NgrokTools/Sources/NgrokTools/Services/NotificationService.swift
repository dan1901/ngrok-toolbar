import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func notifyTunnelConnected(url: String) {
        sendNotification(title: "Tunnel Connected", body: url)
    }

    func notifyTunnelDisconnected(url: String) {
        sendNotification(title: "Tunnel Disconnected", body: url)
    }

    func notifySessionStopped(ip: String) {
        sendNotification(title: "Session Stopped", body: "Agent at \(ip) has been stopped.")
    }

    func notifyError(message: String) {
        sendNotification(title: "ngrok Error", body: message)
    }
}
