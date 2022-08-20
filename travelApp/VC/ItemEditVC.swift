//
//  TaskEditVC.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 08.07.2022.
//

import UIKit
import RealmSwift

class ItemEditVC: UIViewController {
    @IBOutlet weak var itemDescription: UITextField!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var popUpCategory: UIButton!
    var tripModel: TripModel!
    var popUpMenuSelectionIndex = 1
    var optionalIndexPath: IndexPath?
    var editMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if let safeIndexPath = optionalIndexPath {
            initForEditing(indexPath: safeIndexPath)
            setDropdownCategories(indexPath: safeIndexPath)
        } else { setDropdownCategories(indexPath: IndexPath(row: 0, section: 0)) }
        itemDescription.borderStyle = .roundedRect
        popUpCategory.layer.borderWidth = 1
        popUpCategory.layer.borderColor = UIColor.systemGray6.cgColor
        popUpCategory.layer.cornerRadius = 5
    }

    func setDropdownCategories(indexPath: IndexPath) {
        popUpCategory.showsMenuAsPrimaryAction = true
        popUpCategory.changesSelectionAsPrimaryAction = true
        var catMenuArray: [UIAction] = []

        let optionClosure = {[weak self] (action : UIAction) in
            let selectedTitle = action.title
            self?.popUpMenuSelectionIndex = catMenuArray.firstIndex(where: { $0.title == selectedTitle})! + 1
        }
        for category in tripModel.checklist {
            let catLabel = category.sectionHeader
            catMenuArray.append(UIAction(title: catLabel, handler: optionClosure))
        }
        if editMode { catMenuArray[indexPath.section].state = .on }
        catMenuArray.remove(at: 0)
        popUpCategory.menu = UIMenu(children: catMenuArray)
    }

    private func addBorder(to myView: UIView) -> UIView {
        let frame = CGRect(x: 0, y: myView.frame.size.height, width: myView.frame.size.width, height: 1)
        let borderBottom = UIView(frame: frame)
        borderBottom.backgroundColor = UIColor.lightGray
        return borderBottom
    }
    func initForEditing(indexPath: IndexPath) {
        editMode = true
        itemDescription.text = tripModel.checklist[indexPath.section].sectionChecklist[indexPath.row].title
        quantityLabel.text = "\(tripModel.checklist[indexPath.section].sectionChecklist[indexPath.row].quantity)"
        popUpMenuSelectionIndex = indexPath.section
        stepper.maximumValue = 10
        stepper.minimumValue = 1
        stepper.autorepeat = true
        stepper.value = Double(quantityLabel.text ?? "1") ?? 1.0
    }
    @IBAction func saveTapped(_ sender: UIButton) {
        let newName = itemDescription.text!
        let newQty = Int(quantityLabel.text ?? "1") ?? 1
        let sectionReference: ChecklistSection = tripModel.checklist[popUpMenuSelectionIndex]
        if let indexPath = optionalIndexPath {
            let itemReference = tripModel.checklist[indexPath.section].sectionChecklist[indexPath.row]
            RealmManager.sharedDelegate().updateChecklistItem(trip: tripModel, indexPath: indexPath, checklistItem: itemReference, newName: newName, newQty: newQty, newCat: sectionReference)
        } else {
            RealmManager.sharedDelegate().addItemToCategory(name: newName, qty: newQty, cat: sectionReference)
        }
        self.dismiss(animated: true)
    }
    @IBAction func quantityChanged(_ sender: UIStepper) {
        quantityLabel.text = Int(sender.value).description
    }
}
