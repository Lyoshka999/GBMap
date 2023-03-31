//
//  Realm.swift
//  GBMap
//
//  Created by Алексей on 31.03.2023.
//

import UIKit
import RealmSwift

class CoordinateRealm: Object {
    @objc dynamic var uid: Int = 0
    @objc dynamic var latitude: Double  = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "uid"
    }
    
}

class RealmWork {
    static let instance = RealmWork()
    private init(){}
    
    static var configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    
    func saveItems(coordinates: CoordinateRealm ) {
        do {
            let realm = try Realm()
            
            try! realm.write {
                realm.add(coordinates)
            }
            
        } catch {
            print("Realm saveItems error: \(error)")
        }
    }
    
    
    func deleteAllItems() {
        do {
            let realm = try Realm()
            
            try! realm.write {
                realm.deleteAll()
            }
            
        } catch {
            print("Realm deleteAllItems  error: \(error)")
        }
    }
    
    func readItems() -> [CoordinateRealm] {
        var right = [CoordinateRealm]()
        
        do {
            let realm = try Realm()
            
            right = Array(realm.objects(CoordinateRealm.self))
 
        } catch {
            print("Realm readItems error: \(error)")
        }
        
        return right
    }
    
}
