// setting.swift

import SwiftUI
import Combine

// -----------------------------------------------------------------
// 1. ⭐️ المكون المساعد LanguagePickerRow (تم وضعه هنا ليصبح مرئياً لـ setting) ⭐️
// -----------------------------------------------------------------
struct LanguagePickerRow: View {
    // يجب أن يتم تمرير ViewModel كـ ObservedObject
    @ObservedObject var viewModel: SettingViewModel
    
    var body: some View {
        Group {
            Picker("Language", selection: $viewModel.selectedAppLanguageCode) {
                // هنا نستخدم availableLanguageOptions من ViewModel
                ForEach(viewModel.availableLanguageOptions) { option in
                    Text(option.rawValue).tag(option.code)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 10)
        }
        // تطبيق التعديلات الشكلية والوظيفية على الـ Group/Picker
        .frame(width: 345 , height: 54)
        .tint(.white)
        .background(Color.white .opacity(0.1))
        .cornerRadius(10)
        .foregroundColor(.white)
        
        // استدعاء دالة تغيير اللغة
        .onChange(of: viewModel.selectedAppLanguageCode) { newLanguageCode in
            viewModel.changeAppLanguage(to: newLanguageCode)
        }
    }
}

// -----------------------------------------------------------------
// 2. الهيكل الرئيسي لصفحة الإعدادات
// -----------------------------------------------------------------

struct setting: View {
    
    @StateObject var viewModel = SettingViewModel()
    @StateObject var prayerViewModel = PrayerViewModel()
    
    // ⭐️ FIXED: Use the same dynamic background logic as PrayerTimesView ⭐️
    @State private var backgroundType: BackgroundType = {
        return initialBackgroundType()
    }()
    
    var body: some View {
        
        ZStack {
            // ⭐️ FIXED: Use the actual dynamic gradient function ⭐️
            createBackgroundGradient(for: backgroundType)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 30) {
                
                // العنوان (مفتاح الترجمة)
                Text("SETTINGS")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                
                // --- ⭐️ قسم اللغة (مصحح: الآن LanguagePickerRow مرئي) ⭐️ ---
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("LANGUAGE") // مفتاح الترجمة
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    
                    // ⭐️ استخدام المكون المساعد هنا ⭐️
                    LanguagePickerRow(viewModel: viewModel)
                }
                .padding(.horizontal)
                
                Divider()
                    .overlay(Color.black .opacity(0.3))
                    .padding()
                
                // --- قسم مستوى الاهتزاز ---
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Vibration Level") // مفتاح الترجمة
                        .font(.system(size: 21))
                        .foregroundColor(.white)
                    
                    Picker("Vibration Level", selection: $viewModel.selectedVibration) {
                        ForEach(viewModel.availableVibrationLevels, id: \.self) { level in
                            Text(level.rawValue).tag(level).foregroundColor(Color.white)
                        }
                    }
                    .pickerStyle(.inline)
                    .frame(width: 355 , height: 120)
                    .tint(.white)
                    // إطلاق الهزة فور تغيير الاختيار ليتأكد المستخدم أنها تعمل
                    .onChange(of: viewModel.selectedVibration) { _ in
                        HapticManager.instance.impactFromUserSetting()
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .onAppear {
            // ⭐️ FIXED: Update background based on current time when view appears ⭐️
            backgroundType = initialBackgroundType()
            
            // Optional: Update background based on current prayer time
            if let current = prayerViewModel.currentPrayer {
                backgroundType = backgroundType(for: current)
            }
        }
    }
    
    // ⭐️ Helper function to map prayer names to background types ⭐️
    func backgroundType(for prayer: PrayerTime) -> BackgroundType {
        switch prayer.name {
        case "الفجر": return .fajr
        case "العشاء": return .Isha
        case "المغرب": return .Maghrib
        case "العصر": return .asr
        default: return .Dhuhr // Includes Dhuhr
        }
    }
}

#Preview {
    setting()
}
