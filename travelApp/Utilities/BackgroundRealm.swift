//
//  RequestManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 18.08.2022.
//

import Foundation
import RealmSwift

struct BackgroundRealm {
    let photoManager = PhotoManager(geocodingManager: GeocodingManager())
    let weatherManager = WeatherManager()
    let lock = NSLock()
    enum WritePath {
        case weather(weatherData: Weather)
        case image(url: String)
    }
    func requestTripDataAndWrite(for trip: TripModel?) {
        let frozenTrip = trip?.freeze()
        Task {
            print(1)
            let photoURL = try await photoManager.searchForCityImageURL(trip: frozenTrip!)
            print(2)
            if let safePhotoURL = photoURL {
                asyncWrite(trip: frozenTrip!, data: .image(url: safePhotoURL))
            }
        }
        Task {
            print(3)
            let weather = await weatherManager.loadAndReturnWeather(trip: frozenTrip!)
            print(4)
            if let safeWeather = weather {
                asyncWrite(trip: frozenTrip!, data: .weather(weatherData: safeWeather))
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
