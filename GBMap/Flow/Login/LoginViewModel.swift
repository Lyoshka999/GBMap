//
//  LoginViewModel.swift
//  GBMap
//
//  Created by Алексей on 03.04.2023.
//

import UIKit

class LoginViewModel {
    var appCoordinator: AppCoordinator?
    
    func gotoTrackController() {
        appCoordinator?.goToTackView()
    }
    
    func gotoRegistrationController() {
        appCoordinator?.goToRegistrationView()
    }
    
}
