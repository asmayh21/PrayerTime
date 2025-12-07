import UserNotifications
import Foundation

class NotificationManager {
    
    // 1. Request Permission
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    // 2. Schedule All Notifications (The core logic)
    // It accepts the prayer data and the necessary time conversion function.
    static func scheduleAllDailyNotifications(prayers: [PrayerTime], timeConverter: (String) -> Date?) {
        let center = UNUserNotificationCenter.current()
        
        // Remove old requests to clear yesterday's notifications
        center.removeAllPendingNotificationRequests()

        for prayer in prayers {
            // Use the timeConverter function provided by the ViewModel
            guard let prayerDate = timeConverter(prayer.time) else {
                continue
            }
            
            // Only schedule future prayers
            if prayerDate > Date() {
                scheduleSinglePrayerNotification(for: prayer, time: prayerDate)
            }
        }
        print("Scheduled notifications for \(prayers.count) potential prayers.")
    }

    // 3. Schedule a Single Notification (Private helper)
    private static func scheduleSinglePrayerNotification(for prayer: PrayerTime, time: Date) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "حان وقت الصلاة"
        content.body = "حان الآن وقت صلاة \(prayer.name)."
        
        // Using UNNotificationSound.default ensures the device provides haptic feedback (vibration).
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Ensure the identifier is unique for the specific prayer on the specific day
        let identifier = "prayer-\(prayer.name)-\(components.day!)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification for \(prayer.name): \(error.localizedDescription)")
            }
        }
    }
}
