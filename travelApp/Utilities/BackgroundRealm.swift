//
//  RequestManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 18.08.2022.
//

import Foundation
import RealmSwift

class BackgroundRealm {
    let photoManager = PhotoManager(networkManager: NetworkManager())
    let weatherManager = WeatherManager(networkManager: NetworkManager())

    let lock = NSLock()
    enum WritePath {
        case weather(weatherData: Weather)
        case image(url: String)
    }
    func requestTripDataAndWrite(for trip: TripModel?) {
        let frozenTrip = trip?.freeze()
        guard let safeTrip = frozenTrip else { return }
        Task {
            let photoURL = try await photoManager.searchForCityImageURL(trip: safeTrip)
            if let safePhotoURL = photoURL {
                asyncWrite(trip: safeTrip, data: .image(url: safePhotoURL))
            }
        }
        Task {
            let weather = await weatherManager.loadAndReturnWeather(trip: safeTrip)
            if let safeWeather = weather {
                asyncWrite(trip: safeTrip, data: .weather(weatherData: safeWeather))
            }
        }
    }
    func asyncWrite(trip: TripModel,  data: WritePath) {
        do {
            lock.lock()
            let realm = try! Realm(configuration: RealmManager.realmConfig)
            guard let thawTrip = trip.thaw() else { return }
            try realm.write {
                switch data {
                case .weather(weatherData: let weatherData):
                    thawTrip.weather = weatherData
                case .image(url: let url):
                    thawTrip.cityImage = url
                }
            }
            lock.unlock()
        } catch {
            print("error writing in background")
        }
    }
}
