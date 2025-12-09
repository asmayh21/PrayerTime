//
//  Settings1.swift
//  PrayerTime
//
//  Created by rawan alkhaldi  on 18/06/1447 AH.
//
// SettingModel.swift

import Foundation

// تعريف الخيارات المتاحة
enum Language: String, CaseIterable, Identifiable {
    case english = "ENGLISH"
    case arabic = "العربية"
    var id: String { self.rawValue }
}

enum VibrationLevel: String, CaseIterable, Identifiable {
    case low = "Low"
    case midum = "Midum" // لاحظ أننا أبقيناها كما في الصورة
    case heavy = "Heavy"
    var id: String { self.rawValue }
}
