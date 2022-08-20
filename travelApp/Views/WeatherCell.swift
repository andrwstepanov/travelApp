//
//  WeatherCell.swift
//  TablePlayground
//
//  Created by Андрей Степанов on 20.05.2022.
//

import UIKit

class WeatherCell: UITableViewCell {
    @IBOutlet weak var weatherBackground: UIView!
    @IBOutlet weak var weatherTemperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var weatherConditionIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        weatherBackground.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
