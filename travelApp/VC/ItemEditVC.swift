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
    let trip: TripModel!
    var popUpMenuSelectionIndex = 1
    let optionalIndexPath: IndexPath?
    
    init?(coder: NSCoder, trip: TripModel, index: IndexPath?) {
        self.trip = trip
        optionalIndexPath = index
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDropdownCategories(indexPath: optionalIndexPath)
        initForEditing(indexPath: optionalIndexPath)
        setupUI()
    }
    
    func setupUI() {
        itemDescription.borderStyle = .roundedRect
        popUpCategory.layer.borderWidth = 1
        popUpCategory.layer.borderColor = UIColor.systemGray6.cgColor
        popUpCategory.layer.cornerRadius = 5
    }
    
    func setDropdownCategories(indexPath: IndexPath?) {
        var index = IndexPath(item: 0, section: 0)
        if let safeIndex = indexPath { index = safeIndex }
        
        popUpCategory.showsMenuAsPrimaryAction = true
        popUpCategory.changesSelectionAsPrimaryAction = true
        var catMenuArray: [UIAction] = []
        
        let optionClosure = {[weak self] (action : UIAction) in
            let selectedTitle = action.title
            self?.popUpMenuSelectionIndex = catMenuArray.firstIndex(where: { $0.title == selectedTitle})! + 1
        }
        for category in trip.checklist {
            let catLabel = category.sectionHeader
            catMenuArray.append(UIAction(title: catLabel, handler: optionClosure))
        }
        catMenuArray.remove(at: 0)
        catMenuArray[index.section].state = .on
        popUpCategory.menu = UIMenu(children: catMenuArray)
    }
    
    func initForEditing(indexPath: IndexPath?) {
        stepper.maximumValue = 10
        stepper.minimumValue = 1
        stepper.autorepeat = true
        guard let safeIndex = indexPath else { return }
        itemDescription.text = trip.checklist[safeIndex.section].sectionChecklist[safeIndex.row].title
        quantityLabel.text = "\(trip.checklist[safeIndex.section].sectionChecklist[safeIndex.row].quantity)"
        popUpMenuSelectionIndex = safeIndex.section
        stepper.value = Double(quantityLabel.text ?? "1") ?? 1.0
    }
    @IBAction func saveTapped(_ sender: UIButton) {
        guard let newName = itemDescription.text else { print("no text!"); return }
        let newQty = Int(quantityLabel.text ?? "1") ?? 1
        let newCategoryRef = trip.checklist[popUpMenuSelectionIndex]
        
        if let indexPath = optionalIndexPath {
            let curCategoryRef = trip.checklist[indexPath.section]
            let itemRef = curCategoryRef.sectionChecklist[indexPath.row]
            RealmManager.sharedDelegate().updateItem(checklistItem: itemRef,
                                                     newName: newName,
                                                     newQty: newQty)
            RealmManager.sharedDelegate().moveItemToCategoryIfNeeded(item: itemRef,
                                                                     newCat: newCategoryRef,
                                                                     currentCat: curCategoryRef)
        } else {
            let item = ChecklistElement(title: newName, quantity: newQty)
            RealmManager.sharedDelegate().writeItem(checklist: newCategoryRef, item: item)
        }
        self.dismiss(animated: true)
    }
    @IBAction func quantityChanged(_ sender: UIStepper) {
        quantityLabel.text = Int(sender.value).description
    }
}
