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
    // MARK: - watchOS Haptics (Composite Patterns)
    
    private func play(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
    
    // نمط عام لتكرار الهزات بعدد مرات وفاصل زمني
    private func playPattern(types: [WKHapticType], interval: TimeInterval = 0.1) {
        for (index, t) in types.enumerated() {
            let delay = Double(index) * interval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.play(t)
            }
        }
    }
    
    func notification(type: WKHapticType) {
        play(type)
    }
    
    func impact(style: WKHapticType) {
        play(style)
    }
    
    // Read vibrationOption and play a stronger composite pattern on watchOS
    func impactFromUserSetting() {
        let saved = UserDefaults.standard.string(forKey: "vibrationOption")
        switch saved {
        case "Low":
            // نبضة خفيفة واحدة
            play(.click)
        case "Midum":
            // نبضتان واضحتان
            playPattern(types: [.success, .success], interval: 0.12)
        case "Heavy":
            fallthrough
        default:
            // نمط أقوى: ثلاث نبضات notification
            playPattern(types: [.notification, .notification, .notification], interval: 0.15)
        }
    }
    #else
    // MARK: - iOS/iPadOS Haptics (Composite Patterns)
    
    private func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    private func impactOnce(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // نمط عام لتكرار الاهتزازات بعدد مرات وفاصل زمني
    private func impactPattern(styles: [UIImpactFeedbackGenerator.FeedbackStyle], interval: TimeInterval = 0.08) {
        for (index, style) in styles.enumerated() {
            let delay = Double(index) * interval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.impactOnce(style)
            }
        }
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notify(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        impactOnce(style)
    }
    
    func impactFromUserSetting() {
        let saved = UserDefaults.standard.string(forKey: "vibrationOption")
        switch saved {
            
        case "Low":
            // نبضة خفيفة واحدة
            impactOnce(.light)
        case "Midum":
            // نبضتان: success ثم heavy قصيرة
            notify(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                self.impactOnce(.medium)
            }
        case "Heavy":
            fallthrough
        default:
            // نمط أقوى: success ثم ثلاث نبضات .heavy متتابعة
            notify(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                self.impactPattern(styles: [.heavy, .heavy, .heavy], interval: 0.1)
            }
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
