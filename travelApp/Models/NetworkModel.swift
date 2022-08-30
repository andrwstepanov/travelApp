//
//  WeatherData.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 25.04.2022.
//

import Foundation

struct WeatherResponse: Codable {
    let days: [Days]
    struct Days: Codable {
        let tempmax: Double
        let tempmin: Double
        let temp: Double
        let icon: String
    }
}

struct CityImageResponse: Codable {
    let photos: [Photos]
    struct Photos: Codable {
        let attribution: Attribution
        let image: WebImage

        struct Attribution: Codable {
            let license: String
            let photographer: String
        }
        struct WebImage: Codable {
            let mobile: String
            let web: String
        }
    }
}

struct GeocodingResponse: Codable {
    let name: String
}
