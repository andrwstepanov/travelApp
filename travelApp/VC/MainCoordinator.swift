//
//  Coordinator.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 04.09.2022.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController : UINavigationController? { get set }
    func start()
    func eventOccured(with type: Event)
}

protocol MainScreenDelegate: AnyObject {
    func openSettings()
}

protocol Coordinating {
    var coordinator: Coordinator? { get set }
}

enum Event {
    case settingsTapped
}

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController?
//    init(navigationController: UINavigationController) {
//
//        self.navigationController = navigationController
//    }


    func eventOccured(with type: Event) {
        switch type {
        case .settingsTapped: print("settings tap registred")
        }
    }

    func start() {
        var viewController: UIViewController & Coordinating = MainScreen.instatiate()
        viewController.coordinator = self
        navigationController?.setViewControllers([viewController], animated: false)

   //     navigationController?.pushViewController(viewController, animated: false)
    }

}
