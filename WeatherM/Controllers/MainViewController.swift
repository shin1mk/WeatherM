//
//  MainViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 30.07.2023.
//

/* todo
 создать стейт что бы менялся камень
 создать анимации что бы качался камень
 создать метод обновления данных когда тянешь вниз
 создать экран с таблицой для поиска городов найти какой то апи
 
 https://openweathermap.org/weathermap?basemap=map&cities=true&layer=radar&lat=65.2107&lon=-10.5249&zoom=6
 Dnepr
 48,4647
 35,0462
 
 stavern norway rain
 58,99964
 10,04645
 */
import UIKit
import SnapKit
import CoreLocation
import Network


final class MainViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    //MARK: - Import view's
    private let stoneView = StoneView()
    private let weatherView = WeatherView()
    private let weatherManager = WeatherManager()
    private let locationView = LocationView()
    private let locationManager = CLLocationManager()
    private let infoButton = InfoButton()
    private let infoView = InfoView()
    
    private var windSpeed: Double = 0.0
    private var isConnected: Bool = true

    
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
            //            make.centerY.equalToSuperview().offset(view.frame.height) // Move it below the screen
            
            make.width.equalTo(277)
            make.height.equalTo(372)
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
        infoViewAnimation()
        //        infoView.isHidden = !infoView.isHidden
    }
    //MARK: animate Info View
    private func infoViewAnimation() {
        if infoView.isHidden {
            // Show the infoView
            infoView.isHidden = false
            infoView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
                self.infoView.transform = .identity
            } completion: { _ in
            }
        } else {
            UIView.animate(withDuration: 0.1, animations: {
                self.infoView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { _ in
                self.infoView.isHidden = true
                self.infoView.transform = .identity
            }
        }
    }
    //MARK: Location
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
            let conditionCode = complitionData.cod
            DispatchQueue.main.async { [self] in
                self.weatherView.temperatureLabel.text = "\(temperatureCelsius)°"
                self.weatherView.conditionLabel.text = weatherConditions
                self.locationView.locationLabel.text = city + ", " + country
                
                self.updateData(complitionData, isConnected: self.isConnected)
                self.windSpeed = windSpeedData
                
                print("condition code  - \(conditionCode)")
                print("windspeed  - \(windSpeedData)")
                print("t - \(temperatureCelsius)")
            }
        }
    }
    
    private var state: State = .normal(windy: false){
        didSet {
            print("State changed to: \(state)")
            updateWeatherState(state, windSpeed)
        }
    }
    
    private func updateData(_ data: CompletionData, isConnected: Bool) {
        print("updateData - temperature: \(data.temperature), conditionCode: \(data.id), windSpeed: \(data.windSpeed)")

        state = .init(temperature: data.temperature, conditionCode: data.id, windSpeed: data.windSpeed)
    }
    
    private func updateWeatherState(_ state: State, _ windSpeed: Double) {
        switch state {
        case .rain(windy: let isWindy):
            if isWindy {
                print("rain case Windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_wet.png"))
            } else {
                print("rain case NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_wet.png"))
            }
        case .hot(windy: let isWindy):
            if isWindy {
                print("hot case Windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_cracks.png"))
            } else {
                print("hot case NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_cracks.png"))
            }
        case .snow(windy: let isWindy):
            if isWindy {
                print("snow case Windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_snow.png"))
            } else {
                print("snow case NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_snow.png"))
            }
        case .fog(windy: let isWindy):
            if isWindy {
                print("fog case Windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_normal.png"))
                stoneView.alpha = 0.2
                
            } else {
                print("fog case NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_normal.png"))
                stoneView.alpha = 0.2
                
            }
        case .sunny(windy: let isWindy):
            if isWindy {
                print("sunny case Windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_wet.png"))
            } else {
                print("sunny case NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_wet.png"))
            }
        case .normal(windy: let isWindy):
            if isWindy {
                print("normal case Windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_wet.png"))
            } else {
                print("normal case NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_wet.png"))
            }
        case .noInternet:
            stoneView.isHidden = true
        }
        
    }
} // end MainViewController
//MARK: - extension MainViewController
enum State: Equatable {
    case rain(windy: Bool)
    case sunny(windy: Bool)
    case fog(windy: Bool)
    case hot(windy: Bool)
    case snow(windy: Bool)
    case normal(windy: Bool)
    case noInternet
    
    var isWindy: Bool {
        switch self {
        case .noInternet:
            print("No internet")
            return false
        case .snow(let windy):
            return windy
        case .hot(let windy):
            return windy
        case .rain(let windy):
            return windy
        case .sunny(let windy):
            return windy
        case .fog(let windy):
            return windy
        case .normal(let windy):
            return windy
        }
    }

    init(temperature: Int, conditionCode: Int, windSpeed: Double) {
        print("init - temperature: \(temperature), conditionCode: \(conditionCode), windSpeed: \(windSpeed)")

        if temperature > 30 {
            self = .hot(windy: windSpeed > 3)
        } else if temperature < 30 && conditionCode >= 100 && conditionCode <= 531 {
            self = .rain(windy: windSpeed > 3)
        } else if temperature < 30 && conditionCode >= 600 && conditionCode <= 622 {
            self = .snow(windy: windSpeed > 3)
        } else if temperature < 30 && conditionCode >= 701 && conditionCode <= 781 {
            self = .fog(windy: windSpeed > 3)
        } else if temperature < 30 && conditionCode >= 800 && conditionCode <= 804 {
            self = .normal(windy: windSpeed > 3)
        } else {
            self = .normal(windy: false)
        }
    }
}




