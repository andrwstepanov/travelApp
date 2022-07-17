//
//  GeocodingManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 10.06.2022.
//

import Foundation

struct GeocodingManager {
    var delegate: GeocodingManagerDelegate?
    var session = URLSession.shared

    
    private let apiURL = Config.APIkeys.geocodingApiURL
    private let apiKey = HiddenKeys.geocodingApiKey
    
    func asyncGeocoding(lat: Double, lon: Double) async throws -> GeocodingResponse? {
        let stringLat = String(lat)
        let stringLon = String(lon)
        
        let urlString = "\(apiURL)?lat=\(stringLat)&lon=\(stringLon)&limit=1&appid=\(apiKey)"
        if let geocodingUrl = URL(string: urlString) {
            let (data, _) = try await session.data(from: geocodingUrl)
            let decoder = JSONDecoder()
            do {
                return try decoder.decode([GeocodingResponse].self, from: data)[0]
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
            return try decoder.decode(GeocodingResponse.self, from: data)
        } else {
            print("no geocoding response sent")
            return nil
            
        }
    }
}

protocol GeocodingManagerDelegate {
    func didUpdateGeocoding(GeocodingManager: GeocodingManager, location: GeocodingResponse)
    func didEndWithError(error: Error)
}
