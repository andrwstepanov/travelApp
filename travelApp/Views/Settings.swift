//
//  Settings.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 07.09.2022.
//

import UIKit
import SnapKit

class Settings: UIView {

    var saveAction: ((Bool, Bool) -> Void)?
    var male = true
    var celsius = true

    init(saveAction: @escaping(Bool, Bool) -> Void, userGenderIsMale: Bool, userUnitsIsCelsius: Bool) {
        self.saveAction = saveAction
        super.init(frame: .zero)

        male = userGenderIsMale
        celsius = userUnitsIsCelsius
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        let headline = UILabel()
        headline.text = "Preferences"
        headline.font = UIFont.systemFont(ofSize: 34, weight: .semibold)
        addSubview(headline)
        headline.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(50)
        }

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Set up preferences to customize your packing lists"
        descriptionLabel.font = UIFont.systemFont(ofSize: 21)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(headline.snp.bottom).offset(35)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        let genderLabel = UILabel()
        genderLabel.text = "Gender"
        genderLabel.font = UIFont.systemFont(ofSize: 17)
        genderLabel.textAlignment = .center
        addSubview(genderLabel)
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(35)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }

        let genderSwitch = UISegmentedControl()
        genderSwitch.insertSegment(withTitle: "Male", at: 0, animated: false)
        genderSwitch.insertSegment(withTitle: "Female", at: 1, animated: false)
        addSubview(genderSwitch)
        genderSwitch.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
        genderSwitch.selectedSegmentIndex = male ? 0 : 1
        genderSwitch.addTarget(self, action: #selector(genderSliderChanged(_:)), for: .valueChanged)

        let unitsLabel = UILabel()
        unitsLabel.text = "Units"
        unitsLabel.font = UIFont.systemFont(ofSize: 17)
        unitsLabel.textAlignment = .center
        addSubview(unitsLabel)
        unitsLabel.snp.makeConstraints { make in
            make.top.equalTo(genderSwitch.snp.bottom).offset(35)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }

        let unitsSwitch = UISegmentedControl()
        unitsSwitch.insertSegment(withTitle: "Celsius", at: 0, animated: false)
        unitsSwitch.insertSegment(withTitle: "Fahrenheit", at: 1, animated: false)
        addSubview(unitsSwitch)
        unitsSwitch.snp.makeConstraints { make in
            make.top.equalTo(unitsLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
        unitsSwitch.selectedSegmentIndex = celsius ? 0 : 1
        unitsSwitch.addTarget(self, action: #selector(unitsSliderChanged(_:)), for: .valueChanged)


        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(35)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        doneButton.backgroundColor = Config.Colors.darkGreen
        doneButton.layer.cornerRadius = Config.UIConstants.buttonCornerRadius

        doneButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    @objc func saveTapped() {
        saveAction?(male, celsius)
    }

    @objc func genderSliderChanged(_ sender: UISegmentedControl) {
        male = sender.selectedSegmentIndex == 0 ? true : false
    }

    @objc func unitsSliderChanged(_ sender: UISegmentedControl) {
        celsius = sender.selectedSegmentIndex == 0 ? true : false
    }
}
