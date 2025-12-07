import SwiftUI

import SwiftUI



struct PrayerTimesView: View {
    @ObservedObject var viewModel: PrayerViewModel
    
    @State private var selectedPrayerID: UUID?
    //check for current time to reflect the bg
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
            // FIXED: Use the single state variable for the gradient
            createBackgroundGradient(for: backgroundType)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ... (Toolbar/Header Content remains the same) ...
                HStack(spacing: 12) {
                    // Settings Button
                    Button(action: { /* Add Navigation Here */ }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    // Qibla Navigation Link
                    NavigationLink(destination: QiblaView()) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 50)
                
                Spacer()
                
                if prayers.isEmpty {
                    VStack {
                        ProgressView().tint(.white).scaleEffect(1.3).padding(.bottom, 16)
                        Text("جاري تحميل مواقيت الصلاة...").foregroundColor(.white.opacity(0.9)).font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 200)
                            
                        // FIXED: Use the single state variable to pass to the external view
                        CelestialBodyView(backgroundType: backgroundType)
                    }
                    .padding(.horizontal, 24)
                    
                    Text("الآن وقت صلاة \(viewModel.currentPrayer?.name ?? "...")")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 12) {
                        ForEach(prayers) { prayer in
                            PrayerTimeRow(
                                name: prayer.name,
                                time: prayer.time,
                                isSelected: highlightedPrayerID == prayer.id
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    selectedPrayerID = prayer.id
                                    // FIXED: Update the backgroundType state
                                    backgroundType = backgroundType(for: prayer)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            // FIXED: Ensure backgroundType is set based on the actual current prayer time
            if let current = viewModel.currentPrayer {
                backgroundType = backgroundType(for: current)
            }
            
            // Note: If PrayerViewModel updates the current prayer time on a timer,
            // you should include logic here or in the ViewModel to force a state update
            // when the prayer changes (e.g., using a published property in the ViewModel).
        }
    }
    

    
    // Helper function remains to map prayer names to the shared enum
    func backgroundType(for prayer: PrayerTime) -> BackgroundType {
        switch prayer.name {
        case "الفجر": return .fajr
        case "العشاء": return .Isha
        case "المغرب": return .Maghrib
        case "العصر": return .asr
        default: return .Dhuhr // Includes Dhuhr
        }
    }
    
    // REMOVED the redundant static initialBackgroundType() function
}

struct PrayerTimeRow: View {
    let name: String
    let time: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 20))
                
                Text(name)
                    .font(.system(size: 18, weight: .medium))
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 16))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(isSelected ? 0.25 : 0.15))
        )
    }
}

struct ContentView2: View {
    @StateObject var viewModel = PrayerViewModel()
    
    var body: some View {
        NavigationStack {
            PrayerTimesView(viewModel: viewModel)
        }
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
