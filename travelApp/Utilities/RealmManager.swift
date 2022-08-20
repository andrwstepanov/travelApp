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
    func addTrip(trip: TripModel) {
        self.addObject(object: trip, update: false)
    }
    func changeTripChecklist(trip: TripModel, checklist: ChecklistSection) {
        do {
            try self.getRealm().write {
                trip.checklist.append(objectsIn: [checklist])
            }
        } catch {
            print("Realm error: Cannot write: \(trip)")
        }
    }
    func updateChecklistItem(trip: TripModel, indexPath: IndexPath, checklistItem: ChecklistElement, newName: String, newQty: Int, newCat: ChecklistSection?) {
        let realm = getRealm()
        do {
            try realm.write {
                checklistItem.title = newName
                checklistItem.quantity = newQty
                if let safeNewCat = newCat {
                    trip.checklist[indexPath.section].sectionChecklist.remove(at: indexPath.row)
                    safeNewCat.sectionChecklist.append(checklistItem)
                }
            }
        } catch {
            print("Error deleting objects")
        }
    }
    func deleteTrip(trip: TripModel) {
        self.deleteObject(object: trip)
    }
    func deleteItem(trip: TripModel, indexPath: IndexPath) {
        let itemReference = trip.checklist[indexPath.section].sectionChecklist[indexPath.row]
        deleteObject(object: itemReference)
    }
    func addItemToCategory(name: String, qty: Int, cat: ChecklistSection) {
        let realm = getRealm()
        do {
            try realm.write {
                cat.sectionChecklist.append(ChecklistElement(title: name, quantity: qty))
            }
        } catch {
            print("Error updating objects")
        }
    }
    func toggleChecklistItem(trip: TripModel, index: IndexPath) {
        let realm = getRealm()
        do {
            try realm.write {
                trip.checklist[index.section].sectionChecklist[index.row].isDone.toggle()
            }
        } catch {
            print("Error deleting objects")
        }
    }
    func getTrips() -> Results<TripModel> {
        let results: Results<TripModel> = self.getRealm().objects(TripModel.self)
        return results
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
            print("Error deleting objects")
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
}
