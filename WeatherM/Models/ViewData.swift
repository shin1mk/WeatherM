//
//  ViewData.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 20.08.2023.
//

import Foundation

struct ViewData {
    let temperature: String
    let weather: String

    init(temperature: String, weather: String) {
        self.temperature = temperature
        self.weather = weather
    }
}
