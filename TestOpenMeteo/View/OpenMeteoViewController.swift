//
//  OpenMeteoViewController.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import UIKit


/// Главный экран, который отображает погоду.
final class OpenMeteoViewController: UITableViewController {
    private let openMeteoProviderProtocol: any OpenMeteoProviderProtocol
    private let openMeteoImageDownloader = OpenMeteoImageDownloader()
    private let cities: [OpenMeteoCityData]
    
    private var selectedCity: OpenMeteoCityData
    private var dayModels: [OpenMeteoDayModel] = []
    
    init(openMeteoProviderProtocol: any OpenMeteoProviderProtocol,
         cities: [OpenMeteoCityData], selectedCity: OpenMeteoCityData) {
        self.openMeteoProviderProtocol = openMeteoProviderProtocol
        self.cities = cities
        self.selectedCity = selectedCity
        
        super.init(style: .grouped)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectedCity = self.selectedCity
        self.title = selectedCity.cityName
        
        let tableView = self.tableView!
        tableView.allowsSelection = false
        tableView.separatorColor = .white
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 16
        tableView.backgroundColor = UIColor(red: CGFloat(144) / 255, green: CGFloat(213) / 255, blue: 1, alpha: 1)
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(cellClass: OpenMeteoDayCell.self)
        
        let refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { action in
            guard let refreshControl = action.sender as? UIRefreshControl else { return }
            guard let `self` = refreshControl.parentViewController(ofType: Self.self) else { return }
            
            self.loadWeather(selectedCity: self.selectedCity)
        }))
        refreshControl.tintColor = .white
        self.refreshControl = refreshControl
        
        if self.cities.isEmpty == false {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change", menu: self.createMenu(selectedCity: selectedCity))
        }
        
        self.loadWeather(selectedCity: selectedCity)
    }
    
    private func createMenu(selectedCity: OpenMeteoCityData) -> UIMenu {
        let handler: (UIAction) -> Void = { action in
            guard let index = Int(action.identifier.rawValue) else { return }
            guard let barButtonItem = action.sender as? UIBarButtonItem else { return }
            guard let `self` = barButtonItem.parentViewController(ofType: Self.self) else { return }
            
            let newSelectedCity = self.cities[index]
            if self.selectedCity != newSelectedCity {
                self.selectedCity = newSelectedCity
                self.title = newSelectedCity.cityName
                self.dayModels.removeAll()
                self.tableView.reloadData()
                
                barButtonItem.menu = self.createMenu(selectedCity: newSelectedCity)
                
                self.loadWeather(selectedCity: newSelectedCity)
            }
        }
        let actions = self.cities.enumerated().map { (index, cityData) in
            UIAction(title: cityData.cityName, identifier: .init(String(index)), state: selectedCity.cityName == cityData.cityName ? .on : .off, handler: handler)
        }
        return UIMenu(title: "Cities", children: actions)
    }
    
    private func loadWeather(selectedCity: OpenMeteoCityData) {
        let openMeteoProviderProtocol = self.openMeteoProviderProtocol
        Task { [weak self] in
            let openMeteoWeatherResult = try await openMeteoProviderProtocol.getWeather(latitude: selectedCity.latitude, longitude: selectedCity.longitude)
            guard let self else { return }
            
            switch openMeteoWeatherResult {
            case .success(let openMeteoInfo):
                self.display(openMeteoInfo: openMeteoInfo)
            case .failure(let error):
                print(error)
                let alertController =
                UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alertController.addAction(UIAlertAction(title: "Retry", style: .default,
                                                        handler: { [weak self] _ in
                    guard let self else { return }
                    
                    self.loadWeather(selectedCity: self.selectedCity)
                }))
                self.present(alertController, animated: true)
            }
        }
    }
    
    func display(openMeteoInfo: OpenMeteoInfo) {
        self.dayModels = openMeteoInfo.dayModels
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let count = self.dayModels.count
        if count == 0 {
            if (tableView.backgroundView is UIActivityIndicatorView) == false {
                let activityIndicatorView = UIActivityIndicatorView(style: .medium)
                activityIndicatorView.color = .white
                activityIndicatorView.startAnimating()
                tableView.backgroundView = activityIndicatorView
            }
        } else {
            tableView.backgroundView = nil
        }
        return count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dayModel = self.dayModels[indexPath.section]
        let openMeteoDayCell = tableView.dequeueReusableCell(withCellClass: OpenMeteoDayCell.self, for: indexPath)
        openMeteoDayCell.titleLabel.text = dayModel.title
        openMeteoDayCell.weatherLabel.text = dayModel.weather
        openMeteoDayCell.temperatureLabel.text = dayModel.temperature
        openMeteoDayCell.windSpeedLabel.text = dayModel.windSpeed
        openMeteoDayCell.humidityLabel.text = dayModel.humidity
        openMeteoDayCell.weatherIconImageView.image = nil
        self.openMeteoImageDownloader.loadImageOn(cell: openMeteoDayCell, imageURL: dayModel.weatherIcon,
                                                  completion: { openMeteoDayCell, image in
            openMeteoDayCell.weatherIconImageView.image = image
        })
        
        return openMeteoDayCell
    }
}

/// Данные города, погоду которого нужно отобразить.
struct OpenMeteoCityData: Equatable {
    let cityName: String
    let latitude: Double
    let longitude: Double
}
