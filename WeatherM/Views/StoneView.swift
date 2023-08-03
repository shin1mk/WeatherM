//
//  StoneView.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 03.08.2023.
//

import UIKit
import SnapKit

class StoneView: UIView {
    var stoneImageView: UIImageView = {
        let stoneImage = UIImage(named: "image_stone_normal")
        let imageView = UIImageView(image: stoneImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    private func setupConstraints() {
        addSubview(stoneImageView)
        stoneImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
//            make.trailing.leading.equalToSuperview()
        }
    }
    
//    func setStoneImage(_ image: UIImage?) {
//        stoneImageView.image = image
//    }
} // end stoneView
