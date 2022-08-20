//
//  TripView.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 14.05.2022.
//

import UIKit
import Nuke
import RealmSwift
import NukeUI
import NukeExtensions

class TripView: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var headerLocationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerUIView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var headerRoundedCornersView: UIView!
    @IBOutlet weak var headerTripDates: UILabel!
    @IBOutlet weak var headerDotsButton: UIButton!
    var mainMenu = UIMenu()
    var tripModel: TripModel?
    var notificationToken: NotificationToken? = nil
    var weatherManager = WeatherManager()
    var photoManager = PhotoManager(geocodingManager: GeocodingManager())

    private let floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        button.backgroundColor = Config.Colors.darkGreen
        return button
    }()

    func viewDidDisappear() {
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        watchChanges()
        setupUI()

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editItem" {
            let taskEdit = segue.destination as! ItemEditVC
            taskEdit.indexPath = sender as? IndexPath
            taskEdit.tripModel = tripModel
            taskEdit.modalPresentationStyle = .formSheet
        }
    }

    private func watchChanges() {
        notificationToken = tripModel?.checklist.observe {[unowned self] changes in
            switch changes {
            case .initial(let _):
                break
            case .update(let _, let deletions, let insertions, let modifications):
                self.tableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    private func setupUI() {

        headerLocationLabel.text = "\(tripModel?.location!.cityName ?? ""), \(tripModel?.location!.countryName ?? "")"
        registerCells()
        addFloatingButton()

        tableView.tableHeaderView = headerUIView
        navigationItem.title = ""
        
        stickHeaderImageToTop()
        navBarCustomBackButton()
        navBarInitial()

        tableView.bounds = view.bounds
        headerRoundedCornersView.backgroundColor = .white
        headerRoundedCornersView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        headerTripDates.text = "\(dateFormatter.string(from: tripModel!.startDate)) - \(dateFormatter.string(from: tripModel!.finishDate))"
        if let image = tripModel?.cityImage {
            var options = ImageLoadingOptions (
                failureImage: UIImage(named: "tripPlaceholder")
            )
            let pipeline = ImagePipeline(configuration: .withDataCache)
            options.pipeline = pipeline
            let processors = [ImageProcessors.CoreImageFilter(name: "CIExposureAdjust", parameters: [kCIInputEVKey: -0.3], identifier: "nuke-filter-ev")]
            let request = ImageRequest(
                url: URL(string: image),
                processors: processors
                )
            loadImage(with: request, options: options, into: headerImageView)
        } else {
            headerImageView.image = UIImage(named: "tripPlaceholder")
        }
         mainMenu = UIMenu(title: "", children: [
            UIAction(title: "Delete trip", image: UIImage(systemName: "trash"), attributes: .destructive) {[unowned self] _ in
                self.deleteTrip()
            },
        ])
        headerDotsButton.menu = mainMenu
        headerDotsButton.showsMenuAsPrimaryAction = true
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 20
        }
    }
    private func navBarCustomBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "chevron-padding-png"),
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.leftBarButtonItem?.setBackButtonBackgroundVerticalPositionAdjustment(CGFloat(100), for: .default)

    }
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    private func stickHeaderImageToTop() {
        tableView.contentInsetAdjustmentBehavior = .never
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        headerImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true    }
    private func registerCells() {
        let packlistCell = UINib(nibName: "PacklistCell", bundle: nil)
        tableView.register(packlistCell, forCellReuseIdentifier: "packlistCell")
        let weatherCell = UINib(nibName: "WeatherCell", bundle: nil)
        tableView.register(weatherCell, forCellReuseIdentifier: "weatherCell")
    }
    private func addFloatingButton() {
        tableView.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.setImage(UIImage(systemName: "plus"), for: .normal)
        floatingButton.tintColor = .white
        floatingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        floatingButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -75).isActive = true
        floatingButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        floatingButton.addTarget(self, action: #selector(addChecklistItem(_ :)), for: .touchUpInside)
    }
    @objc func addChecklistItem(_ sender: UIButton) {
        self.performSegue(withIdentifier: "editItem", sender: nil)
         }
    private func tryToFetchAgain() {
//        Task {
//            await weatherManager.loadAndSaveWeather(trip: tripModel!)
//            try await photoManager.getAndWriteCityUrl(trip: tripModel!)
//            tableView.reloadData()
//        }
    }
    private func navBarCompact() {
        if navigationItem.title == "" {
            navigationItem.title = "\(tripModel?.location!.cityName ?? ""), \(tripModel?.location!.countryName ?? "")"
//            if #available(iOS 13.0, *) {
//                let navBarAppearance = UINavigationBarAppearance()
//                navBarAppearance.backgroundColor = .white
//                navigationController?.navigationBar.standardAppearance = navBarAppearance
//                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
//            }
            if #available(iOS 15, *) {
                guard let navigationBar = navigationController?.navigationBar else { return }

                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground() // use `configureWithTransparentBackground` for transparent background
                appearance.backgroundColor = .white
                appearance.shadowColor = .clear
                appearance.shadowImage = UIImage()

                navigationBar.standardAppearance = appearance
              //  navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
            }
            self.navigationController?.navigationBar.tintColor = .black
            self.navigationController?.navigationBar.barStyle = .default
            self.navigationItem.rightBarButtonItem = .init(systemItem: .edit)
            navigationItem.rightBarButtonItem?.menu = mainMenu
        }
    }
    private func navBarInitial() {
        if navigationItem.title != " " {
            navigationItem.title = " "
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.tintColor = .white
//            if #available(iOS 13.0, *) {
//                let navBarAppearance = UINavigationBarAppearance()
//                navBarAppearance.configureWithOpaqueBackground()
//                navBarAppearance.backgroundColor = .clear
//
//                navigationController?.navigationBar.standardAppearance = navBarAppearance
//                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
//            }
            if #available(iOS 15, *) {
                guard let navigationBar = navigationController?.navigationBar else { return }

                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.shadowColor = .clear
                appearance.shadowImage = UIImage()

                navigationBar.standardAppearance = appearance
                navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
            }
                self.setNeedsStatusBarAppearanceUpdate()
            navigationItem.rightBarButtonItem = nil

        }
    }

}

// MARK: Data Source

extension TripView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RealmManager.sharedDelegate().toggleChecklistItem(trip: tripModel!, index: indexPath)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if tableView.contentOffset.y < 70 {
            headerImageView.layer.opacity = Float(-0.014285714285714285 * tableView.contentOffset.y + 1)
        } else {
            headerImageView.layer.opacity = 0.0
        }
        if tableView.contentOffset.y > 70 {
            navBarCompact()
        } else if tableView.contentOffset.y < 50 {
            navBarInitial()
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tripModel?.checklist[section].sectionHeader
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if let safeTripModel = tripModel {
            if !safeTripModel.isInvalidated {
               return safeTripModel.checklist.count
            } else { return 0 }
        } else { return 0 }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tripModel?.checklist[section].sectionChecklist.count ?? 0
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Config.Colors.textDarkGray
        header.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        header.textLabel?.text =  header.textLabel?.text?.capitalized
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherCell

            cell.selectionStyle = .none

            if let temperatureString = WeatherManager.sharedInstance.returnWeatherInUserUnits(trip: tripModel!), let avgTempString = WeatherManager.sharedInstance.returnAvgTemp(trip: tripModel!) {
                cell.weatherTemperatureLabel.text = temperatureString
                cell.weatherConditionLabel.text = avgTempString
            } else {
                tryToFetchAgain()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "packlistCell", for: indexPath) as! PacklistCell
            cell.dotsButton.menu = UIMenu(title: "", children: [
                    UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) {[unowned self] _ in
                        self.performSegue(withIdentifier: "editItem", sender: indexPath)
                    },
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) {[unowned self] _ in
                        self.deleteItem(indexPath: indexPath)
                    }

                ])
            if let checklist = tripModel?.checklist[indexPath.section].sectionChecklist[indexPath.row] {
                cell.cellLabel.text = checklist.title
                cell.quantityLabel.text = "\(checklist.quantity)"
                cell.checkButton.isSelected = checklist.isDone
                cell.checkButton.isUserInteractionEnabled = false
            }
            cell.selectionStyle = .none
                return cell
        }
    }
}

// MARK: Trip deletion implementation

extension TripView {
    private func deleteTrip() {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {[unowned self] (action) -> Void in
            self.deleteMyTrip(trip: self.tripModel!)
            self.popToPrevious()

        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {[unowned self] _ -> Void in
        }

        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    private func deleteItem(indexPath: IndexPath) {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: {[unowned self]  (action) -> Void in
            RealmManager.sharedDelegate().deleteItem(trip: self.tripModel!, indexPath: indexPath)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {[unowned self]  (action) -> Void in
        }
        dialogMessage.addAction(okButton)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    private func deleteMyTrip(trip: TripModel) {
        do {
            let realm = try Realm(configuration: RealmManager.realmConfig)
            Task {
                await realm.writeAsync {
                    realm.delete(trip)
                }
            }
        } catch { print("error") }
    }
}
