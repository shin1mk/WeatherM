//
//  MainViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 30.07.2023.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
    //MARK: Properties
    private let backgroundImage: UIImageView = {
        let backgroundView = UIImageView(image: UIImage(named: "image_background"))
        backgroundView.contentMode = .scaleAspectFill
        return backgroundView
    }()
    // location
    private let locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.text = "Location"
        locationLabel.textAlignment = .center
        return locationLabel
    }()
    private let locationIcon = UIImageView(image: UIImage(named: "icon_location"))
    private let searchIcon = UIImageView(image: UIImage(named: "icon_search"))
    // button
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
    }
    //MARK: Constraints
    private func setupConstraints() {
        // background image
        self.view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // button
        self.view.addSubview(infoButton)
        infoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(85)
            make.horizontalEdges.equalToSuperview().inset(65)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(40)
        }
        // location
        view.addSubview(locationLabel)
        locationLabel.snp.makeConstraints{ make in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(view.snp.bottom).inset(100)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(40)
        }
        view.addSubview(locationIcon)
        locationIcon.snp.makeConstraints{ make in
            make.bottom.equalTo(view.snp.bottom).inset(110)
            make.leading.equalTo(locationLabel).inset(50)
            make.height.equalTo(16)
        }
        view.addSubview(searchIcon)
        searchIcon.snp.makeConstraints{ make in
            make.bottom.equalTo(view.snp.bottom).inset(110)
            make.trailing.equalTo(locationLabel).offset(-50)
            make.height.equalTo(16)
        }
    }
    
    
    
    
    
    
    
} // end MainViewController
//MARK: Extension
extension MainViewController {
    enum Constants {
        enum Images {
            static let backgroundView = UIImageView(image: UIImage(named: "image_background.png"))
            static let locationIcon = UIImageView(image: UIImage(named: "icon_location.png"))
            static let searchIcon = UIImageView(image: UIImage(named: "icon_search.png"))
        }
    }
}
