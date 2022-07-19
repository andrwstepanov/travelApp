//
//  TaskEditVC.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 08.07.2022.
//

import UIKit
import SwiftUI
import RealmSwift
import IQKeyboardManagerSwift

class ItemEditVC: UIViewController {
    @IBOutlet weak var itemDescription: UITextField!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var popUpCategory: UIButton!
    
    var indexPath: IndexPath!
    var tripModel: TripModel!
    var popUpMenuSelectionIndex: Int!
    var editMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEditMode()
        if editMode { setupUI() }
        setPopupButton()
        
        itemDescription.borderStyle = .roundedRect
        popUpCategory.layer.borderWidth = 1
        popUpCategory.layer.borderColor = UIColor.systemGray6.cgColor
        popUpCategory.layer.cornerRadius = 5
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let firstVC = presentingViewController as? TripView {
                    DispatchQueue.main.async {
                        firstVC.tableView.reloadData()
            }
        }
    }

    func setEditMode() {
        if indexPath != nil {
            editMode = true
        } else { editMode = false }
    }
    
    func setPopupButton() {
        popUpCategory.showsMenuAsPrimaryAction = true
        popUpCategory.changesSelectionAsPrimaryAction = true
        var catMenuArray: [UIAction] = []

        let optionClosure = {(action : UIAction) in
            let selectedTitle = action.title
            self.popUpMenuSelectionIndex = catMenuArray.firstIndex(where: { $0.title == selectedTitle})! + 1
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
    func setupUI() {
            itemDescription.text = tripModel.checklist[indexPath!.section].sectionChecklist[indexPath!.row].title
        quantityLabel.text = "\(tripModel.checklist[indexPath!.section].sectionChecklist[indexPath!.row].quantity)"
        popUpMenuSelectionIndex = indexPath.section
        
        stepper.maximumValue = 10
        stepper.minimumValue = 1
        stepper.autorepeat = true
        stepper.value = Double(quantityLabel.text ?? "1") ?? 1.0
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        let newName = itemDescription.text!
        let newQty = Int(quantityLabel.text ?? "1") ?? 1
        var checklistSectionReference: Object? = tripModel.checklist[popUpMenuSelectionIndex]
        if editMode {
            let itemReference = tripModel.checklist[indexPath.section].sectionChecklist[indexPath.row]
            if popUpMenuSelectionIndex == indexPath.section { checklistSectionReference = nil }
            let newCat = checklistSectionReference as? ChecklistSection
            
            RealmManager.sharedDelegate().updateChecklistItem(trip: tripModel, indexPath: indexPath, checklistItem: itemReference, newName: newName, newQty: newQty, newCat: newCat)
        } else {
            RealmManager.sharedDelegate().addItemToCategory(name: newName, qty: newQty, cat: checklistSectionReference as! ChecklistSection)
        }
        self.dismiss(animated: true)
    }
    @IBAction func quantityChanged(_ sender: UIStepper) {
        quantityLabel.text = Int(sender.value).description
    }

}
