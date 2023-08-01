//
//  MainViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 30.07.2023.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
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
        locationLabel.textAlignment = .center
        return locationLabel
    }()
    //MARK: locationIcon
    private let locationIconButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon_location"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(locationIconTapped), for: .touchUpInside) // обработчик событий
        return button
    }()
    //MARK: searchIcon
    private let searchIconButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon_search"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(searchIconTapped), for: .touchUpInside) // обработчик событий
        return button
    }()
    //MARK: infoButton
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "infoButton"), for: .normal)
        button.accessibilityIdentifier = "infoButton"
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside) // обработчик событий
        return button
    }()
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    //MARK: Constraints
    private func setupConstraints() {
        // background image
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // temerature label
        view.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints{ make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(view.snp.top).inset(500)
            make.horizontalEdges.equalToSuperview().inset(25)
        }
        // condition label
        view.addSubview(conditionLabel)
        conditionLabel.snp.makeConstraints{ make in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(temperatureLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview().inset(25)
        }
        // location
        view.addSubview(locationLabel)
        locationLabel.snp.makeConstraints{ make in
            make.centerX.equalTo(self.view)
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
    //MARK: Button Action
    @objc private func infoButtonTapped() {
        print("info_button")
    }
    //MARK: Icon Tap Action
    @objc private func locationIconTapped() {
        print("locationIcon tapped")
    }
    //MARK: Search Tap Action
    @objc private func searchIconTapped() {
        print("searchIcon tapped")
    }
} // end MainViewController
//MARK: Extension
extension MainViewController {
    enum Constants {
        enum Images {
            static let backgroundImageView = UIImageView(image: UIImage(named: "image_background.png"))
            static let locationIconImageView = UIImageView(image: UIImage(named: "icon_location.png"))
            static let searchIconImageView = UIImageView(image: UIImage(named: "icon_search.png"))
        }
    }
}
