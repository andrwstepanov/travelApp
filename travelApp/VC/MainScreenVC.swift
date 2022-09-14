//
//  ViewController.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 22.04.2022.
//

import UIKit
import RealmSwift

class MainScreenVC: UIViewController, Storyboarded, Coordinating {

    // MARK: - IBOutlets
//    weak var delegate: MainScreenDelegate?
    private var trips: Results<TripModel>!
    private var tripCollectionView = TripCollectionView()
    private var notificationToken: NotificationToken?
    private var tripHistorySelected = false
    private var selectorIndicator: UIView!
    var coordinator: Coordinator?

    override func loadView() {
        tripCollectionView.collectionDelegate = self
        view = MainScreen(tripCollectionView: tripCollectionView,
                          addTripAction: addTripAction,
                          settingsAction: settingsAction,
                          historyToggleAction: historyToggleAction)
    }

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
//        delegate = self
        trips = RealmManager.sharedInstance.getTrips()
        self.checkDataSourceAndAddIntro()
    }

    private func checkDataSourceAndAddIntro() {
        if trips.count == 0 {
            let introTrip = TripModel.intro()
            RealmManager.sharedDelegate().writeTrip(trip: introTrip)
            let userDefaults = UserDefaults.standard
            let key = "\(introTrip.id)"
            userDefaults.set(key, forKey: Config.UserDefaultsNames.introID)
        }
        tripCollectionView.set(cells: trips)
        notificationToken = trips.observe {(changes: RealmCollectionChange) in
            switch changes {
            case .initial(_): break
            case .update(_, _, _, _):
                self.tripCollectionView.reloadData()

            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    // MARK: IBActions

    private func settingsAction() {
        coordinator?.eventOccured(with: .settingsTapped)
    }

    private func addTripAction() {
        coordinator?.eventOccured(with: .addNewTrip)
    }

    private func historyToggleAction(upcoming: Bool) {
        self.trips = RealmManager.sharedInstance.getTrips().filter("upcoming == \(upcoming)")
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: { [unowned self] in
            self.tripCollectionView.set(cells: trips)
            self.tripCollectionView.reloadData()
        })
    }
}

extension MainScreenVC: TripCollectionViewDelegate {
    func didTapCell(trip: TripModel) {
        showTrip(trip: trip)
    }

    func showTrip(trip: TripModel) {
        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainSB.instantiateViewController(identifier: "TripView", creator: { coder in
            return TripView(coder: coder, tripModel: trip, config: Config(), backgroundWriter: BackgroundRealm())
        })
        navigationController?.pushViewController(vc, animated: true)
    }
}

//extension MainScreen: MainScreenDelegate {
//    func openSettings() {
//        print("implementation from vc")
//    }
//}
