//
//  TripModel.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 29.04.2022.
//

import Foundation
import RealmSwift

class TripModel: Object {
    @Persisted var location: Location? = nil
    @Persisted var upcoming: Bool
    @Persisted var startDate: Date
    @Persisted var finishDate: Date
    @Persisted(primaryKey: true) var id: ObjectId

    // uploaded as 2nd stage
    @Persisted var weather: Weather?
    @Persisted var checklist: List<ChecklistSection>
    @Persisted var cityImage: String?

    convenience init(city: String, country: String, latitude: Double, longitude: Double, startDate: Date, finishDate: Date) {
        self.init()
        self.upcoming = true
        self.location = Location(cityName: city, countryName: country, latitude: latitude, longitude: longitude)
        self.startDate = startDate
        self.finishDate = finishDate
        weather = nil
        let tempChecklist = [ChecklistSection(sectionHeader: "Weather", sectionChecklist: [ChecklistElement(title: "weatherPlaceholder", quantity: 0)])]
        checklist.append(objectsIn: tempChecklist)
        cityImage = nil
    }

    static func intro() -> TripModel {
        let startDate = Calendar.current.date(from: DateComponents(year: 2022, month: 05, day: 15))!
        let finishDate = Calendar.current.date(from: DateComponents(year: 2022, month: 05, day: 15))!
        let city = "Hello"
        let country = "add your first trip"
        let introItem = TripModel(city: city, country: country, latitude: 0.0, longitude: 0.0,  startDate: startDate, finishDate: finishDate)
        introItem.weather = Weather(maxTemp: 315.1, minTemp: 290.7, avgTemp: 293.2)
        introItem.checklist.append(PackingManager.sharedInstance.testChecklist)
        return introItem
    }

    static func testEmptyData() -> [TripModel]? {
        return nil
    }
}

class Location: Object {
    @Persisted var cityName: String
    @Persisted var countryName: String
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    convenience init(cityName: String, countryName: String, latitude: Double, longitude: Double) {
        self.init()
        self.cityName = cityName
        self.countryName = countryName
        self.latitude = latitude
        self.longitude = longitude
    }
}
class Weather: Object {
    @Persisted var maxTemp: Double
    @Persisted var minTemp: Double
    @Persisted var avgTemp: Double
    
    convenience init(maxTemp: Double, minTemp: Double, avgTemp: Double) {
        self.init()
        self.maxTemp = maxTemp
        self.minTemp = minTemp
        self.avgTemp = avgTemp
    }
}
class ChecklistSection: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var sectionHeader: String
    @Persisted var sectionChecklist: List<ChecklistElement>
    convenience init(sectionHeader: String, sectionChecklist: [ChecklistElement]) {
        self.init()
        self.sectionHeader = sectionHeader
        self.sectionChecklist.append(objectsIn: sectionChecklist)
    }
}
class ChecklistElement: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var quantity: Int
    @Persisted var isDone: Bool
    convenience init(title: String, quantity: Int) {
        self.init()
        self.title = title
        self.quantity = quantity
        self.isDone = false
    }
}
