import Foundation
import Combine

class PrayerViewModel: ObservableObject {
    @Published var prayers: [PrayerTime] = []
    @Published var currentPrayer: PrayerTime?

    private let service = PrayerService()
    private var timer: Timer?

    init() {
        load()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateCurrentPrayer()
        }
    }

    deinit {
        timer?.invalidate()
    }

    func load(city: String = "Riyadh", country: String = "SA") {
        service.fetchTodayPrayers(city: city, country: country) { [weak self] result in
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
                case .failure(let error):
                    print("Error fetching prayers: \(error)")
                }
            }
        }
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

    private func dateForToday(from timeString: String) -> Date? {
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
