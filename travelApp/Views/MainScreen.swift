//
//  MainScreen.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 11.09.2022.
//

import UIKit
import SnapKit

class MainScreen: UIView {

    var settingsAction: (() -> Void)?
    var addTripAction: (() -> Void)?
    var historyToggleAction: ((Bool) -> Void)?

    lazy private var segmentedControlContainer = UIView()
    lazy private var historyToggle = UISegmentedControl()
    lazy private var underlineView = UIView()
    private var tripCollectionView: UICollectionView

    init(tripCollectionView: UICollectionView,
         addTripAction: @escaping() -> Void,
         settingsAction: @escaping() -> Void,
         historyToggleAction: @escaping(Bool) -> Void) {

        self.tripCollectionView = tripCollectionView
        self.addTripAction = addTripAction
        self.settingsAction = settingsAction
        self.historyToggleAction = historyToggleAction
        super.init(frame: .zero)

        backgroundColor = .white
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        let helloLabel = UILabel()
        helloLabel.text = "Hello!"
        helloLabel.font = .systemFont(ofSize: 21)
        addSubview(helloLabel)
        helloLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(34)
            make.left.equalTo(safeAreaLayoutGuide).offset(20)
        }

        var settingsBtnConfig = UIButton.Configuration.plain()
        settingsBtnConfig.image = UIImage(systemName: "gearshape.fill",
                                          withConfiguration: UIImage.SymbolConfiguration(pointSize: 23))

        let settingsButton = UIButton(type: .system)
        settingsButton.tintColor = Config.Colors.darkGreen
        settingsButton.configuration = settingsBtnConfig
        addSubview(settingsButton)

        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(34)
            make.right.equalTo(safeAreaLayoutGuide).inset(35)
            make.height.width.equalTo(18)
        }
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)

        let headline = UILabel()
        headline.colorString(text: Config.MainScreenText.stringOne,
                                      coloredText: Config.MainScreenText.stringTwo,
                                      color: Config.Colors.darkGreen)
        headline.numberOfLines = 3
        headline.font = .systemFont(ofSize: 36, weight: .semibold)
        addSubview(headline)
        headline.snp.makeConstraints { make in
            make.top.equalTo(helloLabel.snp.bottom).offset(33)
            make.left.equalTo(safeAreaLayoutGuide).offset(20)
        }

        addSubview(segmentedControlContainer)
        segmentedControlContainer.snp.makeConstraints { make in
            make.top.equalTo(headline.snp.bottom).offset(33)
            make.height.equalTo(44)
            make.left.right.equalTo(safeAreaLayoutGuide).inset(20)
        }

        historyToggle.insertSegment(withTitle: "My upcoming trips", at: 0, animated: true)
        historyToggle.insertSegment(withTitle: "My trip history", at: 1, animated: true)
        historyToggle.tintColor = .clear
        historyToggle.backgroundColor = .clear
        historyToggle.removeBorders()
        historyToggle.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.systemGray2,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)], for: .normal)

        historyToggle.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: Config.Colors.darkGreen,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)], for: .selected)

        historyToggle.selectedSegmentIndex = 0
        historyToggle.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)

        segmentedControlContainer.addSubview(historyToggle)

        underlineView.backgroundColor = Config.Colors.textDarkGray
        segmentedControlContainer.addSubview(underlineView)

        historyToggle.snp.makeConstraints { make in
            make.edges.equalTo(segmentedControlContainer)
        }

        underlineView.snp.makeConstraints { make in
            make.left.equalTo(historyToggle.snp.left)
            make.bottom.equalTo(historyToggle.snp.bottom)
            make.height.equalTo(2)
            make.width.equalTo(historyToggle.snp.width).multipliedBy(0.5)
        }

        var addBtnConfig = UIButton.Configuration.plain()
        addBtnConfig.image = UIImage(systemName: "plus.circle.fill",
                                          withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))

        settingsButton.configuration = settingsBtnConfig
        addSubview(settingsButton)


        let addButton = UIButton(type: .system)
        addButton.configuration = addBtnConfig
        addButton.tintColor = Config.Colors.darkGreen
        addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.left.right.equalTo(safeAreaLayoutGuide)
        }
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        addSubview(tripCollectionView)
        tripCollectionView.snp.makeConstraints {make in
            make.top.equalTo(segmentedControlContainer.snp.bottom).offset(20)
            make.left.right.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(addButton.snp.top).offset(-20)
        }
    }

    @objc private func settingsTapped() {
        settingsAction?()
    }

    @objc private func addTapped() {
        addTripAction?()
    }

    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        changeSegmentedControlLinePosition()

        let historySelection = sender.selectedSegmentIndex
        let upcomingTripsSelected = historySelection == 0 ? true : false
        historyToggleAction?(upcomingTripsSelected)
    }

    private func changeSegmentedControlLinePosition() {
        let segmentIndex = CGFloat(historyToggle.selectedSegmentIndex)
        let segmentWidth = historyToggle.frame.width / CGFloat(historyToggle.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.underlineView.snp.updateConstraints { make in
                guard let constraint = self?.historyToggle.snp.left else { return }
                make.left.equalTo(constraint).offset(leadingDistance)
            }
            self?.layoutIfNeeded()
        })
    }

}
