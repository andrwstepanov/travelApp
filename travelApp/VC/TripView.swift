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

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var headerLocationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerUIView: UIView!
    @IBOutlet weak var headerRoundedCornersView: UIView!
    @IBOutlet weak var headerTripDates: UILabel!
    @IBOutlet weak var headerDotsButton: UIButton!

    let tripModel: TripModel
    let backgroundRealm: BackgroundRealm
    let config: Config
    var notificationToken: NotificationToken?
    var mainMenu = UIMenu()

    init?(coder: NSCoder, tripModel: TripModel, config: Config, backgroundWriter: BackgroundRealm) {
        self.tripModel = tripModel
        self.config = config
        backgroundRealm = backgroundWriter
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    func editItem(index: IndexPath?) {
        guard let viewController = storyboard?.instantiateViewController(identifier: "ItemEditVC", creator: {[unowned self] coder in
            return ItemEditVC(coder: coder, trip: self.tripModel, index: index)
        }) else {
            fatalError("Failed to load ItemEditVC from storyboard.")
        }
        self.present(viewController, animated: true)
    }

    private func watchChanges() {
        notificationToken = tripModel.checklist.observe {[unowned self] changes in
            switch changes {
            case .initial(_):
                break
            case .update(_, _, _, _):
                self.tableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    private func setupUI() {
        guard let location = tripModel.location else { return }
        headerLocationLabel.text = "\(location.cityName), \(location.countryName)"
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
        let startDateString = dateFormatter.string(from: tripModel.startDate)
        let finishDateString = dateFormatter.string(from: tripModel.finishDate)
        headerTripDates.text = "\(startDateString) - \(finishDateString)"
        if let image = tripModel.cityImage {
            var options = ImageLoadingOptions(
                failureImage: UIImage(named: "tripPlaceholder")
            )
            let pipeline = ImagePipeline(configuration: .withDataCache)
            options.pipeline = pipeline
            let processors = [ImageProcessors.CoreImageFilter(name: "CIExposureAdjust",
                                                              parameters: [kCIInputEVKey: -0.3],
                                                              identifier: "nuke-filter-ev")]
            let request = ImageRequest(
                url: URL(string: image),
                processors: processors
            )
            loadImage(with: request, options: options, into: headerImageView)
        } else {
            headerImageView.image = UIImage(named: "tripPlaceholder")
        }
        mainMenu = UIMenu(title: "", children: [
            UIAction(title: "Delete trip",
                     image: UIImage(systemName: "trash"),
                     attributes: .destructive) {[unowned self] _ in
                         self.deleteTrip()
                     }
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
        editItem(index: nil)
    }

    private func navBarCompact() {
        if navigationItem.title == "" {
            navigationItem.title = "\(tripModel.location!.cityName), \(tripModel.location!.countryName)"
            //            if #available(iOS 13.0, *) {
            //                let navBarAppearance = UINavigationBarAppearance()
            //                navBarAppearance.backgroundColor = .white
            //                navigationController?.navigationBar.standardAppearance = navBarAppearance
            //                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            //            }
            if #available(iOS 15, *) {
                guard let navigationBar = navigationController?.navigationBar else { return }

                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
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
        RealmManager.sharedDelegate().toggleItem(trip: tripModel, index: indexPath)
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
        tripModel.checklist[section].sectionHeader
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if !tripModel.isInvalidated {
            return tripModel.checklist.count
        } else { return 0 }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tripModel.checklist[section].sectionChecklist.count
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

            if let temperature = tripModel.weather {
                let userDefaults = UserDefaults.standard
                let isCelsius: Bool = userDefaults.bool(forKey: Config.UserDefaultsNames.userUnitsIsCelsius)
                let userUnitsString = isCelsius ? "°C" : "°F"
                let onAverageString = "on average"

                let minTemp = temperature.minTemp.convertWeatherToUserUnits(celsius: isCelsius)
                let avgTemp = temperature.avgTemp.convertWeatherToUserUnits(celsius: isCelsius)
                let maxTemp = temperature.maxTemp.convertWeatherToUserUnits(celsius: isCelsius)

                cell.weatherTemperatureLabel.text = "\(minTemp)...\(maxTemp)\(userUnitsString)"
                cell.weatherConditionLabel.text = "\(avgTemp)\(userUnitsString) \(onAverageString)"
            } else {
                backgroundRealm.requestTripDataAndWrite(for: tripModel)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "packlistCell", for: indexPath) as! PacklistCell
            cell.dotsButton.menu = UIMenu(title: "", children: [
                UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) {[unowned self] _ in
                    editItem(index: indexPath)
                },
                UIAction(title: "Delete",
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive) {[unowned self] _ in
                    self.deleteItem(indexPath: indexPath)
                }

            ])
            let checklist = tripModel.checklist[indexPath.section].sectionChecklist[indexPath.row]
            cell.cellLabel.text = checklist.title
            cell.quantityLabel.text = "\(checklist.quantity)"
            cell.checkButton.isSelected = checklist.isDone
            cell.checkButton.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            return cell
        }
    }
}

// MARK: Trip deletion implementation

extension TripView {
    private func deleteTrip() {
        let dialogMessage = UIAlertController(title: "Confirm",
                                              message: "Are you sure you want to delete this?",
                                              preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: {[unowned self] _ -> Void in
            RealmManager.sharedInstance.writeTrip(trip: tripModel, delete: true)
            self.popToPrevious()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {_ -> Void in
        }

        dialogMessage.addAction(okButton)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    private func deleteItem(indexPath: IndexPath) {
        let dialogMessage = UIAlertController(title: "Confirm",
                                              message: "Are you sure you want to delete this?",
                                              preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: {[unowned self] _ -> Void in
            let checklist = tripModel.checklist[indexPath.section]
            RealmManager.sharedInstance.writeItem(checklist: checklist,
                                                  item: checklist.sectionChecklist[indexPath.row],
                                                  delete: true)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {_ -> Void in
        }
        dialogMessage.addAction(okButton)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
}
