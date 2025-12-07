//
//  qiblaView.swift
//  PrayerTime
//
//  Created by Linda on 04/12/2025.
//



import SwiftUI

import SwiftUI
import CoreLocation // Assuming QiblaViewModel uses CoreLocation



struct QiblaView_WatchOS: View { // Kept original name
    @State private var currentGradient: [Color] = []
    @StateObject private var viewModel = QiblaViewModel()
    @State private var backgroundType: BackgroundType = {
            return initialBackgroundType()
        }()
    
    // Environment dismiss is not usually needed on watchOS as NavigationLink handles the back action
    // @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            createBackgroundGradient(for: backgroundType)
            .ignoresSafeArea()
            
            ScrollView { // Wrapped content in ScrollView for watchOS layout consistency
                VStack(spacing: 20) { // ADJUSTED: Reduced spacing from 77
                    
                    // --- REMOVED/REPLACED HEADER ---
                    // The custom HStack header is REMOVED because .navigationTitle handles the header.
                    
                    // Add current angle for information
                    Text("\(Int(viewModel.qiblaAngle))°")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    // --- END HEADER REPLACEMENT ---
                    
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            // ADJUSTED: Reduced size from 350 to 150
                            .frame(width: 150, height: 150)
                            // REMOVED: .padding(.top,-88) - No longer needed with ScrollView
                        
                        // Compass Arrow
                        Image(systemName: "location.north.fill")
                            .resizable()
                            .scaledToFit()
                            // ADJUSTED: Reduced size from 130 to 60
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.white.opacity(0.75))
                            .rotationEffect(.degrees(viewModel.qiblaAngle))
                            .animation(.easeInOut(duration: 0.2), value: viewModel.qiblaAngle)
                        
                        // Kaba
                        KabaOnCircle(angle: viewModel.qiblaAngle)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.qiblaAngle)
                    }
            
                    
                }
            } // End ScrollView
        }

        .navigationTitle("القبلة")
    
    }
}

private struct KabaOnCircle: View {
    let angle: Double
    
    // اضبط نصف القطر لتعويض الـ padding/top بحيث الكعبة تكون على الحافة بصريًا
    private let radius: CGFloat = 150 // قريب من نصف 350 مع تعويض بسيط
    // تعويض بسيط للمحاذاة العمودية بسبب .padding(.top, -88) في الدائرة
    private let verticalAdjust: CGFloat = 80
    
    var body: some View {
        let radians = CGFloat((angle - 90).degreesToRadians) // -90° لجعل 0° للأعلى
        let x = radius * cos(radians)
        let y = radius * sin(radians)
        
        return Image("kaba")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .offset(x: x, y: y + verticalAdjust)
    }
}

#Preview {
    QiblaView_WatchOS()
}

