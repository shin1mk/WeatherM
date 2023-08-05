//
//  LocationView.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

import UIKit
import SnapKit

final class LocationView: UIView {
    //MARK: Properties
    private let locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.text = "Location"
        locationLabel.font = UIFont.ubuntuMedium(ofSize: 17)
        locationLabel.textColor = .black
        locationLabel.textAlignment = .center
        return locationLabel
    }()
    private let locationIconButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon_location"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    private let searchIconButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon_search"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    //MARK: Init
    init() {
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    //MARK: Methods
    private func setupConstraints() {
        // location
        addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        // locationIconButton
        addSubview(locationIconButton)
        locationIconButton.snp.makeConstraints { make in
            make.bottom.equalTo(snp.bottom).inset(10)
            make.leading.equalToSuperview().inset(70)
            make.height.equalTo(16)
        }
        // searchIconButton
        addSubview(searchIconButton)
        searchIconButton.snp.makeConstraints{ make in
            make.bottom.equalTo(snp.bottom).inset(10)
            make.trailing.equalToSuperview().inset(70)
            make.height.equalTo(16)
        }
    }
    // locationIconButton
    func getLocationIconButton() -> UIButton {
        return locationIconButton
    }
    // searchIconButton
    func getSearchIconButton() -> UIButton {
        return searchIconButton
    }
    // locationLabel
    func setLocationLabelText(_ text: String) {
        locationLabel.text = text
    }
}
