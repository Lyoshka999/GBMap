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


class User: Object {
    @objc dynamic var login: String = String()
    @objc dynamic var password: String = String()
    
    override static func primaryKey() -> String? {
        return "login"
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
            print("􀘰􀘰􀘰 Realm saveItems error: \(error)")
        }
    }
    
    
    func deleteAllItems() {
        do {
            let realm = try Realm()
            
            let ret = realm.objects(CoordinateRealm.self)
            try! realm.write {
                realm.delete(ret)
            }
            
        } catch {
            print("Realm deleteAllItems  error: \(error)")
        }
    }
    
    
    func readItems() -> [CoordinateRealm] {
        var ret = [CoordinateRealm]()
        
        do {
            let realm = try Realm()
            
            ret = Array(realm.objects(CoordinateRealm.self))
 
        } catch {
            print("Realm readItems error: \(error)")
        }
        
        return ret
    }
    
    
    func checkLogin(login: String) -> Bool {
        var ret = false
        
        do {
            let realm = try Realm()
            
            ret = !realm.objects(User.self).filter("login == %@", login).isEmpty
        } catch {
            print("Realm checkLogin error: \(error)")
        }
        return ret
    }
    
    
    func registrationUser(login: String, password: String) {
        let user = User()
        user.login = login
        user.password = password

        do {
            let realm = try Realm()
            
            try! realm.write {
                realm.add(user)
                print("add",user)
            }
            
        } catch {
            print("Realm registrationUser error: \(error)")
        }
    }
    
    
    func replacePassword(login: String, password: String) {
        do {
            let realm = try Realm()

            let user = realm.objects(User.self).filter("login == %@", login)
            try! realm.write {
                user.setValue(password, forKey: "password")
            }
               
        } catch {
            print("Realm replacePassword error: \(error)")
        }
    }
    
    
    func loginUser(login: String, password: String) -> Bool {
        var ret = false
        do {
            let realm = try Realm()

            ret = !realm.objects(User.self).filter("login == %@ AND password == %@", login, password).isEmpty
 
        } catch {
            print("Realm replacePassword error: \(error)")
        }
        return ret
    }
    
}
