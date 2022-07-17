//
//  Config.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 01.07.2022.
//

import Foundation
import UIKit

struct Config {

    static let resetApp = true
    
    struct APIkeys {
        static let geocodingApiURL = "https://api.openweathermap.org/geo/1.0/reverse"
        static let weatherApiURL = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/"
        static let photoRequestURL = "https://api.teleport.org/api/urban_areas/"
        
    }
    
    struct UIConstants {
        static let leftDistanceToView: CGFloat = 20
        static let rightDistanceToView: CGFloat = 20
        static let carouselLineSpacing: CGFloat = 10
        static let carouselTileWidth = (UIScreen.main.bounds.width - leftDistanceToView - rightDistanceToView - (carouselLineSpacing/2)) / 1.5
        static let buttonCornerRadius: CGFloat = 22.5
        static let squareButtonRadius: CGFloat = 8
    }
    
    struct Colors {
        static let darkGreen = UIColor(red: 0.349, green: 0.455, blue: 0.427, alpha: 1)
        static let textDarkGray = UIColor(red: 0.267, green: 0.243, blue: 0.243, alpha: 1)
    }
    
    struct UserDefaultsNames {
        static let userGenderIsMale = "userGenderIsMale"
        static let userUnitsIsCelsius = "userUnitsIsCelsius"
        static let launchedBefore = "launchedBefore"
    }
    
    struct OnboardingImages {
        static let slide1 = UIImage(named: "slide1")
        static let slide2 = UIImage(named: "slide2")
        static let slide3 = UIImage(named: "slide3")
        static let pageSelected = UIImage(named: "pageSelected")
        static let page = UIImage(named: "pageSelected")

        static let imageArray = [
            Config.OnboardingImages.slide1,
            Config.OnboardingImages.slide2,
            Config.OnboardingImages.slide3
        ]
    }
    
    struct OnboardingText {
        static let onboardingTitles = [
            "Never forget your stuff",
            "Be prepared",
            "Be flexible"
        ]
        static let onboardingSubtitles = [
            "Packing lists ready for your trips",
            "Overview climatic conditions during your trip to fine-tune your list",
            "Automatic adjustment to weather and trip length"
        ]
    }
    
    struct Segues {
        static let initialSettings = "initialSettings"
    }
    
    static func popToMainScreen(navController: UINavigationController) {
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        navController.view.layer.add(transition, forKey: nil)
        _ = navController.popToRootViewController(animated: false)
        
    }
}

