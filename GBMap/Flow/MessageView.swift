//
//  MessageView.swift
//  GBMap
//
//  Created by Алексей on 31.03.2023.
//

import UIKit

class MesssageView: NSObject {
    static let instance = MesssageView()

    func alertMain(view: UIViewController, title: String, message: String = "Ошибка!") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButton)

        view.present(alert, animated: true)
     }
    
    func goSettings(view: UIViewController) {
        let alertController = UIAlertController (title: "Notification",
                                                 message: "для получения уведомлений \n перейдите в настройки",
                                                 preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Настройки", style: .default, handler: { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
               UIApplication.shared.open(settingsUrl)
             }
        })
        
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alertController.addAction(cancelAction)

        view.present(alertController, animated: true, completion: nil)
    }
    
}
