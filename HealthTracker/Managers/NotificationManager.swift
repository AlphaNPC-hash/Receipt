import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }

    func scheduleMedicationNotifications(for medication: Medication) {
        cancelNotifications(for: medication.id)

        for time in medication.scheduledTimes {
            let content = UNMutableNotificationContent()
            content.title = "เวลาทาน\(medication.name)"
            content.body = "\(medication.dosage) \(medication.unit)"
            content.sound = .default
            content.categoryIdentifier = "MEDICATION"

            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let id = "\(medication.id.uuidString)-\(components.hour ?? 0)-\(components.minute ?? 0)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelNotifications(for medicationId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix(medicationId.uuidString) }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
