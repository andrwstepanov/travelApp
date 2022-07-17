//
//  GalleryCollectionViewCell.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 29.04.2022.
//

import UIKit

class TripCollectionViewCell: UICollectionViewCell {
        
    static let reuseID = "GalleryCollectionViewCell"
    
    let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.blue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let countryLabel: UILabel = {
        let country = UILabel()
        country.translatesAutoresizingMaskIntoConstraints = false
        country.textColor = UIColor.white
        country.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        return country
    }()
    
    let dateLabel: UILabel = {
        let date = UILabel()
        date.translatesAutoresizingMaskIntoConstraints = false
        date.textColor = UIColor.white
        date.font = UIFont.systemFont(ofSize: 11)

        return date
    }()
    
    let temperatureLabel: UILabel = {
        let temperature = UILabel()
        temperature.translatesAutoresizingMaskIntoConstraints = false
        temperature.textColor = UIColor.white
        temperature.font = UIFont.systemFont(ofSize: 14)

        return temperature
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainImageView)
        mainImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        mainImageView.layer.cornerRadius = 19.0
        mainImageView.clipsToBounds = true

   
        addSubview(temperatureLabel)
        temperatureLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Config.UIConstants.leftDistanceToView).isActive = true
        temperatureLabel.topAnchor.constraint(equalTo: mainImageView.topAnchor, constant: 18).isActive = true

        
        addSubview(dateLabel)
        dateLabel.bottomAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: -10).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Config.UIConstants.leftDistanceToView).isActive = true
        
        addSubview(countryLabel)
        countryLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -6).isActive = true
        countryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Config.UIConstants.leftDistanceToView).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

