//
//  LoginViewController.swift
//  GBMap
//
//  Created by Алексей on 03.04.2023.
//

import UIKit
import Combine
import RealmSwift

class LoginViewController: UIViewController {

    var loginViewModel: LoginViewModel?

    var onLogin: ((_ login: String, _ passord: String) -> Bool)?
    
    var cancellable = Set<AnyCancellable>()
    let userNamePublisher = PassthroughSubject<String, Never>()
      
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var gotoTrackButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBAction func didGotoTrack(_ sender: UIButton) {
        guard
            let login = userNameField.text,
            let password = passwordField.text,
            onLogin?(login, password) == true
        else {
            MesssageView.instance.alertMain(view: self, title: "Attention", message: "login, password не верны!" )
            return
        }
        
        clearFields()
        loginViewModel?.gotoTrackController()
    }
    
    @IBAction func didRegistrationTouch(_ sender: UIButton) {
        loginViewModel?.gotoRegistrationController()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("􀘰􀘰 realm = \n", Realm.Configuration.defaultConfiguration.fileURL!, "\n 􀘰􀘰")
        
        // Жест нажатия
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // Присваиваем его UIScrollVIew
        scrollView?.addGestureRecognizer(hideKeyboardGesture)

        

     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Подписываемся на два уведомления: одно приходит при появлении клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        // Второе — когда она пропадает
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }


    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }

    
    func checkInputLogin(login: String, password: String) -> Bool {
        enum Constants {
            static let login = "admin"
            static let password = "123456"
        }
        
       return login == Constants.login && password == Constants.password

    }
    
    func clearFields() {
        userNameField.text = String()
        passwordField.text = String()
        
    }

}

extension LoginViewController {
    
    // Когда клавиатура появляется
     @objc func keyboardWasShown(notification: Notification) {

         // Получаем размер клавиатуры
         let info = notification.userInfo! as NSDictionary
         let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
         let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)

         // Добавляем отступ внизу UIScrollView, равный размеру клавиатуры
         self.scrollView?.contentInset = contentInsets
         scrollView?.scrollIndicatorInsets = contentInsets
     }

     //Когда клавиатура исчезает
     @objc func keyboardWillBeHidden(notification: Notification) {
         // Устанавливаем отступ внизу UIScrollView, равный 0
         let contentInsets = UIEdgeInsets.zero
         scrollView?.contentInset = contentInsets
     }

    
    @objc func hideKeyboard() {
            self.scrollView?.endEditing(true)
        }
    
}

