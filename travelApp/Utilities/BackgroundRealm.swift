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

    func requestTripDataAndWrite(for trip: TripModel?) {
        let frozenTrip = trip?.freeze()
        Task {
            print(1)
            let photoURL = try await photoManager.searchForCityImageURL(trip: frozenTrip!)
            print(2)
            if let safePhotoURL = photoURL {
                writeImage(trip: frozenTrip!, imageURL: safePhotoURL)
            }
        }

        Task {
            print(3)
            let weather = await weatherManager.loadAndReturnWeather(trip: frozenTrip!)
            print(4)
            if let safeWeather = weather {
                writeWeather(trip: frozenTrip!, weather: safeWeather)
            }
        }
    }
    

    func writeWeather(trip: TripModel, weather: Weather) {
        do {
            lock.lock()
            let realm = try! Realm(configuration: RealmManager.realmConfig)
            guard let thawTrip = trip.thaw() else { return }
             try realm.write {
                thawTrip.weather = weather
            }
            lock.unlock()
        }
        catch {

        }
    }

    func writeImage(trip: TripModel, imageURL: String) {
        do {
            lock.lock()
            let realm = try! Realm(configuration: RealmManager.realmConfig)
            guard let thawTrip = trip.thaw() else { return }
            try realm.write {
                thawTrip.cityImage = imageURL
            }
            lock.unlock()
        }
        catch {
        }
    }
}
