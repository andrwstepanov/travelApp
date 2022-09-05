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

protocol MainScreenDelegate: AnyObject {
    func openSettings()
}

protocol Coordinating: AnyObject {
    var coordinator: Coordinator? { get set }
}

enum Event {
    case settingsTapped
    case addNewTrip
}

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController?

    func eventOccured(with type: Event) {
        switch type {
        case .settingsTapped: openVC(with: SettingsVC.instantiate(), modal: true)
        case .addNewTrip: openVC(with: CreateNewTripVC.instantiate())
        }
    }

    private func openVC(with viewController: UIViewController & Coordinating, modal: Bool = false) {
        var nextController: UIViewController & Coordinating = viewController
        nextController.coordinator = self

        if modal {
            nextController.modalPresentationStyle = .formSheet
            navigationController?.showDetailViewController(nextController, sender: self)
        } else {
            navigationController?.show(nextController, sender: self)

        }
    }


    func start() {
        let viewController: UIViewController & Coordinating = MainScreen.instantiate()
        viewController.coordinator = self
        navigationController?.setViewControllers([viewController], animated: false)

   //     navigationController?.pushViewController(viewController, animated: false)
    }

}
