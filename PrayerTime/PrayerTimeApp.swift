//
//  PrayerTimeApp.swift
//  PrayerTime
//
//  Created by asma  on 08/06/1447 AH.
//

import SwiftUI
import WatchConnectivity
import UserNotifications
import UIKit

@main
struct PrayerTimeApp: App {
    
    // تعيين delegate عند الإطلاق
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Delegate منفصل لإدارة عرض الإشعارات عندما يكون التطبيق نشط
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // يتم استدعاؤها عندما يصل إشعار والتطبيق في الواجهة
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // تشغيل هابتك وفق إعداد المستخدم
        HapticManager.instance.impactFromUserSetting()
        // عرض الإشعار كـ banner مع صوت وشارة
        completionHandler([.banner, .sound, .badge])
    }
}

struct ContentView: View {
    @StateObject var viewModel = PrayerViewModel()
    
    var body: some View {
        NavigationStack {
            PrayerTimesView(viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
