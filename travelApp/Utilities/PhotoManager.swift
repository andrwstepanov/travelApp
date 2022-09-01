//
//  PhotoManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 30.04.2022.
//

import Foundation
import RealmSwift

struct PhotoManager {
    let networkManager: NetworkManager

    func searchForCityImageURL(trip: TripModel) async throws -> String? {
        let imageURL = try await geocodeCityAndGetImage(trip: trip)
        return imageURL
    }
    
    private func geocodeCityAndGetImage(trip: TripModel) async throws -> String? {
        if let lat = trip.location?.latitude, let lon = trip.location?.longitude {
            let geocodingResponse = try await asyncGeocoding(lat: lat, lon: lon)
            guard let cityName = geocodingResponse?[0].name else { return nil }
            let imageResponse = try await getCityPhoto(city: cityName)
            let cityImage = imageResponse?.photos[0].image.mobile
            return cityImage
        } else { return nil }
    }
    private func getCityPhoto(city: String) async throws -> CityImageResponse? {
        let photoRequestURL = Config.APIPath.photoRequestURL
        let lowercaseCity = city.lowercased().replacingOccurrences(of: " ", with: "-")
        let urlString = "\(photoRequestURL)slug:\(lowercaseCity)/images/"

        return try await networkManager.getNetworkData(urlString: urlString)
    }
    private func asyncGeocoding(lat: Double, lon: Double) async throws -> [GeocodingResponse]? {
        let geoRequestURL = Config.APIPath.geocodingApiURL
        guard let geoRequestKey = HiddenKeys.geocodingApiKey else { return [] }
        let stringLat = String(lat)
        let stringLon = String(lon)
        
        let urlString = "\(geoRequestURL)?lat=\(stringLat)&lon=\(stringLon)&limit=1&appid=\(geoRequestKey)"
        return try await networkManager.getNetworkData(urlString: urlString)
    }
}
