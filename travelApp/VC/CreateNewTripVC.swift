//
//  EnterCityController.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 24.04.2022.
//

import UIKit
import CoreLocation
import MapKit
import Combine
import FSCalendar

class CreateNewTripVC: UIViewController {

    @IBOutlet weak var citySearchButton: UIButton!
    @IBOutlet weak var tripDatesButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var workToggleButton: UIButton!
    @IBOutlet weak var beachToggleButton: UIButton!
    @IBOutlet weak var sportToggleButton: UIButton!
    var tempTrip: TripModel!
    var tempCity: String!
    var tempCountry: String!
    var tempLat: Double!
    var tempLon: Double!
    var tempStartDate: Date?
    var tempFinishDate: Date?
    var weatherManager = WeatherManager()
    var photoManager = PhotoManager(geocodingManager: GeocodingManager())

    override func viewDidLoad() {
        super.viewDidLoad()
        addBorderstoButton(to: citySearchButton)
        addBorderstoButton(to: tripDatesButton)
        setupToggleButtons()
        applyRadius()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openDatePicker" {
            let dateSelectorPopover = segue.destination as! DatePickerVC
            dateSelectorPopover.datePickerControllerDelegate = self
        }
        if segue.identifier == "openCitySearch" {
            let openCitySearchNav = segue.destination as! UINavigationController
            let openCitySearch = openCitySearchNav.viewControllers.first as! CitySearchVC?
            openCitySearch?.citySearchDelegate = self
        }
    }
    private func applyRadius() {
        nextButton.layer.cornerRadius = Config.UIConstants.buttonCornerRadius
        workToggleButton.layer.cornerRadius = Config.UIConstants.squareButtonRadius
        beachToggleButton.layer.cornerRadius = Config.UIConstants.squareButtonRadius
        sportToggleButton.layer.cornerRadius = Config.UIConstants.squareButtonRadius

    }
    private func setupToggleButtons() {
        workToggleButton.alignImageAndTitleVertically(padding: 10)
        beachToggleButton.alignImageAndTitleVertically(padding: 10)
        sportToggleButton.alignImageAndTitleVertically(padding: 10)
    }
    private func addBorderstoButton(to button: UIButton) {
        button.setTitle("", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.cornerRadius = Config.UIConstants.squareButtonRadius
    }
    private func toggleButton(button: UIButton) {
        button.isSelected.toggle()
        if button.isSelected {
            button.tintColor = UIColor.white
            button.backgroundColor = Config.Colors.darkGreen
            button.setTitleColor(UIColor.white, for: .selected)
        } else {
            button.tintColor = Config.Colors.textDarkGray
            button.backgroundColor = UIColor.systemGray5
            button.setTitleColor(Config.Colors.textDarkGray, for: .normal)
        }
    }
    @IBAction func workToggleTapped(_ sender: UIButton) {
        toggleButton(button: sender)
    }
    @IBAction func beachToggleTapped(_ sender: UIButton) {
        toggleButton(button: sender)
    }
    @IBAction func sportToggleTapped(_ sender: UIButton) {
        toggleButton(button: sender)
    }
    @IBAction func createTripTapped(_ sender: UIButton) {
        if let safeStartDate = tempStartDate, let safeFinishDate = tempFinishDate{
            tempTrip = TripModel(city: tempCity, country: tempCountry, latitude: tempLat, longitude: tempLon, startDate: safeStartDate, finishDate: safeFinishDate)
            RealmManager.sharedDelegate().addTrip(trip: tempTrip)
            RealmManager.sharedDelegate().changeTripChecklist(trip: tempTrip, checklist: PackingManager.sharedInstance.testChecklist)
            RealmManager.sharedDelegate().changeTripChecklist(trip: tempTrip, checklist: PackingManager.sharedInstance.electronicsChecklist)
            Task {
                let photoURL = try await photoManager.getAndWriteCityUrl(trip: tempTrip)
                let weather = await weatherManager.loadAndSaveWeather(trip: tempTrip)
                if let safeWeather = weather {
                    RealmManager.sharedDelegate().writeWeather(trip: tempTrip, weather: safeWeather)
                }
                if let safePhotoURL = photoURL {
                    RealmManager.sharedDelegate().writeImage(trip: tempTrip, imageURL: safePhotoURL)
                }
            }
            Config.popToMainScreen(navController: navigationController!)
        }
    }
}

extension CreateNewTripVC: DatePickerControllerDelegate {
    func tripDatesConfirmed(starting: Date?, finishing: Date?) {
        tempStartDate = starting
        tempFinishDate = finishing
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
    
        tripDatesButton.setTitle("\(dateFormatter.string(from: starting!)) - \(dateFormatter.string(from: finishing!))", for: UIControl.State.normal)
        if tempStartDate != nil && tempFinishDate != nil && tempCity != nil {
            nextButton.isEnabled = true
        }
    }
}

extension CreateNewTripVC: CitySearchDelegate {
    func citySelected(locationResponse: MKMapItem) {
        tempCity = locationResponse.name ?? ""
        tempCountry = locationResponse.placemark.country
        tempLat = locationResponse.placemark.coordinate.latitude
        tempLon = locationResponse.placemark.coordinate.longitude
        citySearchButton.setTitle(tempCity, for: .normal)
        if tempStartDate != nil && tempFinishDate != nil && tempCity != nil {
            nextButton.isEnabled = true
        }
    }
}
