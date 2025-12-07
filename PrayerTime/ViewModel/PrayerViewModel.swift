import Foundation
import Combine

class PrayerViewModel: ObservableObject {
    @Published var prayers: [PrayerTime] = []
    @Published var currentPrayer: PrayerTime?

    private let service = PrayerService()
    private var timer: Timer?
    
    // ⭐️ TEST-SPECIFIC PROPERTY: Store the hardcoded Dates to bypass complex parsing
    private var testPrayerTimes: [String: Date] = [:]

    init() {
        NotificationManager.requestNotificationPermission()
        
        // ⚠️ TEMPORARY CHANGE FOR TESTING:
         load() // <-- COMMENT THIS OUT
//        self.loadTestPrayers() // <-- USE THIS TO TEST NOTIFICATIONS
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateCurrentPrayer()
        }
    }

    deinit {
        timer?.invalidate()
    }

    // ----------------------------------------------------
    // MARK: - API Loading (Original Function)
    // ----------------------------------------------------

    func load(city: String = "Riyadh", country: String = "SA") {
        service.fetchTodayPrayers(city: city, country: country) { [weak self] result in
            // ... (rest of the original load logic remains the same) ...
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let prayersFromAPI):
                    let formattedPrayers = prayersFromAPI.map { prayer in
                        PrayerTime(
                            name: prayer.name,
                            time: self.formatTo12Hour(prayer.time)
                        )
                    }
                    self.prayers = formattedPrayers
                    self.updateCurrentPrayer()
                    self.scheduleAllDailyNotifications()
                case .failure(let error):
                    print("Error fetching prayers: \(error)")
                }
            }
        }
    }

    // ----------------------------------------------------
    // ⭐️ MARK: - TESTING FUNCTION
    // ----------------------------------------------------

    func loadTestPrayers() {
        let now = Date()
        
        // 1. Define hardcoded prayer times relative to NOW (in minutes)
        let hardcodedTimes: [(name: String, minutesOffset: TimeInterval)] = [
            ("Fajr Test", 2),
            ("Dhuhr Test", 4),
            ("Asr Test", 6),
            ("Maghrib Test", 8)
        ]

        // 2. Create the future Date objects and format the resulting array
        var testDataMap: [String: Date] = [:]
        
        let testPrayers: [PrayerTime] = hardcodedTimes.map { (name, minutes) in
            let futureDate = now.addingTimeInterval(minutes * 60)
            
            // Format the time string as if it came from the API/formatTo12Hour
            let timeString = self.formatTo12Hour(futureDate.description)
            
            // Store the actual future Date using the formatted time string as the key
            testDataMap[timeString] = futureDate
            
            return PrayerTime(name: name, time: timeString)
        }
        
        // 3. Update the ViewModel state
        self.testPrayerTimes = testDataMap // Store the hardcoded Dates
        self.prayers = testPrayers
        self.updateCurrentPrayer()
        
        // 4. Call the original scheduling function
        self.scheduleAllDailyNotifications()
        
        // OPTIONAL: Check scheduled notifications in the console
//        NotificationManager.checkPendingNotifications()
    }

    // ----------------------------------------------------
    // MARK: - Scheduling and Formatting (The core functions)
    // ----------------------------------------------------

    private func scheduleAllDailyNotifications() {
        // Pass the prayer data and the (now modified) time conversion function to the Manager
        NotificationManager.scheduleAllDailyNotifications(
            prayers: self.prayers,
            timeConverter: self.dateForToday // The function signature remains the same
        )
    }

    private func formatTo12Hour(_ timeString: String) -> String {
        guard let date = dateForToday(from: timeString) else {
            return timeString
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateFormat = "h:mm a"

        var formatted = formatter.string(from: date)
        formatted = formatted
            .replacingOccurrences(of: "AM", with: "ص")
            .replacingOccurrences(of: "PM", with: "م")

        return formatted
    }

    // ⭐️ MODIFIED: dateForToday now checks the test data map first
    private func dateForToday(from timeString: String) -> Date? {
        
        // 1. If we have test data, use the precise Date from the map
        if let testDate = self.testPrayerTimes[timeString] {
            return testDate
        }
        
        // 2. If not testing (i.e., data came from API), proceed with complex parsing
        // ... (original parsing logic for API strings) ...

        let trimmed = timeString.trimmingCharacters(in: .whitespacesAndNewlines)

        // ... (rest of the original complex parsing logic remains unchanged) ...
        
        // NOTE: Ensure your existing parsing logic correctly handles the Date.description format if needed
        // For the test, the initial if-block will typically handle the data.
        
        let noTZ: String
        if let parenRange = trimmed.range(of: "(") {
            noTZ = String(trimmed[..<parenRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        } else {
            noTZ = trimmed
        }
        
        let components = noTZ.split(separator: " ")
        guard let timePart = components.first else { return nil }
        let marker = components.count > 1 ? String(components[1]) : nil
        
        let hm = timePart.split(separator: ":")
        guard hm.count >= 2,
              let rawHour = Int(hm[0]),
              let minute = Int(hm[1]) else { return nil }
        
        var hour = rawHour
        
        if let marker = marker {
            let lower = marker.lowercased()
            if lower.contains("am") || lower.contains("ص") {
                if hour == 12 { hour = 0 }
            } else if lower.contains("pm") || lower.contains("م") {
                if hour < 12 { hour += 12 }
            }
        }
        
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = minute
        
        return Calendar.current.date(from: comps)
    }

    func updateCurrentPrayer() {
        let now = Date()

        let mapped: [(PrayerTime, Date)] = prayers.compactMap { prayer in
            guard let date = dateForToday(from: prayer.time) else { return nil }
            return (prayer, date)
        }

        if let current = mapped
            .filter({ $0.1 <= now })
            .sorted(by: { $0.1 > $1.1 })
            .first {
            currentPrayer = current.0
        } else {
            currentPrayer = mapped.sorted(by: { $0.1 < $1.1 }).first?.0
        }
    }
}
