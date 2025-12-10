import Foundation
import Combine

class PrayerViewModel: ObservableObject {
    @Published var prayers: [PrayerTime] = []
    @Published var currentPrayer: PrayerTime?
//    @Published var backgroundType: BackgroundType = initialBackgroundType()

    private let service = PrayerService()
    private var timer: Timer?
    
    // ⭐️ TEST-SPECIFIC PROPERTY: Store the hardcoded Dates to bypass complex parsing
    private var testPrayerTimes: [String: Date] = [:]

    init() {
        NotificationManager.requestNotificationPermission()
        
        // ⚠️ REMEMBER TO SWITCH WHICH FUNCTION IS CALLED FOR TESTING VS LIVE API
         load()
//        self.loadTestPrayers()
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateCurrentPrayer()
        }
    }

    deinit {
        timer?.invalidate()
    }

    // ----------------------------------------------------
    // MARK: - API Loading (FIXED)
    // ----------------------------------------------------

    func load(city: String = "Riyadh", country: String = "SA") {
        service.fetchTodayPrayers(city: city, country: country) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let prayersFromAPI):
                    let formattedPrayers = prayersFromAPI.map { prayer in
                        // Use the now-English-only formatTo12Hour to standardize the API's raw time
                        PrayerTime(
                            name: prayer.name,
                            time: self.formatTo12Hour(prayer.time)
                        )
                    }
                    self.prayers = formattedPrayers
                    self.updateCurrentPrayer()
                    self.scheduleAllDailyNotifications()
                    
                    // ✅ PRINT STATEMENT FOR DATA CHECK
                    print("✅ LOAD (API) Data Format Check:")
                    self.prayers.forEach { p in
                        print("    \(p.name): \(p.time) (Internal format)")
                    }
                    
                case .failure(let error):
                    print("Error fetching prayers: \(error)")
                }
            }
        }
    }

    // ----------------------------------------------------
    // ⭐️ MARK: - TESTING FUNCTION (MODIFIED)
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
        
        // Use en_US_POSIX for a universal, predictable English format
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a" // e.g., "9:00 AM"
        formatter.timeZone = TimeZone.current

        let testPrayers: [PrayerTime] = hardcodedTimes.map { (name, minutes) in
            let futureDate = now.addingTimeInterval(minutes * 60)
            
            // The timeString is now guaranteed to be the English format (e.g., "12:03 PM")
            let timeString = formatter.string(from: futureDate)
            
            // Store the actual future Date using the English time string as the key
            testDataMap[timeString] = futureDate
            
            return PrayerTime(name: name, time: timeString)
        }
        
        // 3. Update the ViewModel state
        self.testPrayerTimes = testDataMap // Store the hardcoded Dates
        self.prayers = testPrayers
        self.updateCurrentPrayer()
        
        // 4. Call the original scheduling function
        self.scheduleAllDailyNotifications()
        
        // ✅ PRINT STATEMENT FOR DATA CHECK
        print("✅ TEST LOAD Data Format Check:")
        self.prayers.forEach { p in
            print("    \(p.name): \(p.time) (Internal format)")
        }
    }

    // ----------------------------------------------------
    // MARK: - Scheduling and Formatting (The core functions)
    // ----------------------------------------------------

    private func scheduleAllDailyNotifications() {
        NotificationManager.scheduleAllDailyNotifications(
            prayers: self.prayers,
            timeConverter: self.dateForToday
        )
    }

    // ⭐️ MODIFIED: Now consistently returns the standard English format (e.g., "3:30 PM")
    private func formatTo12Hour(_ timeString: String) -> String {
        guard let date = dateForToday(from: timeString) else {
            return timeString
        }

        let formatter = DateFormatter()
        // Use a standard English locale for consistent "h:mm a" output
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current

        // Removed all manual Arabic character replacements.
        return formatter.string(from: date)
    }

    // ⭐️ MODIFIED: Prioritizes parsing the standardized English time format
    private func dateForToday(from timeString: String) -> Date? {
        
        // 1. If we have test data, use the precise Date from the map
        if let testDate = self.testPrayerTimes[timeString] {
            return testDate
        }
        
        // 2. NEW LOGIC: Try to parse the standardized English 12-hour format "h:mm a"
        // This handles the data coming from the 'load' function.
        let standardTimeFormatter = DateFormatter()
        standardTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
        standardTimeFormatter.dateFormat = "h:mm a"
        standardTimeFormatter.timeZone = TimeZone.current

        if let dateFromStandardTime = standardTimeFormatter.date(from: timeString) {
            // Adjust the date to today's date at that time
            let calendar = Calendar.current
            var components = calendar.dateComponents([.hour, .minute], from: dateFromStandardTime)
            
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            components.year = todayComponents.year
            components.month = todayComponents.month
            components.day = todayComponents.day
            
            return calendar.date(from: components)
        }
        
        // 3. Fallback to original complex parsing logic for the raw API string format
        // (if the API returns something unexpected, like "15:30:00" without AM/PM)
        
        let trimmed = timeString.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
        // WARNING: This conversion to Int() will fail if the raw API string contains Arabic-Indic numerals.
        // However, if the API returns standard 24-hour time (e.g., "15:30"), this works.
        guard hm.count >= 2,
              let rawHour = Int(hm[0]),
              let minute = Int(hm[1]) else { return nil }
        
        var hour = rawHour
        
        if let marker = marker {
            let lower = marker.lowercased()
            // This is old logic for AM/PM/ص/م parsing, kept as a final safety fallback.
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
