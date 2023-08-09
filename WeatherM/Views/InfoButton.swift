//
//  InfoButton.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

import UIKit
import SnapKit

final class InfoButton: UIButton {
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
        self.setBackgroundImage(UIImage(named: "infoButton"), for: .normal)
        self.accessibilityIdentifier = "infoButton"
    }
}
