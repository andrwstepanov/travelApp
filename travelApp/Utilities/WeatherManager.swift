//
//  WeatherManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 24.04.2022.
//

import Foundation
import Nuke

struct WeatherManager {
    private let crossingURL = Config.APIkeys.weatherApiURL
    private let apiKey = HiddenKeys.weatherApiKey
    var delegate: WeatherManagerDelegate?
    var session = URLSession.shared
    static let sharedInstance = WeatherManager()
    func loadAndReturnWeather(trip: TripModel) async -> Weather? {
        let weatherResponse = try? await asyncFetchWeather(trip: trip)
        if let weatherResponse = weatherResponse {
            let weather = calculateAvg(weather: weatherResponse)
            return weather
        }
        return nil
    }
    func returnWeatherInUserUnits(trip: TripModel) -> String? {
        let userDefaults = UserDefaults.standard
        let userUnitsIsCelsius: Bool = userDefaults.bool(forKey: Config.UserDefaultsNames.userUnitsIsCelsius)
        if let minTemp = trip.weather?.minTemp, let maxTemp = trip.weather?.maxTemp {
            let userUnitsString = userUnitsIsCelsius ? "°C" : "°F"
            let userUnitsCase: UnitTemperature = userUnitsIsCelsius ? .celsius : .fahrenheit
            let minTempUserUnits = String(format: "%.0f", convertTemperature(temp: minTemp, from: .kelvin, to: userUnitsCase))
            let maxTempUserUnits = String(format: "%.0f", convertTemperature(temp: maxTemp, from: .kelvin, to: userUnitsCase))
            return "\(minTempUserUnits)...\(maxTempUserUnits)\(userUnitsString)"
        }
        return nil
    }
    func returnAvgTemp(trip: TripModel) -> String? {
        let userDefaults = UserDefaults.standard
        let userUnitsIsCelsius: Bool = userDefaults.bool(forKey: Config.UserDefaultsNames.userUnitsIsCelsius)
        if let avgTemp = trip.weather?.avgTemp {
            let userUnitsString = userUnitsIsCelsius ? "°C" : "°F"
            let userUnitsCase: UnitTemperature = userUnitsIsCelsius ? .celsius : .fahrenheit
            let onAverageString = "on average"
            let avgTempUserUnits = String(format: "%.0f", convertTemperature(temp: avgTemp, from: .kelvin, to: userUnitsCase))
            return "\(avgTempUserUnits)\(userUnitsString) \(onAverageString)"
        }
        return nil
    }
    private func convertTemperature(temp: Double, from inputTempType: UnitTemperature, to outputTempType: UnitTemperature) -> Double {
        let input = Measurement(value: temp, unit: inputTempType)
        let output = input.converted(to: outputTempType)
        return output.value
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-d"
        let tripStart = dateFormatter.string(from: trip.startDate)
        let tripFinish = dateFormatter.string(from: trip.finishDate)
        if let lat = trip.location?.latitude, let lon = trip.location?.longitude {
            let urlString = "\(crossingURL)/\(lat),\(lon)/\(tripStart)/\(tripFinish)?key=\(apiKey)"
            let url = URL(string: urlString)
            let (data, _) = try await session.data(from: url!)
            let decoder = JSONDecoder()
            return try decoder.decode(WeatherResponse.self, from: data)
        } else { return nil }
    }
}

protocol WeatherManagerDelegate {
    func didUpdateWeather(weatherManager: WeatherManager, weather: WeatherResponse)
    func didEndWithError(error: Error)
}
