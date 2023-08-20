//
//  CountryManager.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 15.08.2023.
//

import Foundation

final class CountryManager {
    private let queue: DispatchQueue
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }
    
    func updateCountry(for city: String, countryCode: String, completion: @escaping (CompletionData) -> Void) {
        let apiKey = "57f0aada42de195465afd5586ed94a91"
        let cityWithCountry = "\(city),\(countryCode)"
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityWithCountry)&appid=\(apiKey)&units=metric") else { return }
        queue.async {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let weather = try? JSONDecoder().decode(WeatherData.self, from: data) {
                    let completionData = CompletionData(
                        city: weather.name,
                        country: weather.sys.country,
                        temperature: Int(weather.main.temp),
                        weather: weather.weather.first?.main ?? "",
                        id: weather.weather.first?.id ?? 0,
                        windSpeed: weather.wind.speed,
                        cod: weather.cod
                    )
                    DispatchQueue.main.async {
                        completion(completionData)
                    }
                }
            }
            task.resume()
        }
    }
}
// старый вариант
//extension SearchViewController {
//    func fetchWeather(for city: String, countryCode: String, completion: @escaping (Int, Double) -> Void) {
//        let apiKey = "57f0aada42de195465afd5586ed94a91"
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city),\(countryCode)&appid=\(apiKey)&units=metric"
//
//        if let url = URL(string: urlString) {
//            let task = URLSession.shared.dataTask(with: url) { data, response, error in
//                if let error = error {
//                    print("Ошибка: \(error)")
//                    print("Error: \(error.localizedDescription)")
//                    return
//                }
//
//                if let data = data {
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                            if let main = json["main"] as? [String: Any],
//                               let temperature = main["temp"] as? Double,
//                               let wind = json["wind"] as? [String: Any],
//                               let windSpeed = wind["speed"] as? Double {
//                                completion(Int(ceil(temperature)), windSpeed)
//                            } else {
//                                print("Ошибка при получении данных о погоде.")
//                            }
//                        }
//                    } catch {
//                        print("Ошибка при обработке ответа: \(error)")
//                    }
//                }
//            }
//            task.resume()
//        } else {
//            print("Ошибка в URL.")
//        }
//    }
//}