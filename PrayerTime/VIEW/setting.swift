//
//  setting.swift
//  PrayerTime
//
//  Created by rawan alkhaldi  on 18/06/1447 AH.
//

// SettingView.swift

import SwiftUI

struct setting: View {
    
    // 1. تعريف ViewModel كـ @StateObject (ضروري لـ MVVM)
    @StateObject var viewModel = SettingViewModel()
    
    // 2. ربط PrayerViewModel لمزامنة الخلفية مع توقيت الصلوات
    @StateObject var prayerViewModel = PrayerViewModel()
    
    // 3. تعريف الثوابت المساعدة للألوان (للعناصر الداخلية)
 //   let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.2)
    
    var body: some View {
        
        // استخدام حاوية رئيسية لتطبيق الخلفية الديناميكية حسب الصلاة
        ZStack {
            // نفس خلفية صفحة الصلوات باستخدام BackgroundType
            createBackgroundGradient(for: prayerViewModel.backgroundType)
                .ignoresSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 30) { // تم تغيير المحاذاة إلى .leading
                
                // العنوان
                Text("SETTINGS")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                
                // --- قسم اللغة ---
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Language")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        ForEach(viewModel.availableLanguages) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 345 , height: 54)
                    .padding(.horizontal, 10)
                    .background(Color.white .opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .onChange(of: viewModel.selectedLanguage) { _ in
                        viewModel.languageDidChange()
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .overlay(Color.black .opacity(0.3))
                    .padding()
                
                // --- قسم مستوى الاهتزاز (Segmented Control) ---
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Vibration Level")
                        .font(.system(size: 21))
                        .foregroundColor(.white)
                    
                    Picker("Vibration Level", selection: $viewModel.selectedVibration) {
                        ForEach(viewModel.availableVibrationLevels) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 355 , height: 60)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .onAppear {
            // تأكد من تحميل مواقيت الصلوات لتحديث الخلفية تلقائياً
            prayerViewModel.load()
        }
    }
}

#Preview {
    setting()
}
