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
    // State
    var state: State = .normal(windy: false){
        didSet {
            print("State changed to: \(state)")
            updateWeatherState(state, windSpeed, isConnected)
        }
    }
    private var stoneImageView = UIImageView()
    private var activityIndicator = UIActivityIndicatorView(style: .large)
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
     func updateWeatherData(_ data: CompletionData, isConnected: Bool) {
        print("-t: \(data.temperature),\n-conditionCode: \(data.id),\n-windSpeed: \(data.windSpeed)")
         updateWeatherState(.normal(windy: data.windSpeed >= 3), data.windSpeed, isConnected)
    }
    // updateWeatherState
    func updateWeatherState(_ state: State, _ windSpeed: Double, _ isConnected: Bool) {
        print("стейт апдейт везер: \(state)")
        print("скорость ветра: \(windSpeed)")
        
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
                }
            }
        }
    }
    
    func startLoadingAnimation() {
        activityIndicator.startAnimating()
    }
    
    func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    func animateStoneAppearance(isWindy: Bool) {
        // Если анимация уже запущена, не запускайте её снова
        guard !isAnimating else {
            return
        }

        isAnimating = true

        // Определяем начальную позицию вершины камня (выше экрана)
        let initialPosition = stoneImageView.frame.origin.y - 100

        // Определяем финальную позицию вершины камня (0)
        let finalPosition: CGFloat = 0
 
        let numberOfRebounds = 5

        func animateWithRebound(currentRebound: Int) {
            UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                if currentRebound < numberOfRebounds {
                    self.stoneImageView.frame.origin.y = finalPosition + 00
                } else {
//                    self.stoneImageView.frame.origin.y = finalPosition + 200
                }
            }, completion: { _ in
                if currentRebound < numberOfRebounds {
                    animateWithRebound(currentRebound: currentRebound + 1)
                } else {
                    // По завершении анимации, сбрасываем флаг анимации
                    self.isAnimating = false

                    if isWindy {
                        self.animateRockingStone()
                    }
                }
            })
        }

        // Запускаем анимацию с текущим количеством отскоков 0
        animateWithRebound(currentRebound: 0)
    }
    
  


    private func animateRockingStone() {
        let rockingDistance: CGFloat = -20.0
        let rockingDuration: TimeInterval = 1.0
        
        UIView.animate(withDuration: rockingDuration, delay: 0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            self.stoneImageView.center.x -= rockingDistance
        }, completion: nil)
    }
} // end
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
