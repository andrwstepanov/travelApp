//
//  SettingsViewController.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 21.06.2022.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var unitsChangerSwitch: UISegmentedControl!
    @IBOutlet weak var genderChangerSwitch: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCurrentData()

        saveButton.layer.cornerRadius = Config.UIConstants.buttonCornerRadius
        navigationItem.hidesBackButton = true
    }
}

// MARK: IBActions

extension SettingsVC {
    @IBAction func saveTapped(_ sender: UIButton) {
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: Config.UserDefaultsNames.launchedBefore) {
            userDefaults.set(true, forKey: Config.UserDefaultsNames.launchedBefore)
            Config.popToMainScreen(navController: navigationController!)
        } else { self.dismiss(animated: true) }
    }
    
    @IBAction func unitsChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: toggleSetting(settingKey: Config.UserDefaultsNames.userUnitsIsCelsius, newSetting: true)
        case 1: toggleSetting(settingKey: Config.UserDefaultsNames.userUnitsIsCelsius, newSetting: false)
        default: break
        }
    }
   @IBAction func genderChanged(_ sender: UISegmentedControl) {
       switch sender.selectedSegmentIndex {
       case 0: toggleSetting(settingKey: Config.UserDefaultsNames.userGenderIsMale, newSetting: true)
       case 1: toggleSetting(settingKey: Config.UserDefaultsNames.userGenderIsMale, newSetting: false)
       default: break
       }
   }
}

// MARK: Private functions

extension SettingsVC {
    private func loadCurrentData() {
        let userDefaults = UserDefaults.standard
        let userGenderIsMale = userDefaults.bool(forKey: Config.UserDefaultsNames.userGenderIsMale)
        let userUnitsIsCelsius = userDefaults.bool(forKey: Config.UserDefaultsNames.userUnitsIsCelsius)
        switch userGenderIsMale {
        case true: genderChangerSwitch.selectedSegmentIndex = 0
        case false: genderChangerSwitch.selectedSegmentIndex = 1
        }
        
        switch userUnitsIsCelsius {
        case true: unitsChangerSwitch.selectedSegmentIndex = 0
        case false: unitsChangerSwitch.selectedSegmentIndex = 1
        }
    }
    
    private func toggleSetting(settingKey: String, newSetting: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newSetting, forKey: settingKey)
    }
    
}
