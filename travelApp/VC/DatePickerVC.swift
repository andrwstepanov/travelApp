//
//  DatePickerController.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 05.06.2022.
//

import UIKit
import FSCalendar

class DatePickerVC: UIViewController {

    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var fsCalendarView: FSCalendar!
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange: [Date]?
    weak var datePickerControllerDelegate: DatePickerControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        fsCalendarView.delegate = self
        fsCalendarView.dataSource = self
        fsCalendarView.today = nil
        fsCalendarView.swipeToChooseGesture.isEnabled = true
        let scopeGesture = UIPanGestureRecognizer(target: fsCalendarView, action: #selector(fsCalendarView.handleScopeGesture(_:)));
        fsCalendarView.addGestureRecognizer(scopeGesture)
        fsCalendarView.appearance.eventSelectionColor = UIColor.blue
        self.title = "Calendar picker"
        fsCalendarView.allowsMultipleSelection = true
        doneButton.layer.cornerRadius = 22.5

    }
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        datePickerControllerDelegate?.tripDatesConfirmed(starting: firstDate, finishing: lastDate)
        self.dismiss(animated: true)
    }
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        if let safeFirstDate = firstDate {
            let addedMonth = Calendar.current.date(byAdding: .month, value: 1, to: safeFirstDate)
            return addedMonth!
        }
        return Calendar.current.date(byAdding: .year, value: 3, to: Date())!
    }

}

extension DatePickerVC: FSCalendarDelegate, FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate == nil {
            firstDate = date
            fsCalendarView.reloadData()
            datesRange = [firstDate!]
            suggestionLabel.text = "Please select the end of your trip"
            return
        }

        if firstDate != nil && lastDate == nil {

            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                fsCalendarView.reloadData()
                datesRange = [firstDate!]
                return
            }

            let range = datesRangeFunc(from: firstDate!, to: date)
            lastDate = range.last

            for dateSelection in range {
                calendar.select(dateSelection)
            }

            datesRange = range
            suggestionLabel.text = "Click Done once ready"
            return
        }
        func datesRangeFunc(from: Date, to: Date) -> [Date] {

            if from > to { return [Date]() }

            var tempDate = from
            var array = [tempDate]

            while tempDate < to {
                tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
                array.append(tempDate)
            }
            return array
        }

        if firstDate != nil && lastDate != nil {
            for dateSelection in calendar.selectedDates {
                calendar.deselect(dateSelection)
            }
            lastDate = nil
            firstDate = nil
            fsCalendarView.reloadData()
            datesRange = []
        }
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate != nil && lastDate != nil {
            for dateSelection in calendar.selectedDates {
                calendar.deselect(dateSelection)
            }
            lastDate = nil
            firstDate = nil
            fsCalendarView.reloadData()
            datesRange = []
        }
    }
}

protocol DatePickerControllerDelegate: AnyObject {
    func tripDatesConfirmed(starting: Date?, finishing: Date?)
}
