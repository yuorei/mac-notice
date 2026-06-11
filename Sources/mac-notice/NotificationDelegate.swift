import UserNotifications
import AppKit

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    var onClick: String?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier,
              let target = onClick else {
            exit(0)
        }
        openTarget(target)
        exit(0)
    }

    private func openTarget(_ target: String) {
        if let url = URL(string: target), url.scheme != nil && url.scheme != "file" {
            NSWorkspace.shared.open(url)
        } else {
            let expanded = (target as NSString).expandingTildeInPath
            NSWorkspace.shared.open(URL(fileURLWithPath: expanded))
        }
    }
}
