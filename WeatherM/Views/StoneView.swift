//
//  StoneView.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 03.08.2023.
//

import UIKit
import SnapKit

final class StoneView: UIView {
    //MARK: Properties
    private var stoneImageView: UIImageView = {
        let stoneImage = UIImage(named: "image_stone_normal")
        let imageView = UIImageView(image: stoneImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        addSubview(stoneImageView)
        stoneImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
}
