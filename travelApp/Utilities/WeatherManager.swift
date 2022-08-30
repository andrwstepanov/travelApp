//
//  WeatherManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 24.04.2022.
//

import Foundation
import Nuke

struct WeatherManager {

//    var delegate: WeatherManagerDelegate?
    let networkManager: NetworkManager

    func loadAndReturnWeather(trip: TripModel) async -> Weather? {
        let weatherResponse = try? await asyncFetchWeather(trip: trip)
        if let weatherResponse = weatherResponse {
            let weather = calculateAvg(weather: weatherResponse)
            return weather
        }
        return nil
    }
    
    private func calculateAvg(weather: WeatherResponse) -> Weather {
        var tempSum = 0.0
        let tempCount = weather.days.count
        var tempMin = weather.days[0].tempmin
        var tempMax = weather.days[0].tempmax
        for day in weather.days {
            tempSum += day.temp
            if tempMin < day.tempmin {
                tempMin = day.tempmin
            }
            if tempMax > day.tempmax {
                tempMax = day.tempmax
            }
        }
        let avgTemp = tempSum/Double(tempCount)
        return Weather(maxTemp: tempMax, minTemp: tempMin, avgTemp: avgTemp)
    }
    private func asyncFetchWeather(trip: TripModel) async throws -> WeatherResponse? {
        let weatherAPIURL = Config.APIPath.weatherApiURL
        let weatherAPIKey = HiddenKeys.weatherApiKey
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-d"
        let tripStart = dateFormatter.string(from: trip.startDate)
        let tripFinish = dateFormatter.string(from: trip.finishDate)
        if let lat = trip.location?.latitude, let lon = trip.location?.longitude {
            let urlString = "\(weatherAPIURL)/\(lat),\(lon)/\(tripStart)/\(tripFinish)?key=\(weatherAPIKey)"
            return try await networkManager.getNetworkData(urlString: urlString)
        } else { return nil }
    }
}
