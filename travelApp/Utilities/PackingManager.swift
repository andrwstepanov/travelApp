//
//  PackingManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 14.06.2022.
//

import Foundation
import RealmSwift


class PackingManager {
    
    static let sharedInstance = PackingManager()
    
    let testChecklist: ChecklistSection = {
        var clothesChecklist: ChecklistSection = ChecklistSection()
        var clothesChecklistElements = List<ChecklistElement>()
        clothesChecklistElements.append(objectsIn: [
            ChecklistElement(title: "T-Shirts", quantity: 2),
            ChecklistElement(title: "Dresses", quantity: 2),
            ChecklistElement(title: "Jeans", quantity: 1),
            ChecklistElement(title: "Shorts", quantity: 1),
            ChecklistElement(title: "Underwear", quantity: 4),
            ChecklistElement(title: "Sleepwear", quantity: 1),
            ChecklistElement(title: "Towel", quantity: 1),
            ChecklistElement(title: "Socks", quantity: 1),
            ChecklistElement(title: "Shoes", quantity: 1),
            ChecklistElement(title: "Slippers", quantity: 1),
            ChecklistElement(title: "Cap", quantity: 1)

        ])
        
        clothesChecklist.sectionHeader = "Clothes"
        clothesChecklist.sectionChecklist = clothesChecklistElements
        return clothesChecklist
    }()
    
    let electronicsChecklist: ChecklistSection = {
        var electronicsChecklist: ChecklistSection = ChecklistSection()
        var electronicsChecklistElements = List<ChecklistElement>()
        electronicsChecklistElements.append(objectsIn: [
            ChecklistElement(title: "Charger", quantity: 1),
            ChecklistElement(title: "Mobile Phone", quantity: 1),
        ])
        
        electronicsChecklist.sectionHeader = "Electronics"
        electronicsChecklist.sectionChecklist = electronicsChecklistElements
        return electronicsChecklist
    }()
}


