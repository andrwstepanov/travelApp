//
//  Coordinator.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 04.09.2022.
//

import UIKit

protocol Coordinator {
//    var childCoordinators: [Coordinator] { get set }
//    var navigationController : UINavigationController { get set }
    func start()
}



class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController?
//    init(navigationController: UINavigationController) {
//
//        self.navigationController = navigationController
//    }


    func start() {
        let viewController = MainScreen.instatiate()
        navigationController?.pushViewController(viewController, animated: true)
    }

}
