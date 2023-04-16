//
//  ProtocolCordinator.swift
//  GBMap
//
//  Created by Алексей on 03.04.2023.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    
    func start()
}
