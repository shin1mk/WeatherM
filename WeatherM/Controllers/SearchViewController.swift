//
//  SearchViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 13.08.2023.
//

import UIKit
import SnapKit
import Foundation

final class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, StoneDelegate {
    func stoneViewDidUpdateState(_ state: StoneView.State) {
        print("StoneView state updated to: \(state)")

    }
    
    weak var locationDelegate: LocationDelegate?
    weak var weatherDelegate: WeatherDelegate?
    private let countryManager = CountryManager(queue: DispatchQueue(label: "CountryManager_working_queue", qos: .userInitiated))
    private let stoneView = StoneView()
    private let weatherView = WeatherView()
    private let locationView = LocationView()
    private var isConnected = true
    private var windSpeed: Double = 0.0
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
    var cities = CityData.cities
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
        stoneView.stoneDelegate = self
    }
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCities = []
        } else {
            filteredCities = cities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        print("Filtered cities: \(filteredCities)")
        tableView.reloadData() // Обновляем таблицу
        tableView.isHidden = filteredCities.isEmpty
        // Вызываем функцию updateCountry когда ввожу город
        if let selectedCity = filteredCities.first {
            let components = selectedCity.split(separator: ",")
            let city = String(components.first ?? "")
            let countryCode = String(components.last ?? "")
            // получаем данные о погоде
            countryManager.updateCountry(for: city, countryCode: countryCode) { completionData in
                print("Текущая температура в \(selectedCity): \(completionData.temperature)°C")
                print("Скорость ветра в \(selectedCity): \(completionData.windSpeed) м/с")
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let selectedCity = searchBar.text {
            // Парсим
            let components = selectedCity.split(separator: ",")
            let city = String(components.first ?? "")
            let countryCode = String(components.last ?? "")
            // Вызываем функцию updateCountry
            countryManager.updateCountry(for: city, countryCode: countryCode) { completionData in
                // Другие обновления интерфейса
                self.didUpdateLocationLabel(completionData.city + ", " + completionData.country)
                self.stoneView.updateWeatherData(completionData, isConnected: self.isConnected)
                self.stoneView.windSpeed = completionData.windSpeed
                // Закрываем клавиатуру и скрываем таблицу
                self.searchBar.text = selectedCity
                self.tableView.isHidden = false
                self.searchBar.resignFirstResponder()
                // Вызываем функцию для обновления состояния stoneView
                print("Completion Data - Temperature: \(completionData.temperature)")
                print("Completion Data - Condition Code: \(completionData.id)")
                print("Completion Data - Wind Speed: \(completionData.windSpeed)")
                
                // Вызовите updateStoneViewState с новыми данными
                self.updateStoneViewState(
                    temperature: completionData.temperature,
                    conditionCode: completionData.id,
                    windSpeed: completionData.windSpeed
                )
                print("New StoneView State: \(self.stoneView.state)")

            }
        }
        searchBar.resignFirstResponder() // Закрываем клавиатуру
    }
    
    func didUpdateLocationLabel(_ text: String) {
        locationDelegate?.didUpdateLocationLabel(text)
    }
    
    func weatherViewDidTemperature(_ text: String) {
        print("SearchViewController received updated temperature text: \(text)")
        weatherDelegate?.weatherViewDidTemperature(text)
    }
    
    func weatherViewDidCondition(_ text: String) {
        print("SearchViewController received updated condition text: \(text)")
        weatherDelegate?.weatherViewDidCondition(text)
    }
    func updateStoneViewState(temperature: Int, conditionCode: Int, windSpeed: Double) {
        // Определим State на основе данных о погоде
        let newState = StoneView.State(temperature: temperature, conditionCode: conditionCode, windSpeed: windSpeed)
        stoneView.state = newState
    }

} // end SearchViewController
//MARK: Gestures
extension SearchViewController: UIGestureRecognizerDelegate {
    // Gestures
    private func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissSearchView))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    // Dismiss
    @objc private func dismissSearchView() {
        dismiss(animated: true, completion: nil)
    }
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
        
        countryManager.updateCountry(for: city, countryCode: countryCode) { completionData in
            let temperature = completionData.temperature
            let windSpeed = completionData.windSpeed
            print("Текущая температура в \(selectedCity): \(temperature)°C")
            print("Скорость ветра в \(selectedCity): \(windSpeed) м/с")
            // Обновить UI
            DispatchQueue.main.async {
                self.weatherViewDidTemperature("\(completionData.temperature)°")
                self.weatherViewDidCondition(completionData.weather)
                self.didUpdateLocationLabel(completionData.city + ", " + completionData.country)
                
                // Вызовите updateStoneViewState с новыми данными
                self.updateStoneViewState(
                    temperature: completionData.temperature,
                    conditionCode: completionData.id,
                    windSpeed: completionData.windSpeed
                )
                
                // Теперь стейт должен обновиться и картинка в StoneView изменится.
                print("New StoneView State: \(self.stoneView.state)")
                
                // сворачиваем по нажатию на город
                self.dismiss(animated: true, completion: nil)
            }
        }
        searchBar.text = selectedCity
        searchBar.resignFirstResponder()
        tableView.isHidden = false
    }

}
