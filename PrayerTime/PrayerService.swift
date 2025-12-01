import Foundation

class PrayerService {
    
    func fetchTodayPrayers(
        city: String = "Riyadh",
        country: String = "SA",
        completion: @escaping (Result<[PrayerTime], Error>) -> Void
    ) {
        var components = URLComponents(string: "https://api.aladhan.com/v1/timingsByCity")!
        components.queryItems = [
            URLQueryItem(name: "city", value: city),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "method", value: "4"),
            URLQueryItem(
                name: "tune",
                value: "0,2,0,1,1,1,1,1,0"
              
            )
        ]

        guard let url = components.url else {
            let error = NSError(domain: "PrayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                let error = NSError(domain: "PrayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(PrayerAPIResponse.self, from: data)
                let t = decoded.data.timings

                let prayers: [PrayerTime] = [
                    PrayerTime(name: "الفجر",  time: t.Fajr),
                    PrayerTime(name: "الظهر",  time: t.Dhuhr),
                    PrayerTime(name: "العصر",  time: t.Asr),
                    PrayerTime(name: "المغرب", time: t.Maghrib),
                    PrayerTime(name: "العشاء", time: t.Isha)
                ]

                DispatchQueue.main.async {
                    completion(.success(prayers))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
