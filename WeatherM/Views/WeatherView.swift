//
//  WeatherView.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

import UIKit
import SnapKit

final class WeatherView: UIView {
    //MARK: Properties
    private let temperatureLabel: UILabel = {
        let temperatureLabel = UILabel()
        temperatureLabel.text = "--°"
        temperatureLabel.font = UIFont.ubuntuRegular(ofSize: 83)
        temperatureLabel.textColor = .black
        temperatureLabel.textAlignment = .left
        return temperatureLabel
    }()
    private let conditionLabel: UILabel = {
        let conditionLabel = UILabel()
        conditionLabel.text = "condition"
        conditionLabel.font = UIFont.ubuntuLight(ofSize: 36)
        conditionLabel.textColor = .black
        conditionLabel.textAlignment = .left
        return conditionLabel
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
        addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        addSubview(conditionLabel)
        conditionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(temperatureLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
        }
    }
    
    func setTemperature(temperature: String) {
        temperatureLabel.text = temperature
    }

    func setCondition(condition: String) {
        conditionLabel.text = condition
    }
}
