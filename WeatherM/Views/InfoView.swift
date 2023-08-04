//
//  InfoView.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

import UIKit
import SnapKit

final class InfoView: UIView {
    //MARK: Properties
    private let backgroundInfoView: UIImageView = {
        let backgroundImage = UIImageView(image: UIImage(named: "info"))
        backgroundImage.contentMode = .scaleAspectFit
        return backgroundImage
    }()
    private let hideButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    //MARK: Init
    init() {
        super.init(frame: .zero)
        setupConstraints()
        setupTarget()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    //MARK: Methods
    private func setupConstraints() {
        addSubview(backgroundInfoView)
        backgroundInfoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        addSubview(hideButton)
        hideButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(backgroundInfoView.snp.bottom).offset(-30)
            make.width.equalTo(115)
        }
    }
    
    private func setupTarget() {
        hideButton.addTarget(self, action: #selector(hideButtonTapped), for: .touchUpInside)
    }
    
    @objc private func hideButtonTapped() {
        isHidden = true
    }
}

