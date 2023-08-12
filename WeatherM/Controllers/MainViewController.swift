//
//  MainViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 30.07.2023.
//

/* todo
 создать анимации что бы качался камень
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
    private let backgroundImageView: UIImageView = {
        let backgroundImage = UIImageView(image: UIImage(named: "image_background.png"))
        backgroundImage.contentMode = .scaleAspectFit
        return backgroundImage
    }()
    //MARK: - Import view's
    private let stoneView = StoneView()
    private let weatherView = WeatherView()
    private let weatherManager = WeatherManager()
    private let locationView = LocationView()
    private let infoButton = InfoButton()
    private let infoView = InfoView()
    
    private let locationManager = CLLocationManager()
    private let refreshControl = UIRefreshControl()
    private var windSpeed: Double = 0.0
    private var isConnected = true
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
    private var state: State = .normal(windy: false){
        didSet {
            print("State changed to: \(state)")
            updateWeatherState(state, windSpeed, isConnected)
        }
    }
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupTargets()
        setupLocationManager()
        setupSearchBarDelegate()
        setupTapGestureRecognizer()
        hideComponents()
        startNetworkMonitoring()
        animateStoneAppearance()
    }
    //MARK: Constraints
    private func setupConstraints() {
        // background image
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // scroll view
        scrollView.refreshControl = refreshControl
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
            make.top.equalTo(contentView.snp.top).offset(stoneView.frame.height)
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
    //MARK: - Network Monitoring
    private func startNetworkMonitoring() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.isConnected = true
                print("internet +")
            } else {
                self?.isConnected = false
                print("internet -")
            }
            self?.updateWeatherState(.noInternet, self?.windSpeed ?? 0.0, self?.isConnected ?? false)
        }
        monitor.start(queue: queue)
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
        refreshControl.addTarget(self, action: #selector(refreshWeather), for: .valueChanged)
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
    }
    //MARK: animation Info View
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
            }
        }
    }
    //MARK: stone animation
    private func animateStoneAppearance() {
        stoneView.frame.origin.y = stoneView.frame.height
        let finalPosition = stoneView.frame.origin.y + 100
        let numberOfRebounds = 5
        var currentRebound = 0
        func animateWithRebound() {
            UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                if currentRebound < numberOfRebounds {
                    self.stoneView.frame.origin.y = finalPosition
                } else {
                    self.stoneView.frame.origin.y = finalPosition - 0
                }
            }, completion: { _ in
                if currentRebound < numberOfRebounds {
                    currentRebound += 1
                    animateWithRebound()
                }
            })
        }
        animateWithRebound()
    }
    //MARK: updateData
    private func updateData(_ data: CompletionData, isConnected: Bool) {
        print("-t: \(data.temperature),\n-conditionCode: \(data.id),\n-windSpeed: \(data.windSpeed)")
        state = .init(temperature: data.temperature, conditionCode: data.id, windSpeed: data.windSpeed)
    }
    //MARK: updateWeatherState
    private func updateWeatherState(_ state: State, _ windSpeed: Double, _ isConnected: Bool) {
        switch state {
        case .rain(windy: let isWindy):
            if isWindy {
                print("rain = windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_wet.png"))
            } else {
                print("rain = NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_wet.png"))
            }
            animateStoneAppearance()
        case .hot(windy: let isWindy):
            if isWindy {
                print("hot windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_cracks.png"))
            } else {
                print("hot = NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_cracks.png"))
            }
            animateStoneAppearance()
        case .snow(windy: let isWindy):
            if isWindy {
                print("snow = windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_snow.png"))
            } else {
                print("snow = NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_snow.png"))
            }
            animateStoneAppearance()
        case .fog(windy: let isWindy):
            if isWindy {
                print("fog = windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_normal.png"))
                stoneView.alpha = 0.2
            } else {
                print("fog = NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_normal.png"))
                stoneView.alpha = 0.2
            }
            animateStoneAppearance()
        case .normal(windy: let isWindy):
            if isWindy {
                print("normal = windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_normal.png"))
            } else {
                print("normal = NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_normal.png"))
            }
            animateStoneAppearance()
        case .noInternet:
            DispatchQueue.main.async { [self] in
                if !isConnected {
                    stoneView.setStoneImage(UIImage(named: "noInternet.png"))
                    stoneView.frame.origin.y = CGFloat(100)
                    animateStoneAppearance()
                }
            }
        }
    }
    
    @objc private func refreshWeather() {
        // Здесь вызовите методы для обновления данных о погоде
        // Например, перезапустите локационный менеджер для получения новых данных о погоде

        // По завершении обновления данных о погоде:
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Обновите состояние погоды на основе новых данных
            self.updateWeatherState(self.state, self.windSpeed, self.isConnected)

            // Завершите "pull-to-refresh"
            self.refreshControl.endRefreshing()
        }
    }

} // end MainViewController
//MARK: - extension State
extension MainViewController {
    enum State: Equatable {
        case rain(windy: Bool)
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
            case .fog(let windy):
                return windy
            case .normal(let windy):
                return windy
            }
        }
        
        init(temperature: Int, conditionCode: Int, windSpeed: Double) {
            let temperatureCelsius = temperature - 273
            if temperatureCelsius > 30 {
                self = .hot(windy: windSpeed > 3)
            } else if temperatureCelsius < 30 && conditionCode >= 100 && conditionCode <= 531 {
                self = .rain(windy: windSpeed > 3)
            } else if temperatureCelsius < 30 && conditionCode >= 600 && conditionCode <= 622 {
                self = .snow(windy: windSpeed > 3)
            } else if temperatureCelsius < 30 && conditionCode >= 701 && conditionCode <= 781 {
                self = .fog(windy: windSpeed > 3)
            } else if temperatureCelsius < 30 && conditionCode >= 800 && conditionCode <= 804 {
                self = .normal(windy: windSpeed > 3)
            } else {
                self = .normal(windy: false)
            }
        }
    }
}
