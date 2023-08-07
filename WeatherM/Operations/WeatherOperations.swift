//
//  WeatherOperations.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

// api key 57f0aada42de195465afd5586ed94a91

import Foundation

final class WeatherOperations {
    private let queue = DispatchQueue(label: "WeatherManager_working_queue", qos: .userInitiated)
    
    func fetchWeather(for city: String, countryCode: String, completion: @escaping (Int, String) -> Void) {
        let apiKey = "57f0aada42de195465afd5586ed94a91"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city),\(countryCode)&appid=\(apiKey)"

        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Ошибка: \(error)")
                    print("Error: \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let main = json["main"] as? [String: Any], let temperature = main["temp"] as? Double {
                                let temperatureCelsius = temperature - 273.15
                                let roundedTemperature = Int(temperatureCelsius.rounded())
                                
                                if let weatherArray = json["weather"] as? [[String: Any]], let weatherDescription = weatherArray.first?["description"] as? String {
                                    print("Температура \(city): \(roundedTemperature)°C")
                                    print("Состояние погоды в \(city): \(weatherDescription)")
                                    completion(roundedTemperature, weatherDescription)
                                } else {
                                    print("Ошибка при получении данных о погоде.")
                                }
                            } else {
                                print("Ошибка при получении данных о погоде.")
                            }
                        }
                    } catch {
                        print("Ошибка при обработке ответа: \(error)")
                    }
                }
            }
            task.resume()
        } else {
            print("Ошибка в URL.")
        }
    }
}




/*
 https://www.rainviewer.com/ua/ru/weather-radar-map-live.html
 https://openweathermap.org/weathermap?basemap=map&cities=true&layer=radar&lat=65.2107&lon=-10.5249&zoom=6
 Dnepr  48,4647
        35,0462

 stavern norway rain
 58,99964
 10,04645
*/

