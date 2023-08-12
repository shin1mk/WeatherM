//
//  StoneView.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 03.08.2023.
//

import UIKit
import SnapKit

final class StoneView: UIView {
    private var stoneImageView = UIImageView()
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
            make.top.equalToSuperview().offset(-200)
        }
    }
    
    func setStoneImage(_ image: UIImage?) {
        stoneImageView.image = image
    }
}
//MARK: Extension
extension StoneView {
    func startLoadingAnimation() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
        activityIndicator.color = UIColor.red
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    func stopLoadingAnimation() {
        for subview in subviews {
            if let activityIndicator = subview as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
}
