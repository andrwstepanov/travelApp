//
//  TripModel.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 29.04.2022.
//

import Foundation
import RealmSwift

struct TripModel {
    @Persisted var location: Location
    @Persistedm var upcoming: Bool
    
    @Persisted var startDate: DateComponents
    @Persisted var finishDate: DateComponents
    @Persisted var tripID = UUID()
    
    
    //uploaded as 2nd stage
    @Persisted var weather: Weather?
    @Persisted var checklist: [ChecklistSection]?
    @Persisted var cityImage: String?
    
    struct Location {
        let cityName: String
        let countryName: String
//        let latitude: String
//        let longitude: String
        
    }
    
    struct Weather {
        let maxTemp: Int
        let minTemp: Int
        let avgTemp: Int
    }
    
    struct ChecklistSection {
        var sectionHeader: String
        var sectionChecklist: [ChecklistElement]?
    }
        
    struct ChecklistElement {
        let id: UUID
        var title: String
        var isDone: Bool
        
        init(title: String) {
          self.id = UUID()
          self.title = title
          self.isDone = false
        }
    }
    
    init(city: String, country: String, startDate: DateComponents, finishDate: DateComponents) {
        self.upcoming = true
        self.location = Location(cityName: city, countryName: country)
        self.startDate = startDate
        self.finishDate = finishDate
        weather = nil
        checklist = nil
        cityImage = nil
    }
    
    static func testData() -> [TripModel] {
        let firstItem = TripModel(city: "Tbilisi", country: "Georgia", startDate: DateComponents(year: 2022, month: 05, day: 15), finishDate: DateComponents(year: 2022, month: 5, day: 25))

        let secondItem = TripModel(city: "Krabi", country: "Thailand", startDate: DateComponents(year: 2022, month: 9, day: 1), finishDate: DateComponents(year: 2022, month: 9, day: 15))
    
        let thirdItem = TripModel(city: "Stokholm", country: "Sweden", startDate: DateComponents(year: 2022, month: 10, day: 5), finishDate: DateComponents(year: 2022, month: 10, day: 11))
        
        return [firstItem, secondItem, thirdItem]
        
    }
    
    static func intro() -> [TripModel] {
        let item1 = TripModel(city: "Add your first trip", country: "", startDate: DateComponents(year: 2022, month: 05, day: 15), finishDate: DateComponents(year: 2022, month: 05, day: 15))
        return [item1]
    }
    
    static func testEmptyData() -> [TripModel]? {
        return nil
    }
    
    static func addNewTrip(city: String, country: String, startDate: DateComponents, finishDate: DateComponents) -> TripModel {
        let item = TripModel(city: city, country: country, startDate: startDate, finishDate: finishDate)
        return item
    }
    
//    static func testData() -> [TripModel] {
//        let firstItem = TripModel(location: Location(cityName: "Tbilisi", countryName: "Georgia"), weather: Weather(maxTemp: 28, minTemp: 17, avgTemp: 21), upcoming: true, startingDate: DateComponents(year: 2022, month: 05, day: 15), finishDate: DateComponents(year: 2022, month: 5, day: 25), cityImage: "https://d13k13wj6adfdf.cloudfront.net/urban_areas/tbilisi-583faa1bea.jpg", checklist: nil)
//
//        let secondItem = TripModel(location: Location(cityName: "Krabi", countryName: "Thailand"), weather: Weather(maxTemp: 33, minTemp: 24, avgTemp: 28), upcoming: true, startingDate: DateComponents(year: 2022, month: 9, day: 1), finishDate: DateComponents(year: 2022, month: 9, day: 15), cityImage: "https://d13k13wj6adfdf.cloudfront.net/urban_areas/phuket-5b86d83465.jpg", checklist: nil)
//
//        let thirdItem = TripModel(location: Location(cityName: "Stokholm", countryName: "Sweden"), weather: Weather(maxTemp: 5, minTemp: -3, avgTemp: 0), upcoming: false, startingDate: DateComponents(year: 2022, month: 10, day: 5), finishDate: DateComponents(year: 2022, month: 10, day: 11), cityImage: "https://d13k13wj6adfdf.cloudfront.net/urban_areas/stockholm-a696fe73b4.jpg", checklist: nil)
//
//        return [firstItem, secondItem, thirdItem]
//
//    }
}
