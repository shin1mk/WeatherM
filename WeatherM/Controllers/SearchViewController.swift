//
//  SearchViewController.swift
//  WeatherM
//
//  Created by SHIN MIKHAIL on 13.08.2023.
//

import UIKit
import SnapKit

final class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {
    //MARK: Properties
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a city"
        searchBar.backgroundImage = UIImage()
        searchBar.becomeFirstResponder()
        return searchBar
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
        return tableView
    }()
    var cities = ["City1", "City2", "City3", "City4", "City5", "Denver"] // список городов
    var filteredCities: [String] = []
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundView()
        setupConstraints()
        setupDelegates()
        setupGestures()
    }
    //MARK: Constraints
    private func setupConstraints() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    //MARK: Methods
    private func setupBackgroundView() {
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(backgroundView)
    }
    // Delegates
    private func setupDelegates() {
        searchBar.delegate = self
        tableView.dataSource = self
    }
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search text: \(searchText)")
        if searchText.isEmpty {
            filteredCities = []
        } else {
            filteredCities = cities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        print("Filtered cities: \(filteredCities)")
        tableView.reloadData() // Обновляем
        tableView.isHidden = filteredCities.isEmpty
    }
} // end SearchViewController
//MARK: Gestures
extension SearchViewController: UIGestureRecognizerDelegate {
    // Gestures
    private func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissSearchView))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        swipeGesture.direction = .down
        tapGesture.delegate = self
        view.addGestureRecognizer(swipeGesture)
        view.addGestureRecognizer(tapGesture)
    }
    // Dismiss
    @objc private func dismissSearchView() {
        dismiss(animated: true, completion: nil)
    }
    // Tap
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)
        if !searchBar.frame.contains(tapLocation) {
            searchBar.endEditing(true)
        }
    }
}
//MARK: Table View
extension SearchViewController: UITableViewDelegate {
    // numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = filteredCities[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        return cell
    }
    // MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected city: \(filteredCities[indexPath.row])")
        searchBar.text = filteredCities[indexPath.row]
        tableView.isHidden = true
        searchBar.resignFirstResponder()
    }
}
