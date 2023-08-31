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
        informationButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    //MARK: Methods
    private func informationButton() {
        self.setBackgroundImage(UIImage(named: "infoButton"), for: .normal)
        self.accessibilityIdentifier = "infoButton"
    }
}
