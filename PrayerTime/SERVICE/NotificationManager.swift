import UserNotifications
import Foundation

#if os(watchOS)
import WatchKit
#else
import UIKit
#endif

class HapticManager {
    static let instance = HapticManager()
    
    #if os(watchOS)
    // MARK: - watchOS Haptics (Repeated notification-style patterns)
    
    private func play(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
    
    // تكرار نوع هابتك معين لمدة محددة
    private func repeatHaptic(type: WKHapticType, interval: TimeInterval, duration: TimeInterval) {
        let repeats = Int(duration / interval)
        for i in 0..<repeats {
            let delay = Double(i) * interval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.play(type)
            }
        }
    }
    
    func notification(type: WKHapticType) {
        play(type)
    }
    
    func impact(style: WKHapticType) {
        play(style)
    }
    
    // كل درجة = نوع هابتك مختلف
    func impactFromUserSetting() {
        let saved = UserDefaults.standard.string(forKey: "vibrationOption")
        switch saved {
        case "Low":
            // Success = .success
            repeatHaptic(type: .success, interval: 0.5, duration: 3)
        case "Midum":
            // Warning ≈ .retry (أقرب متاح)
            repeatHaptic(type: .retry, interval: 0.4, duration: 5)
        case "Heavy":
            fallthrough
        default:
            // Error ≈ .failure
            repeatHaptic(type: .failure, interval: 0.25, duration: 7)
        }
    }
    #else
    // MARK: - iOS/iPadOS Haptics (Repeated notification feedback)
    
    // تكرار نوع نوتيفيكيشن فيدباك لمدة محددة
    private func repeatNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType, interval: TimeInterval, duration: TimeInterval) {
        let repeats = Int(duration / interval)
        for i in 0..<repeats {
            let delay = Double(i) * interval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(type)
            }
        }
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // كل درجة = نوع هابتك مختلف
    func impactFromUserSetting() {
        let saved = UserDefaults.standard.string(forKey: "vibrationOption")
        switch saved {
        case "Low":
            // Success
            repeatNotificationFeedback(type: .success, interval: 0.5, duration: 5)
        case "Midum":
            // Warning
            repeatNotificationFeedback(type: .warning, interval: 0.4, duration: 5)
        case "Heavy":
            fallthrough
        default:
            // Error
            repeatNotificationFeedback(type: .error, interval: 0.25, duration: 5)
        }
    }
    #endif
}

class NotificationManager {
    
    static func playHapticsForNotificationTap() {
        HapticManager.instance.impactFromUserSetting()
    }
    
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
            guard let prayerDate = timeConverter(prayer.time) else {
                continue
            }
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
        
        // إشعارات النظام تستخدم الاهتزاز/الاهتزازات الخاصة بالنظام فقط،
        // وأنماط الاهتزاز المخصصة من HapticManager ستعمل فقط عند استدعائها يدوياً من كود التطبيق،
        // على سبيل المثال عندما يضغط المستخدم على الإشعار ويفتح التطبيق مرة أخرى.
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let dayComponent = components.day ?? 0
        let identifier = "prayer-\(prayer.name)-\(dayComponent)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification for \(prayer.name): \(error.localizedDescription)")
            }
        }
    }
}
