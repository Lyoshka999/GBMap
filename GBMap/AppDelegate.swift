//
//  AppDelegate.swift
//  GBMap
//
//  Created by Алексей on 27.03.2023.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? {
      didSet {
        window?.overrideUserInterfaceStyle = .light
      }
    }
    var appCoordinate: AppCoordinator?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        GMSServices.provideAPIKey("HGHgHJGhjGhjGhjGHJgHJGjhGjhGjGJgJg")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        appCoordinate = AppCoordinator(navigationController: navigationController)
        appCoordinate?.start()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }


}

