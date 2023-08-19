//
//  SearchViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 13.08.2023.
//

import UIKit
import SnapKit
import Foundation

final class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {
    //MARK: Properties
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a city"
        searchBar.backgroundImage = UIImage()
        searchBar.becomeFirstResponder()
        return searchBar
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
        return tableView
    }()
    var cities = ["Texas", "Forde", "Roros", "Dalvik", "Hofn", "Denver", "Dnipro", "Kyiv", "Keflavik"] // список городов
    var filteredCities: [String] = []
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundView()
        setupConstraints()
        setupDelegates()
        setupGestures()
    }
    //MARK: Constraints
    private func setupConstraints() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    //MARK: Methods
    private func setupBackgroundView() {
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        view.addSubview(backgroundView)
    }
    // Delegates
    private func setupDelegates() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCities = []
        } else {
            filteredCities = cities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        print("Filtered cities: \(filteredCities)")
        tableView.reloadData() // Обновляем
        tableView.isHidden = filteredCities.isEmpty
        
        // Вызываем функцию fetchWeather, когда пользователь вводит город
        if let selectedCity = filteredCities.first {
            // Парсим выбранный город и код страны (если они есть)
            let components = selectedCity.split(separator: ",")
            let city = String(components.first ?? "")
            let countryCode = String(components.last ?? "")
            
            // Вызываем функцию fetchWeather для получения данных о погоде
            fetchWeather(for: city, countryCode: countryCode) { temperature, windSpeed in
                // Вы можете сделать что-то с этой температурой, например, отобразить ее на экране
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let selectedCity = searchBar.text {
            // Парсим выбранный город и код страны (если они есть)
            let components = selectedCity.split(separator: ",")
            let city = String(components.first ?? "")
            let countryCode = String(components.last ?? "")
            
            // Вызываем функцию fetchWeather для получения данных о погоде
            fetchWeather(for: city, countryCode: countryCode) { temperature, windSpeed in
                print("Текущая температура в \(selectedCity): \(temperature)°C")
                // Вы можете сделать что-то с этой температурой, например, отобразить ее на экране
            }
        }
        searchBar.resignFirstResponder() // Закрываем клавиатуру
    }
} // end SearchViewController
//MARK: Gestures
extension SearchViewController: UIGestureRecognizerDelegate {
    // Gestures
    private func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissSearchView))
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        swipeGesture.direction = .down
//        tapGesture.delegate = self
        view.addGestureRecognizer(swipeGesture)
//        view.addGestureRecognizer(tapGesture)
    }
    // Dismiss
    @objc private func dismissSearchView() {
        dismiss(animated: true, completion: nil)
    }
    // Tap
//    @objc private func handleTap(sender: UITapGestureRecognizer) {
//        let tapLocation = sender.location(in: view)
//        if !tableView.frame.contains(tapLocation) {
//            searchBar.endEditing(true)
//        }
//    }
}
//MARK: Table View
extension SearchViewController: UITableViewDelegate {
    // numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = filteredCities[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        return cell
    }
    // MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = filteredCities[indexPath.row]
        print("Selected city: \(selectedCity)")
        
        let components = selectedCity.split(separator: ",")
        let city = String(components.first ?? "")
        let countryCode = String(components.last ?? "")
        
        fetchWeather(for: city, countryCode: countryCode) { temperature, windSpeed in
            print("Текущая температура в \(selectedCity): \(temperature)°C")
            print("Скорость ветра: \(selectedCity): \(windSpeed) м/с")
            
            // Обновите ваш интерфейс с информацией о погоде здесь
            DispatchQueue.main.async {
                // Например, обновите UILabels на экране
                //                self.temperatureLabel.text = "\(temperature)°C"
                //                self.windSpeedLabel.text = "\(windSpeed) м/с"
                // сворачиваем по нажатию на выбранный город
                self.dismiss(animated: true, completion: nil)
            }
        }

        searchBar.text = selectedCity
        tableView.isHidden = false
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController {
    func fetchWeather(for city: String, countryCode: String, completion: @escaping (Int, Double) -> Void) {
        let apiKey = "57f0aada42de195465afd5586ed94a91"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city),\(countryCode)&appid=\(apiKey)&units=metric"
        
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
                            if let main = json["main"] as? [String: Any],
                               let temperature = main["temp"] as? Double,
                               let wind = json["wind"] as? [String: Any],
                               let windSpeed = wind["speed"] as? Double {
                                print("Текущая температура в \(city): \(temperature)°C")
                                completion(Int(ceil(temperature)), windSpeed)
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
