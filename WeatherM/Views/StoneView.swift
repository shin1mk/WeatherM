//
//  StoneView.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 03.08.2023.
//

import UIKit
import SnapKit
import Network

final class StoneView: UIView {
    private var windSpeed: Double = 0.0
    private var isConnected = true
    private var isAnimating = false
    private var stoneImageView = UIImageView()
    private var activityIndicator = UIActivityIndicatorView(style: .large)
    // State
    var state: State = .normal(windy: false){
        didSet {
            print("State changed to: \(state)")
            updateWeatherState(state, windSpeed, isConnected)
        }
    }
    //MARK: Init
    init() {
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    //MARK: Constraints
    private func setupConstraints() {
        addSubview(stoneImageView)
        stoneImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(-200)
        }
    }
    //MARK: Methods
    func setStoneImage(_ image: UIImage?) {
        stoneImageView.image = image
    }
    // UpdateWeatherData
    func updateWeatherData(_ data: CompletionData, isConnected: Bool) {
        print("-t: \(data.temperature),\n-conditionCode: \(data.id),\n-windSpeed: \(data.windSpeed)")
        updateWeatherState(.normal(windy: data.windSpeed >= 3), data.windSpeed, isConnected)
    }
    // UpdateWeatherState
    func updateWeatherState(_ state: State, _ windSpeed: Double, _ isConnected: Bool) {
        switch state {
        case .rain(windy: let isWindy):
            if isWindy {
                print("rain = windy")
                self.setStoneImage(UIImage(named: "image_stone_wet.png"))
            } else {
                print("rain = NOT windy")
                self.setStoneImage(UIImage(named: "image_stone_wet.png"))
            }
            animateStoneAppearance(isWindy: isWindy)
        case .hot(windy: let isWindy):
            if isWindy {
                print("hot windy")
                self.setStoneImage(UIImage(named: "image_stone_cracks.png"))
            } else {
                print("hot = NOT windy")
                self.setStoneImage(UIImage(named: "image_stone_cracks.png"))
            }
            animateStoneAppearance(isWindy: isWindy)
        case .snow(windy: let isWindy):
            if isWindy {
                print("snow = windy")
                self.setStoneImage(UIImage(named: "image_stone_snow.png"))
            } else {
                print("snow = NOT windy")
                self.setStoneImage(UIImage(named: "image_stone_snow.png"))
            }
            animateStoneAppearance(isWindy: isWindy)
        case .fog(windy: let isWindy):
            if isWindy {
                print("fog = windy")
                self.setStoneImage(UIImage(named: "image_stone_normal.png"))
                self.alpha = 0.2
            } else {
                print("fog = NOT windy")
                self.setStoneImage(UIImage(named: "image_stone_normal.png"))
                self.alpha = 0.2
            }
            animateStoneAppearance(isWindy: isWindy)
        case .normal(windy: let isWindy):
            if isWindy {
                print("normal = windy")
                self.setStoneImage(UIImage(named: "image_stone_normal.png"))
            } else {
                print("normal = NOT windy")
                self.setStoneImage(UIImage(named: "image_stone_normal.png"))
            }
            animateStoneAppearance(isWindy: isWindy)
        case .noInternet:
            DispatchQueue.main.async { [self] in
                if !isConnected {
                    self.setStoneImage(UIImage(named: "noInternet.png"))
                    self.frame.origin.y = CGFloat(250)
                } else {
                    self.frame.origin.y = CGFloat(100)
                }
            }
        }
    }
    // Animation with fadeIn
    func animateStoneAppearance(isWindy: Bool) {
        guard !isAnimating else {
            return
        }
        isAnimating = true
        self.stoneImageView.layer.removeAllAnimations()

        let rockingDistance: CGFloat = -20.0
        let rockingDuration: TimeInterval = 1.1
        let fadeInDuration: TimeInterval = 1.2
        // alpha сначала
        self.stoneImageView.alpha = 0.0
        // Fade in
        UIView.animate(withDuration: fadeInDuration, animations: {
            self.stoneImageView.alpha = 1.0
        })
        // Rocking
        UIView.animate(withDuration: rockingDuration, delay: 0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            self.stoneImageView.center.x -= rockingDistance
        }, completion: nil)
    }
} // end stone view
//MARK: State
extension StoneView {
    enum State: Equatable {
        case rain(windy: Bool)
        case fog(windy: Bool)
        case hot(windy: Bool)
        case snow(windy: Bool)
        case normal(windy: Bool)
        case noInternet
        
        var isWindy: Bool {
            switch self {
            case .noInternet:
                print("No internet")
                return false
            case .snow(let windy):
                return windy
            case .hot(let windy):
                return windy
            case .rain(let windy):
                return windy
            case .fog(let windy):
                return windy
            case .normal(let windy):
                return windy
            }
        }
        
        init(temperature: Int, conditionCode: Int, windSpeed: Double) {
            if temperature > 30 {
                self = .hot(windy: windSpeed > 3)
            } else if temperature < 30 && conditionCode >= 100 && conditionCode <= 531 {
                self = .rain(windy: windSpeed > 3)
            } else if temperature < 30 && conditionCode >= 600 && conditionCode <= 622 {
                self = .snow(windy: windSpeed > 3)
            } else if temperature < 30 && conditionCode >= 701 && conditionCode <= 781 {
                self = .fog(windy: windSpeed > 3)
            } else if temperature < 30 && conditionCode >= 800 && conditionCode <= 804 {
                self = .normal(windy: windSpeed > 3)
            } else {
                self = .normal(windy: false)
            }
        }
    }
}
