//
//  PrayerTimesView.swift
//  PrayerTime
//
//  Created by Linda on 04/12/2025.
//

import SwiftUI
import WatchConnectivity
import SwiftUI
import WatchConnectivity
// Assuming PrayerTime, PrayerViewModel, QiblaView exist and PrayerTime is Identifiable & Codable


struct PrayerTimeRow_WatchOS: View {
    let name: String
    let time: String
    let isSelected: Bool
    @State private var backgroundType: BackgroundType = {
            return initialBackgroundType()
        }()
    
    var body: some View {
        HStack {
            // Smaller icon for watchOS
            if name == "الظهر" || name == "العصر"  {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 20))
            } else if name == "الفجر" || name == "المغرب" {
                Image(systemName: "sun.horizon.fill")
                    .font(.system(size: 20))
            } else {
                Image(systemName: "moon.fill")
                    .font(.system(size: 20))
            }

            Text(name)
                .font(.system(size: 14, weight: .medium)) // Smaller font
            
            Spacer()
            
            Text(time)
                .font(.system(size: 14)) // Smaller font
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8) // Reduced padding
        .padding(.vertical, 8) // Reduced padding
        .background(
            RoundedRectangle(cornerRadius: 10) // Smaller corner radius
                .fill(Color.white.opacity(isSelected ? 0.25 : 0.15))
        )
        // Set list row padding to zero to hug the edges, simulating the original full width
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
    }
}

// --- PrayerTimesView for watchOS (Structure Preserved) ---

struct PrayerTimesView_WatchOS: View {
    @ObservedObject var viewModel: PrayerViewModel
    
    @State private var selectedPrayerID: UUID?
    
    @State private var backgroundType: BackgroundType = {
            return initialBackgroundType()
        }()
    
    var highlightedPrayerID: UUID? {
        selectedPrayerID ?? viewModel.currentPrayer?.id
    }
    
    var prayers: [PrayerTime] {
        viewModel.prayers
    }
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND (Retained)
            createBackgroundGradient(for: backgroundType)
                .ignoresSafeArea()
            
            // 2. MAIN CONTENT (Changed VStack to ScrollView/LazyVStack)
            ScrollView {
                VStack(spacing: 0) {
                              
                    // LOADING VIEW (Retained)
                    if prayers.isEmpty {
                        VStack {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8) // Smaller scale
                                .padding(.bottom, 8)
                            
                            Text("جاري تحميل مواقيت الصلاة...")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 12, weight: .medium)) // Smaller font
                        }
                        .padding(.vertical, 40) // Add vertical spacing for loading
                    } else {
                        // CELESTIAL BODY & INFO (Adapted)
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15) // Smaller corner radius
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 100) // Much smaller height
                                
                                // Celestial Body (Using the original logic, but scaled down)
//                                CelestialBodyView(backgroundType: backgroundType)
                                celestialBody_WatchOS
                            }
                            .padding(.horizontal, 8) // Reduced padding
                            
                            // Current Prayer Text (Retained style, smaller size)
                            Text("الآن وقت صلاة \(viewModel.currentPrayer?.name ?? "...")")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.top, 10)
                                .padding(.bottom, 10)
                            
                            // PRAYER LIST (Retained style, reduced spacing)
                            LazyVStack(spacing: 4) { // Tightened spacing
                                ForEach(prayers) { prayer in
                                    PrayerTimeRow_WatchOS( // Use the new watchOS row
                                        name: prayer.name,
                                        time: prayer.time,
                                        isSelected: highlightedPrayerID == prayer.id
                                    )
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            selectedPrayerID = prayer.id
                                            backgroundType = backgroundType(for: prayer)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 8) // Reduced padding
                            .padding(.bottom, 20) // Ensure enough space at the bottom
                        }
                    }
                }
            }.toolbar {
//                ToolbarItem(placement: .topBarLeading) { // Settings button on the leading side
//                    Button(action: {
//                        // Add navigation here
//                    }) {
//                        Image(systemName: "gearshape.fill")
//                            .font(.system(size: 16))
//                            .foregroundColor(.white.opacity(0.9))
//                            .frame(width: 35, height: 35)
//                            .background(Color.white.opacity(0.2))
//                            .clipShape(Circle())
//                    }
//                    .buttonStyle(.plain)
//                }
                
                ToolbarItem(placement: .topBarTrailing) { // Qibla button on the trailing side
                    NavigationLink(destination: QiblaView_WatchOS()) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 35, height: 35)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            } // End ScrollView
        }
        .onAppear {
            if let current = viewModel.currentPrayer ?? prayers.first {
                selectedPrayerID = current.id
                backgroundType = backgroundType(for: current)
            }
        }
    }

    
    func backgroundType(for prayer: PrayerTime) -> BackgroundType {
        switch prayer.name {
        case "الفجر": return .fajr
        case "العشاء": return .Isha
        case "المغرب": return .Maghrib
        case "العصر": return .asr
        default: return .Dhuhr
        }
    }
    
    // --- Celestial Body (Scaled Down) ---
    @ViewBuilder
    var celestialBody_WatchOS: some View { // Renamed to avoid collision with iPhone version
        if backgroundType == .Isha || backgroundType == .fajr {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 50, height: 50) // Reduced size
                    .shadow(color: .white.opacity(0.3), radius: 15) // Reduced shadow
                
                // Craters / details (Scaled down offsets)
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 10, height: 10)
                    .offset(x: -6, y: -4)
                
                Circle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 12, height: 12)
                    .offset(x: 8, y: 6)
                
                // Clouds (Scaled down sizes and offsets)
                if backgroundType == .Isha {
                    Capsule()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 25, height: 8)
                        .offset(x: -30, y: 12)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 20, height: 7)
                        .offset(x: 30, y: 8)
                }
            }
        } else {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.9),
                                Color.orange.opacity(0.7)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 30 // Reduced size
                        )
                    )
                    .frame(width: 55, height: 55) // Reduced size
                    .shadow(color: .yellow.opacity(0.4), radius: 15) // Reduced shadow
                
                // Clouds (Scaled down sizes and offsets)
                if backgroundType == .Dhuhr {
                    Capsule()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 25, height: 8)
                        .offset(x: -30, y: 12)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 20, height: 7)
                        .offset(x: 30, y: 8)
                }
                
                // Clouds for Asr (Scaled down sizes and offsets)
                if backgroundType == .asr {
                    Capsule()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 25, height: 8)
                        .offset(x: -30, y: 12)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 20, height: 7)
                        .offset(x: 30, y: 8)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 18, height: 6)
                        .offset(x: 25, y: -20)
                }
            }
        }
    }
}


struct ContentView2: View {
    @StateObject var viewModel = PrayerViewModel()
    
    var body: some View {
        NavigationStack {
            PrayerTimesView_WatchOS(viewModel: viewModel)
        }
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
