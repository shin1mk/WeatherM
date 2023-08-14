////
////  SearchView.swift
////  WeatherM
////
////  Created by SHIN MIKHAIL on 13.08.2023.
////
//
//import UIKit
//import SnapKit
//
//class SearchView: UIViewController, UIGestureRecognizerDelegate {
//    private let searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.placeholder = "Search for a city"
//        searchBar.backgroundImage = UIImage()
//        return searchBar
//    }()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        activateSearchBar()
//        setupBackgroundView()
//        setupSwipeGesture()
//        setupConstraints()
//        setupTapGestureRecognizer()
//    }
//
//    private func setupBackgroundView() {
//        let backgroundView = UIView(frame: view.bounds)
//        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        view.addSubview(backgroundView)
//    }
//
//    private func setupSwipeGesture() {
//        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissSearchView))
//        swipeGesture.direction = .down
//        view.addGestureRecognizer(swipeGesture)
//    }
//
//    private func setupConstraints() {
//        view.addSubview(searchBar)
//        searchBar.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(20)
//            make.horizontalEdges.equalToSuperview().inset(10)
//            make.height.equalTo(40)
//        }
//    }
//
//    private func activateSearchBar() {
//        searchBar.becomeFirstResponder()
//    }
//
//    private func setupTapGestureRecognizer() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        tapGesture.delegate = self
//        view.addGestureRecognizer(tapGesture)
//    }
//
//    @objc private func dismissSearchView() {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @objc private func handleTap(sender: UITapGestureRecognizer) {
//        let tapLocation = sender.location(in: view)
//        if !searchBar.frame.contains(tapLocation) {
//        }
//    }
//}

import UIKit
import SnapKit

class SearchView: UIViewController, UIGestureRecognizerDelegate {
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a city"
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activateSearchBar() // Активация поисковой строки
        setupBackgroundView() // Настройка фонового представления
        setupSwipeGesture() // Настройка жеста свайпа
        setupConstraints() // Настройка констрейнтов
    }
    // MARK: - Настройка пользовательского интерфейса
    private func setupBackgroundView() {
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(backgroundView)
    }
    
    private func setupConstraints() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
    }
    // MARK: - Активация поисковой строки
    private func activateSearchBar() {
        searchBar.becomeFirstResponder()
    }
    
    private func setupSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissSearchView))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func dismissSearchView() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - жест касания
//    private func setupTapGestureRecognizer() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        tapGesture.delegate = self
//        view.addGestureRecognizer(tapGesture)
//    }
//    @objc private func handleTap(sender: UITapGestureRecognizer) {
//        let tapLocation = sender.location(in: view)
//        if !searchBar.frame.contains(tapLocation) {
//            // Выполните какие-либо действия, если необходимо
//        }
//    }
}
