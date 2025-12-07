
import SwiftUI

// Define the enum once
enum BackgroundType {
    case Isha
    case Dhuhr
    case Maghrib
    case fajr
    case asr
}

// Define the function that returns the LinearGradient based on the type
func createBackgroundGradient(for type: BackgroundType) -> LinearGradient {
    switch type {
    case .Isha, .fajr:
        return LinearGradient(
            colors: [
                Color(red: 0.15, green: 0.15, blue: 0.25),
                Color(red: 0.1, green: 0.1, blue: 0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    case .Dhuhr, .asr:
        return LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.6, blue: 0.95),
                Color(red: 0.6, green: 0.75, blue: 0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    case .Maghrib:
        return LinearGradient(
            colors: [
                Color(red: 0.65, green: 0.45, blue: 0.65),
                Color(red: 0.85, green: 0.6, blue: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}



 func initialBackgroundType() -> BackgroundType {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<6, 20...23: // Corresponds to Fajr/Isha time (Dark/Night)
            return .Isha
        case 6..<11, 11..<17: // Corresponds to Dhuhr/Asr time (Day/Blue Sky)
            return .Dhuhr
        case 17..<20: // Corresponds to Maghrib time (Sunset)
            return .Maghrib
        default: // Fallback
            return .Isha
        }
    }
