//
//  OpenMeteoViews.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//


import UIKit

/// Ячейка, которая отображает погоду на данный день.
final class OpenMeteoDayCell: UITableViewCell, OpenMeteoImageURLProtocol {
    let titleLabel = UILabel()
    let weatherLabel = UILabel()
    let weatherIconImageView = UIImageView()
    let temperatureLabel = UILabel()
    let windSpeedLabel = UILabel()
    let humidityLabel = UILabel()
    
    var imageURL: URL?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        let textColor = UIColor.white
        let contentView = self.contentView
        contentView.backgroundColor = .clear
        
        self.titleLabel.textColor = textColor
        self.titleLabel.textAlignment = .center
        contentView.autoLayoutSubview(self.titleLabel)
        self.titleLabel.leftRightEqualsToLayoutMargin(of: contentView)
        self.titleLabel.topEquals(to: contentView, inset: 12)
        
        contentView.autoLayoutSubview(self.weatherIconImageView)
        self.weatherIconImageView.leftEqualsToLayoutMargin(of: contentView)
        self.weatherIconImageView.topEqualsToBorder(of: self.titleLabel.bottomAnchor, space: 8)
        self.weatherIconImageView.sizeEqualsTo(square: 24)
        
        self.weatherLabel.textColor = textColor
        contentView.autoLayoutSubview(self.weatherLabel)
        self.weatherLabel.leftEqualsToBorder(of: self.weatherIconImageView.rightAnchor, space: 8)
        self.weatherLabel.rightEqualsToLayoutMargin(of: contentView)
        self.weatherLabel.centerYEquals(to: self.weatherIconImageView)
        
        self.temperatureLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.temperatureLabel.textColor = textColor
        contentView.autoLayoutSubview(self.temperatureLabel)
        self.temperatureLabel.leftRightEqualsToLayoutMargin(of: contentView)
        self.temperatureLabel.topEqualsToBorder(of: self.weatherIconImageView.bottomAnchor, space: 8)
        
        self.windSpeedLabel.textColor = textColor
        contentView.autoLayoutSubview(self.windSpeedLabel)
        self.windSpeedLabel.leftRightEqualsToLayoutMargin(of: contentView)
        self.windSpeedLabel.topEqualsToBorder(of: self.temperatureLabel.bottomAnchor, space: 8)
        
        self.humidityLabel.textColor = textColor
        contentView.autoLayoutSubview(self.humidityLabel)
        self.humidityLabel.leftRightEqualsToLayoutMargin(of: contentView)
        self.humidityLabel.topEqualsToBorder(of: self.windSpeedLabel.bottomAnchor, space: 8)
        self.humidityLabel.bottomEquals(to: contentView, inset: 12)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
