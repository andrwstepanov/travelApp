//
//  Storyboarded.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 05.09.2022.
//

import UIKit

extension Storyboarded where Self: UIViewController {
    static func instatiate() -> Self {
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: id) as! Self
    }
}

protocol Storyboarded {
   static func instatiate() -> Self
}
