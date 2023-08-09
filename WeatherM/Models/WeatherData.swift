//
//  WeatherData.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 09.08.2023.
//

import Foundation

struct WeatherData: Codable {
    var name: String
    var sys: Sys
    var weather: [Weather]
    var main: Main
    var wind: Wind
    var cod: Int
}

struct Weather: Codable {
    var id: Int
    var main: String
}

struct Sys: Codable {
    var country: String
}

struct Wind: Codable {
    var speed: Double
}

struct Main: Codable {
    var temp: Double
}

struct Cod: Codable {
    var cod: Int
}

struct CompletionData {
    let city: String
    let country: String
    let temperature: Int
    let weather: String
    let id: Int
    let windSpeed: Double
    let cod: Int
}
