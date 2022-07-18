//
//  PhotoManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 30.04.2022.
//

import Foundation
import RealmSwift

struct PhotoManager {
    let geocodingManager: GeocodingManager
    var session = URLSession.shared
    let photoRequestURL = Config.APIkeys.photoRequestURL


    func getAndWriteCityUrl(trip: TripModel) async throws -> String? {
        let imageURL = try await geocodeCityAndGetImage(trip: trip)
        return imageURL
    }
    
    private func geocodeCityAndGetImage(trip: TripModel) async throws -> String? {

        if let lat = trip.location?.latitude, let lon = trip.location?.longitude {
            let geocodingResponse = try await geocodingManager.asyncGeocoding(lat: lat, lon: lon)
            let cityName = geocodingResponse?.name ?? ""
            
            let imageResponse = try await getCityPhoto(city: cityName)
            let cityImage = imageResponse?.photos[0].image.mobile
            return cityImage
            
        } else { return nil }
    }
    
    
    private func getCityPhoto(city: String) async throws -> CityImageResponse? {
        let lowercaseCity = city.lowercased().replacingOccurrences(of: " ", with: "-")
        let urlString = "\(photoRequestURL)slug:\(lowercaseCity)/images/"
        let url = URL(string: urlString)
        
        do {
            let (data, _) = try await session.data(from: url!)
            let decoder = JSONDecoder()
            return try decoder.decode(CityImageResponse.self, from: data)
        } catch {
            return nil
        }
  }
}


