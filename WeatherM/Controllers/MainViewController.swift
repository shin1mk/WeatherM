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
    // location
    private let locationManager = CLLocationManager()
    //MARK: backgroundImage
    private let backgroundImageView: UIImageView = {
        let backgroundImage = Constants.Images.backgroundImageView
        backgroundImage.contentMode = .scaleAspectFill
        return backgroundImage
    }()
    //MARK: temperatureLabel
    private let temperatureLabel: UILabel = {
        let temperatureLabel = UILabel()
        temperatureLabel.text = "20°"
        temperatureLabel.font = UIFont.ubuntuRegular(ofSize: 83)
        temperatureLabel.textColor = .black
        temperatureLabel.textAlignment = .left
        return temperatureLabel
    }()
    //MARK: conditionLabel
    private let conditionLabel: UILabel = {
        let conditionLabel = UILabel()
        conditionLabel.text = "wind"
        conditionLabel.font = UIFont.ubuntuLight(ofSize: 36)
        conditionLabel.textColor = .black
        conditionLabel.textAlignment = .left
        return conditionLabel
    }()
    //MARK: locationLabel
    private let locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.text = "Location"
        locationLabel.font = UIFont.ubuntuRegular(ofSize: 17)
        locationLabel.textColor = .black
        locationLabel.textAlignment = .center
        return locationLabel
    }()
    //MARK: locationIcon
    private let locationIconButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon_location"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    //MARK: searchIcon
    private let searchIconButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon_search"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    //MARK: searchBar
    private var isSearchBarVisible = false
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a city"
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    //MARK: infoButton
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "infoButton"), for: .normal)
        button.accessibilityIdentifier = "infoButton"
        return button
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
    }
    //MARK: Constraints
    private func setupConstraints() {
        // background image
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // searchBar
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.horizontalEdges.equalToSuperview().inset(30)
            make.height.equalTo(40)
        }
        // temerature label
        view.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints{ make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.snp.top).inset(500)
            make.horizontalEdges.equalToSuperview().inset(25)
        }
        // condition label
        view.addSubview(conditionLabel)
        conditionLabel.snp.makeConstraints{ make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(temperatureLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview().inset(25)
        }
        // location
        view.addSubview(locationLabel)
        locationLabel.snp.makeConstraints{ make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).inset(100)
            make.horizontalEdges.equalToSuperview().inset(30)
            make.height.equalTo(40)
        }
        // locationIconButton
        view.addSubview(locationIconButton)
        locationIconButton.snp.makeConstraints{ make in
            make.bottom.equalTo(view.snp.bottom).inset(110)
            make.leading.equalTo(locationLabel).inset(70)
            make.height.equalTo(16)
        }
        // searchIconButton
        view.addSubview(searchIconButton)
        searchIconButton.snp.makeConstraints{ make in
            make.bottom.equalTo(view.snp.bottom).inset(110)
            make.trailing.equalTo(locationLabel).offset(-70)
            make.height.equalTo(16)
        }
        // button
        view.addSubview(infoButton)
        infoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(65)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(40)
            make.height.equalTo(85)
        }
    }
    //MARK: - METHODS
    // скрыть при загрузке search bar
    private func hideSearchBar() {
        searchBar.isHidden = true
    }
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
} // end MainViewController




//MARK: Constants
extension MainViewController {
    enum Constants {
        enum Images {
            static let backgroundImageView = UIImageView(image: UIImage(named: "image_background.png"))
            static let locationIconImageView = UIImageView(image: UIImage(named: "icon_location.png"))
            static let searchIconImageView = UIImageView(image: UIImage(named: "icon_search.png"))
        }
    }
}
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
    //результат геолокации
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // выводим в консоль широту и долготу
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        let geocoder = CLGeocoder()
        // геокодирование
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                // Получаем название города
                if let city = placemark.locality, let country = placemark.country {
                    print("City: \(city), Country: \(country)")
                    // выводим в locationLabel
                    self.locationLabel.text = "\(country), \(city)"
                }
            }
        }
    }
    // ошибки геол
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
}
//MARK: - targets/delegates/actions
extension MainViewController {
    //MARK: - Search Bar Delegate Setup
    private func setupSearchBarDelegate() {
        searchBar.delegate = self
        locationManager.delegate = self
    }
    // target
    private func setupTargets() {
        locationIconButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        searchIconButton.addTarget(self, action: #selector(searchIconTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
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
    //MARK: Button Action
    @objc private func infoButtonTapped() {
        print("info_button")
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
