//
//  MainViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 30.07.2023.
//

/* todo
 изменить метод локации после запроса сразу выдавал результат +
 создать файл weather data +
 создать метод weather manager что бы получать из него название города ветер температуру состоние +
 создать экран инфо вью
 создать стейт что бы менялся камень
 создать анимации что бы качался камень
 создать метод обновления данных когда тянешь вниз
 создать экран с таблицой для поиска городов найти какой то апи 
*/
import UIKit
import SnapKit
import CoreLocation

final class MainViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    //MARK: - Import view's
    private let stoneView = StoneView()
    private let weatherView = WeatherView()
    private let weatherManager = WeatherManager()
    private let locationView = LocationView()
    private let locationManager = CLLocationManager()
    private let infoButton = InfoButton()
    private let infoView = InfoView()
    
    private let backgroundImageView: UIImageView = {
        let backgroundImage = UIImageView(image: UIImage(named: "image_background.png"))
        backgroundImage.contentMode = .scaleAspectFit
        return backgroundImage
    }()
    //MARK: Scroll-Content
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
    //MARK: State
//    private var currentStoneState: State = .normal {
//        didSet {
//            updateBackgroundImage()
//        }
//    }
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupTargets()
        setupLocationManager()
        setupSearchBarDelegate()
        setupTapGestureRecognizer()
        hideComponents()
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
            make.horizontalEdges.equalToSuperview().inset(70)
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
    // скрываем при загрузке SearchBar и InfoView
    private func hideComponents() {
        searchBar.isHidden = true
        infoView.isHidden = true
    }
    //MARK: Gesture
    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    //MARK: Keyboard
    @objc private func handleTap() {
        // Скрываем клавиатуру
        searchBar.resignFirstResponder()
        // Скрываем UISearchBar
        isSearchBarVisible = false
        searchBar.isHidden = true
    }
    //MARK: Search Bar Delegate
    private func setupSearchBarDelegate() {
        searchBar.delegate = self
        locationManager.delegate = self
    }
    //MARK: Targers
    private func setupTargets() {
        locationView.getLocationIconButton().addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        locationView.getSearchIconButton().addTarget(self, action: #selector(searchIconTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
    //MARK: Request geo/start geo
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    //MARK: Location button action
    @objc private func locationButtonTapped() {
        print("location icon tapped")
        locationManager.startUpdatingLocation()
    }
    //MARK: Search button action
    @objc private func searchIconTapped() {
        print("search icon tapped")
        isSearchBarVisible.toggle()
        searchBar.isHidden = !isSearchBarVisible
        // Show the keyboard
        if isSearchBarVisible {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
    }
    //MARK: Info button action
    @objc private func infoButtonTapped() {
        print("info button tapped")
        infoView.isHidden = !infoView.isHidden
    }
    /*//MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Получаем координаты широты и долготы
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        WeatherManager().updateWeather(for: latitude, longitude: longitude) { weatherData in
            DispatchQueue.main.async {
                let weatherConditions = weatherData.weather
                let temperatureKelvin = weatherData.temperature
                let temperatureCelsius = Int(Double(temperatureKelvin) - 273.15) // конвертируем в цельсии
                let city = weatherData.city
                let country = weatherData.country
                let locationString = "Lat:\(latitude), Lon:\(longitude)"
                self.locationView.setLocationLabelText(locationString)

                self.weatherView.setTemperature(temperature: "\(temperatureCelsius)°")
                self.weatherView.setCondition(condition: weatherConditions)

                self.locationView.locationLabel.text = city + ", " + country
            }
        }
    }
    */
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        weatherManager.updateWeather(for: latitude, longitude: longitude) { complitionData in
            let weatherConditions = complitionData.weather
            let temperatureKelvin = complitionData.temperature
            let temperatureCelsiusValue = Double(temperatureKelvin) - 273.15
            let temperatureCelsius = Int(ceil(temperatureCelsiusValue))

            let city = complitionData.city
            let country = complitionData.country
            let windSpeedData = complitionData.windSpeed
            let conditionsCode = complitionData.cod
            DispatchQueue.main.async { [self] in
                self.weatherView.temperatureLabel.text = "\(temperatureCelsius)°"
                self.weatherView.conditionLabel.text = weatherConditions
                self.locationView.locationLabel.text = city + ", " + country
//                self.updateData(complitionData, isConnected: self.isConnected)
//                self.windSpeed = windSpeedData
                
                print("condition code  - \(conditionsCode)")
                print("windspeed  - \(windSpeedData)")
                print(temperatureCelsius)
            }
        }
    }
    
  
} // end MainViewController
