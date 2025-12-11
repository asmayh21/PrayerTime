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
        // 1) If testing map has exact Date, return it
        if let testDate = self.testPrayerTimes[timeString] {
            return testDate
        }

        let calendar = Calendar.current
        let today = Date()
        let todayYMD = calendar.dateComponents([.year, .month, .day], from: today)

        // Helper to build Date with today's Y/M/D and parsed H/M
        func buildTodayDate(from date: Date) -> Date? {
            var hm = calendar.dateComponents([.hour, .minute], from: date)
            var comps = todayYMD
            comps.hour = hm.hour
            comps.minute = hm.minute
            return calendar.date(from: comps)
        }

        // Try "h:mm a" first (for already formatted or test times)
        do {
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.timeZone = TimeZone.current
            fmt.dateFormat = "h:mm a"
            if let d = fmt.date(from: timeString) {
                return buildTodayDate(from: d)
            }
        }

        // Remove any trailing timezone in parentheses, e.g. "05:12 (AST)"
        let trimmed = timeString.trimmingCharacters(in: .whitespacesAndNewlines)
        let withoutTZ: String = {
            if let r = trimmed.range(of: "(") {
                return String(trimmed[..<r.lowerBound]).trimmingCharacters(in: .whitespaces)
            } else {
                return trimmed
            }
        }()

        // Try "HH:mm"
        do {
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.timeZone = TimeZone.current
            fmt.dateFormat = "HH:mm"
            if let d = fmt.date(from: withoutTZ) {
                return buildTodayDate(from: d)
            }
        }

        // Try "HH:mm:ss"
        do {
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.timeZone = TimeZone.current
            fmt.dateFormat = "HH:mm:ss"
            if let d = fmt.date(from: withoutTZ) {
                return buildTodayDate(from: d)
            }
        }

        // Final fallback: manual parsing (Western digits)
        let parts = withoutTZ.split(separator: ":")
        guard parts.count >= 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else {
            // Debug log if needed:
            // print("❌ Failed to parse time: \(timeString)")
            return nil
        }

        var comps = todayYMD
        comps.hour = hour
        comps.minute = minute
        return calendar.date(from: comps)
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

