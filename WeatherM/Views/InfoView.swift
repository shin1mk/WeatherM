//
//  InfoView.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

import UIKit
import SnapKit

protocol InfoViewDelegate: AnyObject {
    func hideInfoView()
}

final class InfoView: UIView {
    weak var delegate: InfoViewDelegate?

    private let backgroundInfoView: UIImageView = {
        let backgroundView = UIImageView()
        backgroundView.backgroundColor = UIColor(red: 251/255, green: 95/255, blue: 41/255, alpha: 1)
        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.5
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backgroundView.layer.shadowRadius = 4
        backgroundView.layer.masksToBounds = false
        return backgroundView
    }()
    private let mainInfoView: UIImageView = {
        let mainInfoView = UIImageView()
        mainInfoView.backgroundColor = UIColor(red: 1.0, green: 153/255, blue: 96/255, alpha: 1.0)
        mainInfoView.layer.cornerRadius = 15
        return mainInfoView
    }()
    private let infoTitle: UILabel = {
        let infoLabel = UILabel()
        infoLabel.text = "INFO"
        infoLabel.font = UIFont.ubuntuBold(ofSize: 17)
        infoLabel.textColor = .black
        infoLabel.textAlignment = .center
        return infoLabel
    }()
    private let infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.text = "Brick is wet - raining\n\nBrick is dry - sunny\n\nBrick is hard to see - fog\n\nBrick with cracks - very hot\n\nBrick with snow - snow\n\nBrick is swinging - windy\n\nBrick is gone - No Internet"
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont.ubuntuRegular(ofSize: 15)
        infoLabel.textColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
        infoLabel.textAlignment = .left
        return infoLabel
    }()
    private let hideButton: UIButton = {
        let button = UIButton()
        button.setTitle("Hide", for: .normal)
        button.setTitleColor(UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1), for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1).cgColor
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.ubuntuRegular(ofSize: 15)
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
            make.edges.equalToSuperview()
        }
        addSubview(mainInfoView)
        mainInfoView.snp.makeConstraints { make in
            make.top.bottom.equalTo(backgroundInfoView)
            make.trailing.equalTo(backgroundInfoView.snp.trailing).offset(-7)
            make.leading.equalTo(backgroundInfoView.snp.leading)
        }
        addSubview(infoTitle)
        infoTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
        }
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(infoTitle.snp.bottom).offset(24)
        }
        addSubview(hideButton)
        hideButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(infoLabel.snp.bottom).offset(30)
            make.height.equalTo(30)
            make.width.equalTo(115)
        }
    }
    // Target
    private func setupTarget() {
        hideButton.addTarget(self, action: #selector(hideButtonTapped), for: .touchUpInside)
    }
    // Animation
    private func hideButtonAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { _ in
            self.isHidden = true
            self.transform = .identity
        }
    }
    // Button tapped
    @objc private func hideButtonTapped() {
        hideButton.setTitleColor(UIColor.white, for: .highlighted)
        hideButtonAnimation()
        delegate?.hideInfoView()
    }
}

