//
//  ViewController.swift
//  GBMap
//
//  Created by Алексей on 27.03.2023.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController {
    
    var coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var locationManager: CLLocationManager?
    var geoCoder: CLGeocoder?
    
    var bounds = GMSCoordinateBounds()
    
    var distantion = 0.0
    
    @IBOutlet weak var distantionLabek: UILabel!

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func didTapMEButton(_ sender: Any) {
        addMarker()
        mapView.animate(toLocation: coordinate)
        if marker == nil {
            addMarker()
            mapView.animate(toLocation: coordinate)
        } else {
            removeMarker()
        }
    }
    
    @IBAction func didTapLocationButton(_ sender: UIButton) {
        locationManager?.requestLocation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        
        configureMap()
        configureLacationManager()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.settings.zoomGestures = true
//        myAdd(newPoint: coordinate)
        addMarker()
    }
    
    func configureLacationManager(){
        locationManager = CLLocationManager()
        
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func addMarker() {
        marker = GMSMarker(position: coordinate)
        
        marker?.icon = UIImage.init(systemName: "car.fill")
//        marker?.icon = GMSMarker.markerImage(with: .red)
        marker?.map = mapView

    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    func configureMap() {
        let camera = GMSCameraPosition(target: coordinate, zoom: 15)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        mapView.delegate = self
    }
    
    func myAdd(newCoordinate: CLLocationCoordinate2D) {
        let path = GMSMutablePath()
        path.add(coordinate)
        path.add(newCoordinate)
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .red
        polyline.strokeWidth = 3.0
        polyline.geodesic = true
        polyline.map = mapView
        
        bounds = bounds.includingCoordinate(path.coordinate(at: 1))
        let pathLen = GMSGeometryLength(path)
        distantion = distantion + round(pathLen)
        
        distantionLabek.text = "Растояние: \(distantion) м"
//        self.mapView.moveCamera(GMSCameraUpdate.fit(bounds))
        print("distantion = \(distantion)км")
        
        coordinate = newCoordinate
    }
    
    
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("coordinate=",coordinate)
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let manualMarker  = GMSMarker(position: coordinate)
            manualMarker.map = mapView
        }
        myAdd(newCoordinate: coordinate)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        guard let location = locations.last else { return }
       
        if geoCoder == nil {
            geoCoder = CLGeocoder()
        }
        geoCoder?.reverseGeocodeLocation(location) { (places, error) in
            print(places?.first)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

