//
//  Extentions.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 11.07.2022.
//

import UIKit

extension Double {
    func convertWeatherToUserUnits(celsius: Bool) -> String {
        let input = Measurement(value: self, unit: UnitTemperature.kelvin)
        let userUnitsCase: UnitTemperature = celsius ? .celsius : .fahrenheit
        let output = input.converted(to: userUnitsCase).value
        let outputString = String(format: "%.0f", output)
        return outputString
    }
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let cornerRadii = CGSize(width: radius, height: radius)
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIPageControl {
    var page: Int {
        get {
            return currentPage
        }
        set {
            currentPage = newValue
        }
    }
}

extension UILabel {
    func colorString(text: String?, coloredText: String?, color: UIColor? = .red) {
        let attributedString = NSMutableAttributedString(string: text!)
        let range = (text! as NSString).range(of: coloredText!)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color!],
                                       range: range)
        self.attributedText = attributedString
    }
}

extension UIButton {
    func alignImageAndTitleVertically(padding: CGFloat = 6.0) {
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
}
