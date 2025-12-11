// SettingViewModel.swift

import Foundation
import Combine
import SwiftUI // ضرورية لـ @AppStorage

// ----------------------------------------------------
// 1. تعريف Enums المصححة لتجنب أخطاء التداخل
// ----------------------------------------------------
enum LanguageOption: String, CaseIterable, Identifiable {
    case english = "English"
    case arabic = "العربية"
    var id: String { self.rawValue }
    
    // دالة مساعدة للحصول على كود اللغة
    var code: String {
        switch self {
        case .english: return "en"
        case .arabic: return "ar"
        }
    }
}

enum VibrationOption: String, CaseIterable, Identifiable {
    case low = "Low"
    case midum = "Midum"
    case heavy = "Heavy"
    var id: String { self.rawValue }
}

// ----------------------------------------------------
// 2. كلاس SettingViewModel: ObservableObject
// ----------------------------------------------------

class SettingViewModel: ObservableObject {
    
    // ⭐️ 1. الخاصية الرئيسية: تخزين كود اللغة باستخدام @AppStorage (String) ⭐️
    @AppStorage("appLanguageCode") var selectedAppLanguageCode: String = "ar"
    
    // 2. خصائص الإعدادات الأخرى (باستخدام Enum الجديدة)
    @Published var selectedVibration: VibrationOption = .midum
    
    // 3. البيانات المتاحة
    let availableLanguageOptions = LanguageOption.allCases
    let availableVibrationLevels = VibrationOption.allCases
    
    init() {
        // تحميل اللغة الحالية عند التهيئة
        if let currentLanguageArray = UserDefaults.standard.stringArray(forKey: "AppleLanguages"),
           let currentLanguageCode = currentLanguageArray.first {
            self.selectedAppLanguageCode = currentLanguageCode.prefix(2).lowercased()
        }
    }
    
    // ⭐️ 4. الدالة الرئيسية لتغيير اللغة في إعدادات النظام ⭐️
    func changeAppLanguage(to languageCode: String) {
        if selectedAppLanguageCode != languageCode {
            
            selectedAppLanguageCode = languageCode
            
            // 🛑 الخطوة الحاسمة: تحديث قائمة اللغات المفضلة للتطبيق 🛑
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            
            print("Language code set to: \(languageCode). App restart is required.")
        }
    }
    
    // دوال dummy للحفاظ على الهيكل
    func loadSettings() { print("Settings loaded.") }
    func saveSettings() { print("Settings saved.") }
}
