//
//  ViewController.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 22.04.2022.
//

import UIKit
import SwiftUI
import RealmSwift

class MainScreen: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var myTripsAndPackingLabel: UILabel!
    @IBOutlet weak var addTripButton: UIButton!
    @IBOutlet weak var tripHistoryButton: UIButton!
    @IBOutlet weak var upcomingTripsButton: UIButton!
    @IBOutlet weak var upcomingTripsStack: UIStackView!
    @IBOutlet weak var selectorHorizontalStack: UIStackView!
    var trips: Results<TripModel>!
    private var tripCollectionView = TripCollectionView()
    var notificationToken: NotificationToken? = nil
    var stringOne = "My trips \n& packing \nlists"
    let stringTwo = "packing"
    var borderPill: UIView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tripCollectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCollectionView()
        trips = RealmManager.sharedInstance.getTrips()
        self.checkDataSourceAndAddIntro()
        loadSettings()
        myTripsAndPackingLabel.colorString(text: stringOne, coloredText: stringTwo, color: Config.Colors.darkGreen)
        myTripsAndPackingLabel.font = .systemFont(ofSize: 36, weight: .bold)
        borderPill = addBorderstoButton(to: upcomingTripsButton)
        upcomingTripsButton.addSubview(borderPill)

    }

    private func addBorderstoButton(to button: UIButton) -> UIView {
        let frame = CGRect(x: button.frame.size.width / 2 - (34 / 3), y: button.frame.size.height, width: 34, height: 3)
        let borderBottom = UIView(frame: frame)
        borderBottom.backgroundColor = Config.Colors.darkGreen
        borderBottom.roundCorners(corners: .allCorners, radius: Config.UIConstants.buttonCornerRadius)

        return borderBottom
    }

    private func addCollectionView() {
        view.addSubview(tripCollectionView)
        tripCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tripCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tripCollectionView.topAnchor.constraint(equalTo: upcomingTripsStack.bottomAnchor, constant: 30).isActive = true
        tripCollectionView.bottomAnchor.constraint(equalTo: addTripButton.topAnchor, constant: -30).isActive = true
        tripCollectionView.collectionDelegate = self
    }
    
    private func loadSettings() {

        let userDefaults = UserDefaults.standard
        if Config.resetApp { userDefaults.set(false, forKey: Config.UserDefaultsNames.launchedBefore) }
        if !userDefaults.bool(forKey: Config.UserDefaultsNames.launchedBefore) {
        self.performSegue(withIdentifier: "openOnboarding", sender: self)
        }
    }
    
    private func checkDataSourceAndAddIntro() {
        if trips.count == 0 {
            RealmManager.sharedDelegate().addTrip(trip: TripModel.intro())
        }
        tripCollectionView.set(cells: trips)
        notificationToken = trips.observe {(changes: RealmCollectionChange) in
            switch changes {
            case .initial(let _): break
            case .update(let _, let deletions, let insertions, let modifications):
                self.tripCollectionView.reloadData()

            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    // MARK: IBActions

    @IBAction func addNewTrip(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addNew", sender: self)
    }
    @IBAction func tapOnUpcomingTrips(_ sender: UIButton) {

        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.borderPill.removeFromSuperview()
        }, completion: nil)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            sender.addSubview(self.borderPill)
        }, completion: nil)
        tripHistoryButton.isSelected = false
        upcomingTripsButton.isSelected = true
        self.trips = RealmManager.sharedInstance.getTrips().filter("upcoming == true")
        tripCollectionView.set(cells: trips)
        tripCollectionView.reloadData()
    }
    @IBAction func tapOnTripHistory(_ sender: UIButton) {
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.borderPill.removeFromSuperview()
        }, completion: nil)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            sender.addSubview(self.borderPill)
        }, completion: nil)
        tripHistoryButton.isSelected = true
        upcomingTripsButton.isSelected = false
        self.trips = RealmManager.sharedInstance.getTrips().filter("upcoming == false")
        tripCollectionView.set(cells: trips)
        tripCollectionView.reloadData()
    }

}

extension MainScreen: TripCollectionViewDelegate {
    func didTapCell(data: TripModel) {
        self.performSegue(withIdentifier: "openTripCard", sender: data)
    }
}

extension MainScreen {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openTripCard" {
            if let trip = sender as? TripModel {
                if let targetVC = segue.destination as? TripView {
                    targetVC.tripModel = trip
                }
            }
        }
    }
}
