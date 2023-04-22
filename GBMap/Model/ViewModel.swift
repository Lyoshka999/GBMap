//
//  ViewModel.swift
//  GBMap
//
//  Created by Алексей on 31.03.2023.
//

import UIKit
import GoogleMaps

class ViewModel {
    
    static let instance = ViewModel()
    private init(){}
    
    func saveMarkerRealm(marker: [GMSMarker?]) {
        var markerRealm = [MarkerRealm]()
        var index = 0
        marker.forEach{ val in
            guard let val = val else {return}
            let mark = MarkerRealm()
            mark.uid = index
            mark.latitude = val.position.latitude
            mark.longitude = val.position.longitude
            let nameImage = "\(index)"
            mark.image = nameImage
            DiskWork().saveImageToDisk(imageName: nameImage, image: val.icon ?? UIImage())
            markerRealm.append(mark)
            index = index + 1
        }
        
        RealmWork.instance.saveMarkerRealm(marker: markerRealm)
    }
    
    func readMarkerRealm() -> [GMSMarker?] {
        var markerRealm = [GMSMarker?]()
        let marker = RealmWork.instance.readMarkerRealm()
        var index = 0
        marker.forEach { val in
            let mark = GMSMarker()
            mark.position.latitude = val.latitude
            mark.position.longitude = val.longitude
            mark.icon = DiskWork().loadImageFromDisk(fileName: "\(index)" )
            markerRealm.append(mark)
            index = index + 1
        }
        
        return markerRealm
    }
    
    
    func saveRealm(count: UInt, coordinate: CLLocationCoordinate2D) {
        let coordinateRealm =  CoordinateRealm()
        coordinateRealm.uid = Int(count)
        coordinateRealm.latitude = coordinate.latitude
        coordinateRealm.longitude = coordinate.longitude
        
        RealmWork.instance.saveItems(coordinates: coordinateRealm)
    }
    
    func saveAllRealm(routePath: GMSMutablePath) {
        for i in 0..<routePath.count() {
            saveRealm(count: i, coordinate: routePath.coordinate(at: i))
        }
        
    }
    
    func deleteAllRealm() {
        RealmWork.instance.deleteAllItems()
    }
    
    func readAllRealm() -> GMSMutablePath {
        let routePath = GMSMutablePath()
        let coord = RealmWork.instance.readItems()
        
            coord.forEach { coordinateRealm in
                routePath.add(CLLocationCoordinate2DMake(coordinateRealm.latitude, coordinateRealm.longitude))
            }
        return routePath
    }

    
    func registrationUser(login: String, password: String) {
        if RealmWork.instance.checkLogin(login: login) {
            RealmWork.instance.replacePassword(login: login, password: password)
        } else {
            RealmWork.instance.registrationUser(login: login, password: password)
        }
            
    }
    
    
    
    func loginUser(login: String, password: String) -> Bool {
        RealmWork.instance.loginUser(login: login, password: password)
    }
    
}

