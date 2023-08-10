//
//  InfoView.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 04.08.2023.
//

import UIKit
import SnapKit

/*
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
 */

final class InfoView: UIView {
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
        button.layer.cornerRadius = 15 // Выберите желаемый радиус
        button.titleLabel?.font = UIFont.ubuntuRegular(ofSize: 15) // Установка шрифта размером 15

        return button
    }()
    //MARK: Init
    init() {
        super.init(frame: .zero)
        setupBackground()
        setupConstraints()
        setupTarget()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    //MARK: Methods
    private func setupBackground() {
        backgroundColor = UIColor(red: 1.0, green: 153/255, blue: 96/255, alpha: 1.0)
        layer.cornerRadius = 15
    }
    
    private func setupConstraints() {
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
    
    private func setupTarget() {
        hideButton.addTarget(self, action: #selector(hideButtonTapped), for: .touchUpInside)
    }
    
    @objc private func hideButtonTapped() {
        isHidden = true
    }
}
