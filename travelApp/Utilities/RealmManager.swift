//
//  RealmManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 11.06.2022.
//

import Foundation
import RealmSwift

class RealmManager {
    static let sharedInstance = RealmManager()
    static var realmConfig = Realm.Configuration()
    init() {
        RealmManager.realmConfig.deleteRealmIfMigrationNeeded = true
        if Config.resetApp { deleteAll() }
    }
    static func sharedDelegate() -> RealmManager {
        return self.sharedInstance
    }
    func getTrips() -> Results<TripModel> {
        let results: Results<TripModel> = self.getRealm().objects(TripModel.self)
        return results
    }
    func writeTrip(trip: TripModel, delete: Bool = false) {
        if !delete {
            addObject(object: trip, update: false)
        } else {
            deleteObject(object: trip)
        }
    }
    func writeSection(trip: TripModel, section: ChecklistSection, delete: Bool = false) {
        if !delete {
            addObject(object: section, update: false)
            makeReference(from: trip.checklist, to: section)
        } else {
            deleteObject(object: section)
        }
    }
    func writeItem(checklist: ChecklistSection, item: ChecklistElement, delete: Bool = false) {
        if !delete {
            addObject(object: item, update: false)
            makeReference(from: checklist.sectionChecklist, to: item)
        } else {
            deleteObject(object: item)
        }
    }
    func updateItem(checklistItem: ChecklistElement, newName: String, newQty: Int) {
        let realm = getRealm()
        do {
            try realm.write {
                checklistItem.title = newName
                checklistItem.quantity = newQty
            }
        } catch {
            print("Error updating checklist objects \(checklistItem)")
        }
    }
    func moveItemToCategoryIfNeeded(item: ChecklistElement, newCat: ChecklistSection, currentCat: ChecklistSection) {
        let realm = getRealm()
        if newCat.sectionChecklist.contains(item) { return }
        guard let index = currentCat.sectionChecklist.firstIndex(of: item) else { return }
        do {
            try realm.write {
                currentCat.sectionChecklist.remove(at: index)
                newCat.sectionChecklist.append(item)
            }
        } catch {
            print("Error updating objects")
        }
    }
    func toggleItem(trip: TripModel, index: IndexPath) {
        let realm = getRealm()
        do {
            try realm.write {
                trip.checklist[index.section].sectionChecklist[index.row].isDone.toggle()
            }
        } catch {
            print("Error toggling item")
        }
    }
    func getReference<T: Object>(id: String) -> T? {
        let realm = getRealm()
        if let ref = realm.object(ofType: T.self, forPrimaryKey: id) {
            return ref
        } else { return nil }
    }

    private func getRealm() -> Realm {
        return try! Realm(configuration: RealmManager.realmConfig)
    }
    private func deleteAll() {
        let realm = self.getRealm()
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Error deleting all objects")
        }
    }
    private func addObject(object: Object, update: Bool) {
        let realm = self.getRealm()
        do {
            try realm.write {
                realm.add(object, update: update ? .all : .modified)
            }
        } catch {
            print("Realm error: Cannot add object: \(object)")
        }
    }
    private func deleteObject(object: Object) {
        let realm = self.getRealm()
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Realm error: Cannot delete object: \(object)")
        }
    }
    private func makeReference<T>(from parent: List<T>, to object: T) {
        let realm = getRealm()
        do {
            try realm.write {
                parent.append(object)
            }
        } catch {
            print("Error updating objects")
        }
    }
}



