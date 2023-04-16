//
//  LocationManager.swift
//  GBMap
//
//  Created by Алексей on 09.04.2023.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa


final class LocationManager: NSObject {
    static let instance = LocationManager()
    
    private override init() {
        super.init()
        configureLocationManager()
    }
    
    let locationManager = CLLocationManager()
    
    let location = BehaviorRelay<CLLocation?>(value: nil)
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }


    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.activityType = .automotiveNavigation

        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()

    }
    
}


extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location.accept( locations.last )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

