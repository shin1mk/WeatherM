//
//  MainViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 30.07.2023.
//

import UIKit
import SnapKit
import CoreLocation

final class MainViewController: UIViewController, UISearchBarDelegate {
    //MARK: - import view's
    private let stoneView = StoneView()
    private let weatherView = WeatherView()
    private let locationView = LocationView()
    private let infoButton = InfoButton()
    private let infoView = InfoView()
    private let weatherOperations = WeatherOperations()
    //MARK: Location
    private let locationManager = CLLocationManager()
    //MARK: backgroundImage
    private let backgroundImageView: UIImageView = {
        let backgroundImage = UIImageView(image: UIImage(named: "image_background.png"))
        backgroundImage.contentMode = .scaleAspectFit
        return backgroundImage
    }()
    //MARK: - Scroll View
    private let scrollView: UIScrollView = {
        var view = UIScrollView()
        view.isScrollEnabled = true
        view.alwaysBounceVertical = true
        return view
    }()
    private let contentView = UIView()
    //MARK: SearchBar
    private var isSearchBarVisible = false
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a city"
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupTargets()
        setupLocationManager()
        setupSearchBarDelegate()
        setupTapGestureRecognizer()
        hideSearchBar()
        infoView.isHidden = true
//        weatherOperations.fetchWeather()
    }
    //MARK: Constraints
    private func setupConstraints() {
        // background image
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // content view
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.top.bottom.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        // stone view
        contentView.addSubview(stoneView)
        stoneView.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.trailing.leading.equalTo(contentView)
            make.top.equalTo(contentView).offset(-100)
        }
        // searchBar
        contentView.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-20)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
        // weather view
        view.addSubview(weatherView)
        weatherView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).inset(350)
            make.horizontalEdges.equalToSuperview().inset(25)
        }
        // location view
        view.addSubview(locationView)
        locationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).inset(100)
            make.horizontalEdges.equalToSuperview().inset(30)
            make.height.equalTo(40)
        }
        // info button
        view.addSubview(infoButton)
        infoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(65)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(40)
            make.height.equalTo(85)
        }
        // Info View
        view.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(350)
            make.height.equalTo(450)
        }
    }
    //MARK: Methods
    // скрыть при загрузке search bar
    private func hideSearchBar() {
        searchBar.isHidden = true
    }
} // end MainViewController
//MARK: - геолокация
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Геолокация разрешена
            break
        case .denied, .restricted:
            // Геолокация отклонена
            break
        default:
            break
        }
    }
//    //результат геолокации
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        // выводим в консоль широту и долготу
//        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
//        let geocoder = CLGeocoder()
//        // геокодирование
//        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
//            if let error = error {
//                print("Error \(error.localizedDescription)")
//                return
//            }
//            if let placemark = placemarks?.first {
//                // Получаем название города
//                if let city = placemark.locality, let countryCode = placemark.isoCountryCode {
//                    print("City: \(city), Country: \(countryCode)")
//                    // выводим в locationLabel
//                    self.locationView.setLocationLabelText("\(city), \(countryCode)")
//
//                    // Вызываем функцию fetchWeather() с полученными данными о городе и стране
//                    WeatherOperations().fetchWeather(for: city, countryCode: countryCode)
//                }
//            }
//        }
//    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // выводим в консоль широту и долготу
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        let geocoder = CLGeocoder()
        // геокодирование
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                // Получаем название города
                if let city = placemark.locality, let countryCode = placemark.isoCountryCode {
                    print("City: \(city), Country: \(countryCode)")
                    // выводим в locationLabel
                    self?.locationView.setLocationLabelText("\(city), \(countryCode)")

                    // Вызываем функцию fetchWeather() с полученными данными о городе и стране
                    WeatherOperations().fetchWeather(for: city, countryCode: countryCode) { temperature in
                        DispatchQueue.main.async {
                            self?.weatherView.temperatureLabel.text = "\(temperature)°"
                        }
                    }
                }
            }
        }
    }

}
//MARK: - targets/delegates/actions
extension MainViewController {
    //MARK: Search Bar Delegate Setup
    private func setupSearchBarDelegate() {
        searchBar.delegate = self
        locationManager.delegate = self
    }
    // target
    private func setupTargets() {
        locationView.getLocationIconButton().addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        locationView.getSearchIconButton().addTarget(self, action: #selector(searchIconTapped), for: .touchUpInside)
        infoButton.infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
    
    //MARK: location button tap action
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
    }
    //MARK: метод для вызова разрешение для гео
    @objc private func locationButtonTapped() {
        locationManager.startUpdatingLocation()
    }
    //MARK: Search button Tap Action
    @objc private func searchIconTapped() {
        print("searchIcon tapped")
        isSearchBarVisible.toggle()
        searchBar.isHidden = !isSearchBarVisible
        // Show the keyboard
        if isSearchBarVisible {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
    }
    //MARK: Info Button Action
    @objc private func infoButtonTapped() {
        print("info_button")
        infoView.isHidden = !infoView.isHidden
    }
}
//MARK: - gesture recognizer
extension MainViewController: UIGestureRecognizerDelegate {
    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    //MARK: - keyboard
    @objc private func handleTap() {
        // Скрываем клавиатуру
        searchBar.resignFirstResponder()
        // Скрываем UISearchBar
        isSearchBarVisible = false
        searchBar.isHidden = true
    }
}


