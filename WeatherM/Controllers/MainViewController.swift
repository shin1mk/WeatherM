//
//  MainViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 30.07.2023.
//

/*
 Dnepr
 48,4647
 35,0462
 */
import UIKit
import SnapKit
import CoreLocation
import Network

final class MainViewController: UIViewController, LocationDelegate {
    func didUpdateLocationLabel(_ text: String) {
        print("MainViewController received updated location text: \(text)")
        self.locationView.setLocationLabelText(text)
    }
    
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
    private let searchViewController = SearchViewController()
    
    private let locationManager = CLLocationManager()
    private let refreshControl = UIRefreshControl()

    private var isConnected = true
    private var windSpeed: Double = 0.0
    // Scroll & Content
    private let scrollView: UIScrollView = {
        var view = UIScrollView()
        view.isScrollEnabled = true
        view.alwaysBounceVertical = true
        return view
    }()
    private let contentView = UIView()
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupTargets()
        setupLocationManager()
        setupSearchBarDelegate()
        setupInfoViewDelegate()
        hideComponents()
        startNetworkMonitoring()
    }
    //MARK: Methods
    private func hideComponents() {
        infoView.isHidden = true
    }
    // Constraints
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
            make.top.equalTo(contentView.snp.top).offset(100)
        }
        // weather view
        view.addSubview(weatherView)
        weatherView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
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
    // Network Monitoring
    private func startNetworkMonitoring() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if self?.isConnected == true {
                    print("Internet connection is available.")
                    self?.stoneView.updateWeatherState(.noInternet, self?.windSpeed ?? 0.0, self?.isConnected ?? false)
                } else {
                    print("No internet connection.")
                    self?.weatherView.temperatureLabel.text = "--°"
                    self?.weatherView.conditionLabel.text = "-"
                    self?.didUpdateLocationLabel("no internet")
                    self?.stoneView.updateWeatherState(.noInternet, self?.windSpeed ?? 0.0, self?.isConnected ?? false)
                }
            }
        }
        monitor.start(queue: queue)
    }
    // Request geo/start geo
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    // Animation Info View
    private func infoViewAnimation() {
        if infoView.isHidden {
            weatherView.isHidden = true
            locationView.isHidden = true
            stoneView.isHidden = true
            infoButton.isHidden = true
            // Show infoView
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
    // RefreshWeather
    @objc private func refreshWeather() {
        startNetworkMonitoring()
        // Update the UI
        weatherView.temperatureLabel.text = "--°"
        weatherView.conditionLabel.text = "-"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.isConnected {
                guard let location = self.locationManager.location else { return }
                self.updateLocationData(for: location)
                self.stoneView.updateWeatherState(.noInternet, self.windSpeed, self.isConnected)
            } else {
                self.stoneView.updateWeatherState(.noInternet, self.windSpeed, self.isConnected)
            }
            self.refreshControl.endRefreshing()
        }
    }
} // end
//MARK: Location
extension MainViewController: CLLocationManagerDelegate {
    // Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateLocationData(for: location)
    }
    // Update Location
    private func updateLocationData(for location: CLLocation) {
        weatherManager.updateWeather(for: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] complitionData in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.weatherView.temperatureLabel.text = "\(complitionData.temperature)°"
                self.weatherView.conditionLabel.text = complitionData.weather
                self.didUpdateLocationLabel(complitionData.city + ", " + complitionData.country)
                self.stoneView.updateWeatherData(complitionData, isConnected: self.isConnected)
                self.windSpeed = complitionData.windSpeed
            }
        }
    }
}
//MARK: Delegate/Targets
extension MainViewController: UISearchBarDelegate {
    // Search Bar Delegate
    private func setupSearchBarDelegate() {
        locationManager.delegate = self
        locationView.delegate = self
        searchViewController.locationDelegate = self
    }
    // Targers
    private func setupTargets() {
        locationView.getLocationIconButton().addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        locationView.getSearchIconButton().addTarget(self, action: #selector(searchIconTapped), for: .touchUpInside)
        refreshControl.addTarget(self, action: #selector(refreshWeather), for: .valueChanged)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
}
//MARK: InfoViewDelegate
extension MainViewController: InfoViewDelegate {
    private func setupInfoViewDelegate() {
        infoView.delegate = self
    }

    func hideInfoView() {
        weatherView.isHidden = false
        locationView.isHidden = false
        stoneView.isHidden = false
        infoButton.isHidden = false
    }
}
//MARK: Buttons action
extension MainViewController {
    // Location button action
    @objc private func locationButtonTapped() {
        print("location icon tapped")
        locationManager.startUpdatingLocation()
    }
    // Search button action
    @objc private func searchIconTapped() {
        print("search button tapped")
        let searchViewController = SearchViewController()
        searchViewController.modalPresentationStyle = .popover
        present(searchViewController, animated: true, completion: nil)
    }
    // Info button action
    @objc private func infoButtonTapped() {
        print("info button tapped")
        infoViewAnimation()
    }
}
