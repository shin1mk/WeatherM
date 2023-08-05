//
//  WeatherOperations.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

// api key 57f0aada42de195465afd5586ed94a91

import Foundation
/*
final class WeatherOperations {
    private let queue = DispatchQueue(label: "WeatherManager_working_queue", qos: .userInitiated)
    
    func fetchWeather() {
        let apiKey = "57f0aada42de195465afd5586ed94a91"
        let city = "dnepr"
        let countryCode = "ua"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city),\(countryCode)&appid=\(apiKey)"

        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Ошибка: \(error)")
                    return
                }

                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let main = json["main"] as? [String: Any], let temperature = main["temp"] as? Double {
                                let temperatureCelsius = temperature - 273.15
                                let roundedTemperature = Int(temperatureCelsius.rounded())
                                print("t': \(roundedTemperature)°C")
                            } else {
                                print("error blya")
                            }
                        }
                    } catch {
                        print("error: \(error)")
                    }
                }
            }
            task.resume()
        } else {
            print("Ошибка в URL.")
        }
    }
}
 */


//final class WeatherOperations {
//    private let queue = DispatchQueue(label: "WeatherManager_working_queue", qos: .userInitiated)
//
//    func fetchWeather(for city: String, countryCode: String) {
//        let apiKey = "57f0aada42de195465afd5586ed94a91"
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city),\(countryCode)&appid=\(apiKey)"
//        print("URL: \(urlString)")
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
//                            if let main = json["main"] as? [String: Any], let temperature = main["temp"] as? Double {
//                                let temperatureCelsius = temperature - 273.15
//                                let roundedTemperature = Int(temperatureCelsius.rounded())
//                                print("Температура\(city): \(roundedTemperature)°C")
//                                completion(roundedTemperature) // Pass the temperature to the completion closure
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
final class WeatherOperations {
    private let queue = DispatchQueue(label: "WeatherManager_working_queue", qos: .userInitiated)
    
    func fetchWeather(for city: String, countryCode: String, completion: @escaping (Int) -> Void) {
        let apiKey = "57f0aada42de195465afd5586ed94a91"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city),\(countryCode)&appid=\(apiKey)"
        print("URL: \(urlString)")

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
                                print("Температура \(city): \(roundedTemperature)°C")
                                completion(roundedTemperature) // Pass the temperature to the completion closure
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
