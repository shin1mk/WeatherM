//
//  WeatherManager.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

// api key 57f0aada42de195465afd5586ed94a91

import Foundation

final class WeatherManager {
    private let queue = DispatchQueue(label: "WeatherManager_working_queue", qos: .userInitiated)
    
    func updateWeather(for latitude: Double,
                      longitude: Double,
                      completion: @escaping (CompletionData) -> Void) {
        let apiKey = "57f0aada42de195465afd5586ed94a91"
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)") else {return}
        queue.async {
            let task = URLSession.shared.dataTask(with: url) { data, responce, error in
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

/*
 https://openweathermap.org/weathermap?basemap=map&cities=true&layer=radar&lat=65.2107&lon=-10.5249&zoom=6
 Dnepr
 48,4647
 35,0462
 
 stavern norway rain
 58,99964
 10,04645
 */

