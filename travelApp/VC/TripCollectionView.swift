//
//  GalleryCollectionView.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 29.04.2022.
//

import UIKit
import Nuke
import CoreMedia
import RealmSwift
import NukeUI
import NukeExtensions

class TripCollectionView: UICollectionView {
    weak var collectionDelegate: TripCollectionViewDelegate?
    var notificationToken: NotificationToken?
    var cells: Results<TripModel>!
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.reuseID.self)
        translatesAutoresizingMaskIntoConstraints = false
        layout.minimumLineSpacing = Config.UIConstants.carouselLineSpacing
        contentInset = UIEdgeInsets(top: 0, left: Config.UIConstants.leftDistanceToView, bottom: 0, right: Config.UIConstants.rightDistanceToView)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TripCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func set(cells: Results<TripModel>) {
        self.cells = cells
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Config.UIConstants.carouselTileWidth, height: frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.reuseID, for: indexPath) as! TripCollectionViewCell
        cell.countryLabel.text = "\(cells[indexPath.row].location?.cityName ?? "")"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        cell.dateLabel.text = "\(dateFormatter.string(from: cells[indexPath.row].startDate)) - \(dateFormatter.string(from: cells[indexPath.row].finishDate))"
        if let temperature = cells[indexPath.row].weather {
            let userDefaults = UserDefaults.standard
            let isCelsius: Bool = userDefaults.bool(forKey: Config.UserDefaultsNames.userUnitsIsCelsius)
            let userUnitsString = isCelsius ? "°C" : "°F"

            let minTemp = temperature.minTemp.convertWeatherToUserUnits(celsius: isCelsius)
            let maxTemp = temperature.maxTemp.convertWeatherToUserUnits(celsius: isCelsius)

            cell.temperatureLabel.text = "Weather: \(minTemp)...\(maxTemp)\(userUnitsString)"
        }
        if let image = cells[indexPath.row].cityImage {
            var options = ImageLoadingOptions(
                placeholder: UIImage(named: "tripPlaceholder"),
                failureImage: UIImage(named: "tripPlaceholder"),
                tintColors: .none
            )
            let pipeline = ImagePipeline(configuration: .withDataCache)
            options.pipeline = pipeline
            let processors = [ImageProcessors.CoreImageFilter(name: "CIExposureAdjust", parameters: [kCIInputEVKey: -0.3], identifier: "nuke-filter-ev")]
            let request = ImageRequest(
                url: URL(string: image),
                processors: processors
            )
            loadImage(with: request, options: options, into: cell.mainImageView)
        } else {
            cell.mainImageView.image = UIImage(named: "tripPlaceholder")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionDelegate?.didTapCell(data: cells[indexPath.row])
    }
}

protocol TripCollectionViewDelegate: AnyObject {
    func didTapCell(data: TripModel)
}
