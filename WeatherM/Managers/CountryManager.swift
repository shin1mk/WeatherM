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
    
    func updateCountry(for city: String, completion: @escaping (CompletionData) -> Void) {
        let apiKey = "57f0aada42de195465afd5586ed94a91"
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric") else { return }
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
