//
//  InfoButton.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

import UIKit
import SnapKit

final class InfoButton: UIView {
    //MARK: Properties
    let infoButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "infoButton"), for: .normal)
        button.accessibilityIdentifier = "infoButton"
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
        addSubview(infoButton)
        infoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(85)
        }
    }
}
