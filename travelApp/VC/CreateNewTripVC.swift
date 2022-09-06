//
//  EnterCityController.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 24.04.2022.
//

import UIKit
import MapKit
import FSCalendar

class CreateNewTripVC: UIViewController, Storyboarded, Coordinating {

    @IBOutlet weak var citySearchButton: UIButton!
    @IBOutlet weak var tripDatesButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var workToggleButton: UIButton!
    @IBOutlet weak var beachToggleButton: UIButton!
    @IBOutlet weak var sportToggleButton: UIButton!

    var tripLocation: MKMapItem?
    var tripDates: [Date]?
    let backgroundRealm = BackgroundRealm()
    var coordinator: Coordinator?

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
        // Formulate trip according to user data
        guard let trip = generateTrip() else { return }

        RealmManager.sharedDelegate().writeTrip(trip: trip)

        // Remove intro trip
        let userDefaults = UserDefaults.standard
        if let introID = userDefaults.string(forKey: Config.UserDefaultsNames.introID) {
            guard let ref: TripModel = RealmManager.sharedDelegate().getReference(id: introID) else { return }
            RealmManager.sharedDelegate().writeTrip(trip: ref, delete: true)
            userDefaults.removeObject(forKey: Config.UserDefaultsNames.introID)

        }


        // Add test data
        RealmManager.sharedDelegate().writeSection(trip: trip,
                                                   section: PackingManager.sharedInstance.testChecklist)
        RealmManager.sharedDelegate().writeSection(trip: trip,
                                                   section: PackingManager.sharedInstance.electronicsChecklist)

        backgroundRealm.requestTripDataAndWrite(for: trip)

        Config.popToMainScreen(navController: navigationController!)

    }

    private func generateTrip() -> TripModel? {
        guard let safeLocation = tripLocation, let safeDates = tripDates else { return nil }
        let city = safeLocation.name ?? ""
        let country = safeLocation.placemark.country ?? ""
        let lat = safeLocation.placemark.coordinate.latitude
        let lon = safeLocation.placemark.coordinate.longitude
        let startDate = safeDates[0]
        let finishDate = safeDates[1]

        let trip = TripModel(city: city,
                                 country: country,
                                 latitude: lat,
                                 longitude: lon,
                                 startDate: startDate,
                                 finishDate: finishDate)
        return trip
    }
}


extension CreateNewTripVC: DatePickerControllerDelegate {
    func tripDatesConfirmed(starting: Date?, finishing: Date?) {
        guard let safeStarting = starting, let safeFinishing = finishing else { return }
        tripDates = [safeStarting, safeFinishing]

        // Display chosen dates on button
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        tripDatesButton.setTitle("\(dateFormatter.string(from: safeStarting)) - \(dateFormatter.string(from: safeFinishing))",
                                 for: UIControl.State.normal)
        if tripDates != nil && tripLocation != nil {
            nextButton.isEnabled = true
        }
    }
}

extension CreateNewTripVC: CitySearchDelegate {
    func citySelected(locationResponse: MKMapItem) {
        tripLocation = locationResponse

        // Display chosen location on button
        citySearchButton.setTitle(locationResponse.name ?? "", for: .normal)

        if tripDates != nil && tripLocation != nil { nextButton.isEnabled = true }
    }
}
