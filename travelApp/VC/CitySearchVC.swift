//
//  CitySearchVC.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 07.07.2022.
//

import UIKit
import CoreLocation
import MapKit

protocol CitySearchDelegate: AnyObject {
    func citySelected(locationResponse: MKMapItem)
}

class CitySearchVC: UIViewController, UITableViewDelegate {
    private var suggestionController: CitySuggestionsTableVC!
    private var searchController: UISearchController!
    private var localSearch: MKLocalSearch?
    weak var citySearchDelegate: CitySearchDelegate?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        suggestionController = CitySuggestionsTableVC(style: .grouped)
        suggestionController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
    }
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    private func search(using searchRequest: MKLocalSearch.Request) {
        searchRequest.resultTypes = .address
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { (response, error) in
            if let safeResponse = response {
                self.citySearchDelegate?.citySelected(locationResponse: safeResponse.mapItems[0])
                self.dismiss(animated: true)
            }
            guard error == nil else {
                print("Error while searching for choosen location")
                return
            }
        }
    }
}

extension CitySearchVC {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            search(for: suggestion)
        }
    }
}

extension CitySearchVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

