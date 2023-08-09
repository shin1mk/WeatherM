//
//  MainViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 30.07.2023.
//

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
    private var currentStoneState: State = .normal {
        didSet {
            updateBackgroundImage()
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
    //MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Получаем координаты широты и долготы
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        // Выводим в locationLabel
        let locationString = "Lat:\(latitude), Lon:\(longitude)"
        self.locationView.setLocationLabelText(locationString)
        // Вызываем функцию fetchWeather с полученными координатами
        WeatherManager().fetchWeather(for: latitude, longitude: longitude) { temperature, weatherDescription in
            DispatchQueue.main.async {
                self.weatherView.setTemperature(temperature: "\(temperature)°")
                self.weatherView.setCondition(condition: weatherDescription)
            }
        }
    } // location
} // end MainViewController
// MARK: - State Extension
extension MainViewController {
    enum State: Int {
        case normal
        case cracks
        case snow
        case wet
    }

    private func updateBackgroundImage() {
        switch currentStoneState {
        case .normal:
            self.stoneView.setStoneImage(UIImage(named: "image_stone_normal.png"))
        case .cracks:
            self.stoneView.setStoneImage(UIImage(named: "image_stone_cracks.png"))
        case .snow:
            self.stoneView.setStoneImage(UIImage(named: "image_stone_snow.png"))
        case .wet:
            self.stoneView.setStoneImage(UIImage(named: "image_stone_wet.png"))
        }
    }

}
