//
//  AppCoordinator.swift
//  GBMap
//
//  Created by Алексей on 03.04.2023.
//

import UIKit
import SwiftUI

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        goToLoginView()
    }
    
    var stroryboard = UIStoryboard(name: "Main", bundle: .main)
    
    func goToTackView() {
        guard let controller = stroryboard.instantiateViewController(withIdentifier: "TrackViewController") as? TrackViewController else { return }

        let viewModel = TrackViewModel()
        viewModel.appCoordinator = self

        controller.trackviewModel = viewModel
        navigationController.pushViewController(controller, animated: true)
    }
    
    func goToLoginView() {
        guard let controller = stroryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
        
       controller.onLogin = { [weak self] (login, password) in
            ViewModel.instance.loginUser(login: login, password: password)
        }
        
        let viewModel = LoginViewModel()
        viewModel.appCoordinator = self
        
        controller.loginViewModel = viewModel
        navigationController.pushViewController(controller, animated: true)

    }
   
    func goToRegistrationView() {
        guard let controller = stroryboard.instantiateViewController(withIdentifier: "RegistrationViewController") as? RegistrationViewController else { return }
        
        
        controller.onRegistration = { [weak self] (login, password) in
            ViewModel.instance.registrationUser(login: login, password: password)
        }
        
        
        let viewModel = RegistrationViewModel()
        viewModel.appCoordinator = self
        
        controller.registrationViewModel = viewModel
        navigationController.pushViewController(controller, animated: true)

    }
    
}
