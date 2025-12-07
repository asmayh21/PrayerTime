//
//  celestialBody.swift
//  PrayerTime
//
//  Created by Linda on 07/12/2025.
//

import SwiftUI

struct CelestialBodyView: View {
    
    let backgroundType: BackgroundType
    
    var body: some View {
        // Use ViewBuilder to conditionally return the ZStack content
        celestialBodyContent
    }
    
    @ViewBuilder
    private var celestialBodyContent: some View {
        // ⭐️ Night/Dawn Time: Moon and Clouds
        if backgroundType == .Isha || backgroundType == .fajr {
            ZStack {
                // Moon (White Circle)
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 120, height: 120)
                    .shadow(color: .white.opacity(0.3), radius: 30)
                
                // Moon Craters/Details (Grey Circles)
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 25, height: 25)
                    .offset(x: -15, y: -10)
                
                Circle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 30, height: 30)
                    .offset(x: 20, y: 15)
                
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 20, height: 20)
                    .offset(x: 10, y: -20)
                
                // غيوم الفجر (Night Clouds - Optional based on specific time)
                if backgroundType == .Isha {
                    Capsule()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 60, height: 20)
                        .offset(x: -70, y: 30)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 50, height: 18)
                        .offset(x: 75, y: 20)
                }
            }
        }
        // ⭐️ Day/Sunset Time: Sun and Clouds
        else {
            ZStack {
                // Sun (Radial Gradient)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.9),
                                Color.orange.opacity(0.7)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 130, height: 130)
                    .shadow(color: .yellow.opacity(0.4), radius: 30)
                
                // غيوم الظهر (Mid-Day Clouds)
                if backgroundType == .Dhuhr {
                    Capsule()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 60, height: 20)
                        .offset(x: -70, y: 30)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 50, height: 18)
                        .offset(x: 75, y: 20)
                }
                
                // غيوم العصر (Afternoon Clouds)
                if backgroundType == .asr {
                    Capsule()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 60, height: 20)
                        .offset(x: -70, y: 30)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 50, height: 18)
                        .offset(x: 75, y: 20)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 45, height: 17)
                        .offset(x: 60, y: -45)
                }
            }
        }
    }
}
