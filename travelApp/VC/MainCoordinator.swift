//
//  Coordinator.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 04.09.2022.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController : UINavigationController? { get set }
    func start()
    func eventOccured(with type: Event)
}

//protocol MainScreenDelegate: AnyObject {
//    func openSettings()
//}

protocol Coordinating: AnyObject {
    var coordinator: Coordinator? { get set }
}

enum Event {
    case settingsTapped
    case settingsSaved
    case addNewTrip
}

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController?

    func eventOccured(with type: Event) {
        switch type {
        case .settingsTapped: openVC(with: SettingsVC(), modal: true)
        case .addNewTrip: openVC(with: CreateNewTripVC.instantiate())
        case .settingsSaved: settingsSaved()
        }
    }

    private func openVC(with viewController: UIViewController & Coordinating, modal: Bool = false) {
        var nextController: UIViewController & Coordinating = viewController
        nextController.coordinator = self

        if modal {
            navigationController?.present(nextController, animated: true)
        } else {
            navigationController?.show(nextController, sender: self)
//            let child = BuyCoordinator(navigationController: navigationController)
//            childCoordinators.append(child)
//            child.start()
        }
    }

    private func checkInOnboarded() -> Bool {
        let userDefaults = UserDefaults.standard
        if Config.resetApp { userDefaults.set(false, forKey: Config.UserDefaultsNames.launchedBefore) }
        if !userDefaults.bool(forKey: Config.UserDefaultsNames.launchedBefore) { return false }
        return true
    }

    private func settingsSaved() {
        let onboarded = checkInOnboarded()
        if onboarded {
            navigationController?.popViewController(animated: true)
        } else {
            let userDefaults = UserDefaults.standard
            userDefaults.set(true, forKey: Config.UserDefaultsNames.launchedBefore)
            startMain()
        }
    }

    private func startMain() {
        let viewController: UIViewController & Coordinating = MainScreenVC()
        viewController.coordinator = self
        navigationController?.setViewControllers([viewController], animated: false)
    }

    private func startIntro() {
        let viewController: UIViewController & Coordinating = OnboardingVC.instantiate()
        viewController.coordinator = self
        navigationController?.setViewControllers([viewController], animated: false)
    }

    func start() {
        let onboarded = checkInOnboarded()
        if onboarded { startMain() } else { startIntro() }
    }

}
