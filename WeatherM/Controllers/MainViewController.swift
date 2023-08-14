//
//  MainViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 30.07.2023.
//
/* todo
 создать экран с таблицой для поиска городов найти какой то апи
 https://openweathermap.org/weathermap?basemap=map&cities=true&layer=radar&lat=65.2107&lon=-10.5249&zoom=6
 Dnepr
 48,4647
 35,0462
 */
import UIKit
import SnapKit
import CoreLocation
import Network

final class MainViewController: UIViewController {
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
    private var isAnimatingStone = false
    //MARK: Scroll & Content
    private let scrollView: UIScrollView = {
        var view = UIScrollView()
        view.isScrollEnabled = true
        view.alwaysBounceVertical = true
        return view
    }()
    private let contentView = UIView()
 
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
//        setupTapGestureRecognizer()
        hideComponents()
        startNetworkMonitoring()
    }
    //MARK: Methods
    private func hideComponents() {
        infoView.isHidden = true
    }
    //MARK: RefreshWeather
    @objc private func refreshWeather() {
        startNetworkMonitoring()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.isConnected {
                guard let location = self.locationManager.location else { return }
                self.updateLocationData(for: location)
            } else {
                self.updateWeatherState(.noInternet, self.windSpeed, self.isConnected)
            }
            self.refreshControl.endRefreshing()
        }
    }
} // end MainViewController
//MARK: Constraints
extension MainViewController {
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
            make.top.equalTo(contentView.snp.top).offset(-100)
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
        // info View
        view.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(277)
            make.height.equalTo(372)
        }
    }
}
//MARK: State
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
//MARK: Delegate/Targets
extension MainViewController: UISearchBarDelegate {
    //MARK: Search Bar Delegate
    private func setupSearchBarDelegate() {
//        searchBar.delegate = self
        locationManager.delegate = self
    }
    //MARK: Targers
    private func setupTargets() {
        locationView.getLocationIconButton().addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        locationView.getSearchIconButton().addTarget(self, action: #selector(searchIconTapped), for: .touchUpInside)
        refreshControl.addTarget(self, action: #selector(refreshWeather), for: .valueChanged)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
}
//MARK: Buttons action
extension MainViewController {
    //MARK: Location button action
    @objc private func locationButtonTapped() {
        print("location icon tapped")
        locationManager.startUpdatingLocation()
    }
    //MARK: Search button action
    @objc private func searchIconTapped() {
        let searchViewController = SearchView()
        searchViewController.modalPresentationStyle = .popover
        present(searchViewController, animated: true, completion: nil)
    }
    //MARK: Info button action
    @objc private func infoButtonTapped() {
        print("info button tapped")
        infoViewAnimation()
    }
}
//MARK: Animations
extension MainViewController {
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
    //MARK: stone animation
    private func animateStoneAppearance(isWindy: Bool) {
        stoneView.frame.origin.y = stoneView.frame.height
        stoneView.center.x = contentView.center.x
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
                    currentRebound += 5
                    animateWithRebound()
                }
            })
        }
        animateWithRebound()
        
        if isWindy {
            animateRockingStone()
        }
    }
    //MARK: Rocking Animation
    private func animateRockingStone() {
        if isAnimatingStone {
            let rockingDistance: CGFloat = -20.0
            let rockingDuration: TimeInterval = 1.0
            
            UIView.animate(withDuration: rockingDuration, delay: 0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
                self.stoneView.center.x -= rockingDistance
            }, completion: nil)
        }
    }
}
//MARK: NetworkManager
extension MainViewController {
    //MARK: - Network Monitoring
    private func startNetworkMonitoring() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if self?.isConnected == true {
                    print("Internet connection is available.")
                    self?.updateWeatherState(.noInternet, self?.windSpeed ?? 0.0, self?.isConnected ?? false)
                    self?.isAnimatingStone = true
                } else {
                    print("No internet connection.")
                    self?.weatherView.temperatureLabel.text = "--°"
                    self?.weatherView.conditionLabel.text = "-"
                    self?.locationView.locationLabel.text = "no internet"
                    self?.updateWeatherState(.noInternet, self?.windSpeed ?? 0.0, self?.isConnected ?? false)
                    self?.isAnimatingStone = false
                }
            }
        }
        monitor.start(queue: queue)
    }

}
//MARK: Location
extension MainViewController: CLLocationManagerDelegate {
    //MARK: Request geo/start geo
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    //MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateLocationData(for: location)
    }
    // updateLocation
    private func updateLocationData(for location: CLLocation) {
        weatherManager.updateWeather(for: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] complitionData in
            guard let self = self else { return }
            
            let weatherConditions = complitionData.weather
            let temperatureKelvin = complitionData.temperature
            let temperatureCelsiusValue = Double(temperatureKelvin) - 273.15
            let temperatureCelsius = Int(ceil(temperatureCelsiusValue))
            let city = complitionData.city
            let country = complitionData.country
            let windSpeedData = complitionData.windSpeed
            let conditionCode = complitionData.cod
            
            DispatchQueue.main.async {
                self.weatherView.temperatureLabel.text = "\(temperatureCelsius)°"
                self.weatherView.conditionLabel.text = weatherConditions
                self.locationView.locationLabel.text = city + ", " + country
                self.updateWeatherData(complitionData, isConnected: self.isConnected)
                self.windSpeed = windSpeedData
                print("condition code - \(conditionCode)")
            }
        }
    }
}
//MARK: UpdateWeather
extension MainViewController {
    //MARK: updateWeatherData
    private func updateWeatherData(_ data: CompletionData, isConnected: Bool) {
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
            animateStoneAppearance(isWindy: isWindy)
        case .hot(windy: let isWindy):
            if isWindy {
                print("hot windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_cracks.png"))
            } else {
                print("hot = NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_cracks.png"))
            }
            animateStoneAppearance(isWindy: isWindy)
        case .snow(windy: let isWindy):
            if isWindy {
                print("snow = windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_snow.png"))
            } else {
                print("snow = NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_snow.png"))
            }
            animateStoneAppearance(isWindy: isWindy)
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
            animateStoneAppearance(isWindy: isWindy)
        case .normal(windy: let isWindy):
            if isWindy {
                print("normal = windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_normal.png"))
            } else {
                print("normal = NOT windy")
                stoneView.setStoneImage(UIImage(named: "image_stone_normal.png"))
            }
            animateStoneAppearance(isWindy: isWindy)
        case .noInternet:
            DispatchQueue.main.async { [self] in
                if !isConnected {
                    stoneView.setStoneImage(UIImage(named: "noInternet.png"))
                    stoneView.frame.origin.y = CGFloat(250)
                }
            }
        }
    }
}
