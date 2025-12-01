//
//  qibla.swift
//  PrayerTime
//
//  Created by sara on 10/06/1447 AH.
//

import SwiftUI

struct QiblaView: View {
    @State private var currentGradient: [Color] = []
    
    var body: some View {
        ZStack {
            // خلفية متدرجة تتغير حسب الوقت
            LinearGradient(
                colors: currentGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 77) {
                // Toolbar - شريط علوي بدون خلفية
                HStack {
                    // زر الرجوع
                    Button(action: {
                        // أكشن الرجوع
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            
                    }
                    .padding(.leading, 30)
                    
                    Spacer()
                    
                    // العنوان
                    Text("القبلة")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top,-10)

                    
                    Spacer()
                    
                    // مساحة فارغة للتوازن
                    Color.clear
                        .frame(width: 44)
                        .padding(.trailing, -20)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // أيقونة الكعبة
                Image("kaba")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // دائرة البوصلة
                ZStack {
                    // دائرة - تتغير شفافيتها حسب الوقت
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 350, height: 350)
                        .padding(.top,-30)

                    
                    // سهم البوصلة
                    Image(systemName: "location.north.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .foregroundColor(Color.white.opacity(0.75))
                        .padding(.top,-40)

                }
                
                Spacer()
            }
        }
        .onAppear {
            updateGradient()
        }
    }
    
    // دالة لتحديث التدرج اللوني حسب الوقت
    func updateGradient() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<6:
            // الليل والفجر - كحلي داكن
            currentGradient = [
                Color(red: 0.05, green: 0.08, blue: 0.12),
                Color(red: 0.08, green: 0.12, blue: 0.18),
                Color(red: 0.10, green: 0.14, blue: 0.20)
            ]
            
        case 6..<11:
            // الصباح - من أزرق غامق لأزرق فاتح
            currentGradient = [
                Color(red: 0x2D/255.0, green: 0x8C/255.0, blue: 0xFF/255.0),
                Color(red: 0xD1/255.0, green: 0xE0/255.0, blue: 0xFF/255.0)
            ]
            
        case 11..<17:
            // الظهر - من أزرق غامق لأزرق فاتح
            currentGradient = [
                Color(red: 0x2D/255.0, green: 0x8C/255.0, blue: 0xFF/255.0),
                Color(red: 0xD1/255.0, green: 0xE0/255.0, blue: 0xFF/255.0)
            ]
            
        case 17..<20:
            // المغرب والغروب - بنفسجي وبرتقالي
            currentGradient = [
                Color(red: 0.65, green: 0.50, blue: 0.75),
                Color(red: 0.85, green: 0.60, blue: 0.70),
                Color(red: 0.95, green: 0.70, blue: 0.55),
                Color(red: 0.85, green: 0.55, blue: 0.40)
            ]
            
        default:
            // الليل - كحلي داكن
            currentGradient = [
                Color(red: 0.05, green: 0.08, blue: 0.12),
                Color(red: 0.08, green: 0.12, blue: 0.18),
                Color(red: 0.10, green: 0.14, blue: 0.20)
            ]
        }
    }
}

#Preview {
    QiblaView()
}
