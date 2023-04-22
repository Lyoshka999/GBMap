//
//  TrackViewController.swift
//  GBMap
//
//  Created by Алексей on 27.03.2023.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift
import RxCocoa
import RxSwift

class TrackViewController: UIViewController {
    
    var trackviewModel: TrackViewModel?
    
    var coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
   
    let locationManager = LocationManager.instance
    
    let disposeBag = DisposeBag()
    
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var photoMarker = [GMSMarker?]()
    
    var route = GMSPolyline()
    var routePath = GMSMutablePath()
    
    let distantionRealy = BehaviorSubject<Double>(value: 0.0)
    
    let isTracking  = BehaviorRelay<Bool>(value: false)

    @IBAction func takePicture(_ sender: UIButton) {
        // Проверка, поддерживает ли устройство камеру
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        // Создаём контроллер и настраиваем его
        let imagePickerController = UIImagePickerController()
        // Источник изображений: камера
        imagePickerController.sourceType = .camera
        // Изображение можно редактировать
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        // Показываем контроллер
        present(imagePickerController, animated: true)
    
    }
    
    @IBOutlet weak var ledTrack: UIImageView!
    
    @IBOutlet weak var distantionLabek: UILabel!

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func didTapEndTrackButton(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        if routePath.count() > 0 {
            ViewModel.instance.deleteAllRealm()
            ViewModel.instance.saveAllRealm(routePath: routePath)
            ViewModel.instance.saveMarkerRealm(marker: photoMarker)
            removePictureMarker()
            initTrack()
            isTracking.accept( false )
        }

    }
    
    @IBAction func didTapNewTrackButton(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        ViewModel.instance.deleteAllRealm()
        initTrack()
        isTracking.accept( true )
    }
    
    @IBAction func didTapViewTrackButton(_ sender: UIButton) {
        if isTracking.value {
            MesssageView.instance.alertMain(view: self, title: "Attention", message: "Остановлена запись трека!")
            locationManager.stopUpdatingLocation()
            isTracking.accept( false )
        }
        viewPhotoMarker()
        viewTrack()
        viewAllTrack(routePath: ViewModel.instance.readAllRealm())
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ViewModel.instance.deleteAllRealm()
        
        configureMap()
        configureLocationManager()
        
        subscriptionLocationManager()

        isTrackingObservable()
        
        setDistantionRelay()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.settings.zoomGestures = true
    }
    
    
    
    func initTrack() {
        // Отвязываем от карты старую линию
        route.map = nil
        // Заменяем старую линию новой
        route = GMSPolyline()
        // Заменяем старый путь новым, пока пустым (без точек)
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту
        distantionRealy.onNext(-1)
    }
    

    
    func addMarker(newCoordinate: CLLocationCoordinate2D) {
        marker = GMSMarker(position: newCoordinate)
        
        marker?.icon = UIImage.init(systemName: "figure.wave")
        marker?.map = mapView

    }
    
    func addPictureMarker(image: UIImage) {
       
        guard let position = marker?.position,
              let frameImage = UIImage(named: "picPointbl")
        else {return}
        
        photoMarker.append(GMSMarker(position: position))
        guard let last = photoMarker.last else {return}
        
        let imageView = drawImageToframeImage(image: image, frameImage: frameImage)
        
        last?.icon = imageView
        last?.map = mapView
    }
    
    func removePictureMarker() {
        photoMarker.forEach({ body in
            body?.map = nil
        })
        photoMarker.removeAll()
    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    
    func viewPhotoMarker() {
        removePictureMarker()
        
        photoMarker = ViewModel.instance.readMarkerRealm()
        photoMarker.forEach { val in
            let img = val?.icon?.imageResized(to: CGSize(width: 45, height: 57))
            val?.icon = img
            val?.map = mapView
        }
        
    }
    
    func viewAllTrack(routePath: GMSMutablePath) {
        var bounds = GMSCoordinateBounds()
        for i in 0..<routePath.count() {
            self.routePath.add(routePath.coordinate(at: i))
            self.route.path = routePath
            bounds = bounds.includingCoordinate(routePath.coordinate(at: i))
            viewTrack()
        }

        mapView.moveCamera(GMSCameraUpdate.fit(bounds))
    }
    
    func viewTrack() {
        route.strokeColor = .red
        route.strokeWidth = 3.0
        route.geodesic = true
        route.map = mapView
        
        let pathLen = GMSGeometryLength(routePath)
        distantionRealy
            .asObserver()
            .onNext(round(pathLen))
 
    }
    
    func configureMap() {
        mapView.delegate = self
    }
    
    
    
    func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] (location) in
                guard let location = location else { return }
                self?.routePath.add(location.coordinate)
                self?.route.path = self?.routePath
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
                self?.removeMarker()
                self?.addMarker(newCoordinate: location.coordinate)
                self?.viewTrack()
            }
            .disposed(by: disposeBag)
    }
    
    
    func subscriptionLocationManager() {
        locationManager
            .location
            .subscribe { (event) in print("location=", event) }
            .disposed(by: disposeBag)
    }
    
}

extension TrackViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let manualMarker  = GMSMarker(position: coordinate)
            manualMarker.map = mapView
        }
    }
}

extension TrackViewController {
    func isTrackingObservable() {
        isTracking
            .asObservable()
            .bind { [weak self] (bool) in
                guard let self = self else { return }
                if bool {
                    self.ledTrack.image = UIImage(systemName: "xmark.circle.fill")
                    self.ledTrack.tintColor = .red
                } else {
                    self.ledTrack.image = UIImage(systemName: "checkmark.circle.fill")
                    self.ledTrack.tintColor = .blue
                }
            }
            .disposed(by: disposeBag)
    }
    
    func setDistantionRelay() {
        distantionRealy
            .asObservable()
        
            .scan(0.0) { val1, val2 in
                if val2 == -1 { return 0 }
                else {return val1 + val2}
            }
            .bind(onNext: { self.distantionLabek.text = "Растояние: \($0) м"})
            .disposed(by: disposeBag)
    }
    
}

extension TrackViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Если нажали на кнопку Отмена, то UIImagePickerController надо закрыть
        picker.dismiss(animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Закрываем UIImagePickerController
        picker.dismiss(animated: true) { [weak self] in
            // После того, как он закроется, извлечём изображение
            guard let image = self?.extractImage(from: info) else { return }
            // Если оно будет извлечено, выполним действие на его получение
            
            self?.addPictureMarker(image: image)
            
        }
    }
    
    // Метод, извлекающий изображение
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        // Пытаемся извлечь отредактированное изображение
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            return image
        // Пытаемся извлечь оригинальное
        } else
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                return image
            } else { return nil }
    }
    
}
