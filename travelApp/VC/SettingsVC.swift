//
//  SettingsViewController.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 21.06.2022.
//

import UIKit

class SettingsVC: UIViewController, Coordinating {
    var coordinator: Coordinator?

    let userDefaults = UserDefaults.standard
    var userGenderIsMale = true
    var userUnitsIsCelsius = true

    override func loadView() {
        loadCurrentData()
        view = Settings(saveAction: saveSettings,
                        userGenderIsMale: userGenderIsMale,
                        userUnitsIsCelsius: userUnitsIsCelsius)
    }

    func saveSettings(male: Bool, celsius: Bool) {
        writeSettings(male: male, celsius: celsius)
        coordinator?.eventOccured(with: .settingsSaved)
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }
}

// MARK: Private functions

extension SettingsVC {
    private func loadCurrentData() {
        let genderSetToMale = userDefaults.bool(forKey: Config.UserDefaultsNames.userGenderIsMale)
        userGenderIsMale = genderSetToMale ? true : false
        let unitsSetToCelsius = userDefaults.bool(forKey: Config.UserDefaultsNames.userUnitsIsCelsius)
        userUnitsIsCelsius = unitsSetToCelsius ? true : false
    }

    private func writeSettings(male: Bool, celsius: Bool) {
        userDefaults.set(male, forKey: Config.UserDefaultsNames.userGenderIsMale)
        userDefaults.set(celsius, forKey: Config.UserDefaultsNames.userUnitsIsCelsius)


    }
}
