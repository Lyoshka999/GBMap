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
    
}
