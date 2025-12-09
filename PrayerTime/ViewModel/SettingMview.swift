//
//  SettingMview.swift
//  PrayerTime
//
//  Created by rawan alkhaldi  on 18/06/1447 AH.
//
// SettingViewModel.swift

import Foundation
import Combine

class SettingViewModel: ObservableObject {
    
    // البيانات التي ستراقبها الواجهة (View)
    @Published var selectedLanguage: Language = .english
    @Published var selectedVibration: VibrationLevel = .midum
    
    // هذه خصائص القراءة فقط (Read-only) التي يمكن للواجهة استخدامها
    let availableLanguages = Language.allCases
    let availableVibrationLevels = VibrationLevel.allCases
    
    // دالة تهيئة (Initialization)
    init() {
        // هنا يمكن تحميل الإعدادات المحفوظة من UserDefaults أو قاعدة بيانات
        loadSettings()
    }
    
    // دالة لتحميل الإعدادات (مثال)
    private func loadSettings() {
        // مثال: يتم تحميل آخر إعداد محفوظ هنا
        // selectedLanguage = ...
        // selectedVibration = ...
    }
    
    // دالة لحفظ الإعدادات عند تغييرها
    func saveSettings() {
        // هنا يتم حفظ selectedLanguage و selectedVibration
        print("Settings saved: Language=\(selectedLanguage.rawValue), Vibration=\(selectedVibration.rawValue)")
    }
    
    // عند تغيير أي قيمة، نقوم بتحديث الحفظ
    func languageDidChange() {
        saveSettings()
    }
    
    func vibrationDidChange() {
        saveSettings()
    }
}
