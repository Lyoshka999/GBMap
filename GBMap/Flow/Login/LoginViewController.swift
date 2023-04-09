//
//  LoginViewController.swift
//  GBMap
//
//  Created by Алексей on 03.04.2023.
//

import UIKit
import Combine
import RealmSwift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {

    var autoCompletionPossibilities = [ "mail.ru", "yandex.ru", "google.com" ]

    var loginViewModel: LoginViewModel?

    var onLogin: ((_ login: String, _ passord: String) -> Bool)?

    let disposeBag = DisposeBag()
    var passwordPublisher = PublishSubject<Bool>()
    var userNamePublisher = PublishSubject<Bool>()
    
    let isPasswordView  = BehaviorRelay<Bool>(value: true)
    
    @IBOutlet weak var passwordViewButton: UIButton!
    @IBAction func didPasswordView(_ sender: UIButton) {
        
    }
    
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var gotoTrackButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func didUserNameField(_ sender: UITextField) {

    }
    
    @IBAction func didGotoTrack(_ sender: UIButton) {
        guard
            let login = userNameField.text,
            let password = passwordField.text,
            onLogin?(login, password) == true
                
        else {
            MesssageView.instance.alertMain(view: self, title: "Attention", message: "\n login, password не верны!" )
            return
        }
        
        guard
            Reachability.instance.isConnectedToNetwork()
        else {
            MesssageView.instance.alertMain(view: self, title: "Attention", message: "\n Ошибка подключения к интернету!" )
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
        
        checkLogin()
                
        passwordViewButtonTap()
        passwordViewSecureTextEntry()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        gotoTrackButton.isEnabled = false
        
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
    @objc private func keyboardWillBeHidden(notification: Notification) {
         // Устанавливаем отступ внизу UIScrollView, равный 0
        let contentInsets = UIEdgeInsets.zero
        scrollView?.contentInset = contentInsets
     }
    
    @objc private func hideKeyboard() {
        self.scrollView?.endEditing(true)
    }
    
}

extension LoginViewController {

    func checkLogin() {

        let userNamePublisher = userNameField.rx.text
            .orEmpty
            .map {$0.count > 0}

        let passwordPublisher = passwordField.rx.text
            .orEmpty
            .map {$0.count > 0}
        
        Observable
            .combineLatest(userNamePublisher, passwordPublisher) { $0 && $1 }
            .bind { [weak gotoTrackButton] (bool) in
                gotoTrackButton?.isEnabled = bool
            }
            .disposed(by: disposeBag)

    }

}

extension LoginViewController {
    func passwordViewButtonTap() {
        passwordViewButton.rx.tap
            .map{self.isPasswordView.value}
            .bind(onNext: { [weak isPasswordView] (bool) in
                isPasswordView?.accept(!bool)
            } )
            .disposed(by: disposeBag)
    }
    
    
    func passwordViewSecureTextEntry() {
        enum nameImages: String {
            case open = "eye.fill"
            case close = "eye.slash.fill"
        }
        
        isPasswordView
            .asObservable()
            .bind(onNext: { [weak passwordField] (bool) in
                passwordField?.isSecureTextEntry = bool
                
                let smallSizeImage = UIImage.SymbolConfiguration(scale: .small)
                var nameImage = nameImages.open
                if bool { nameImage = nameImages.close }
                self.passwordViewButton.setImage(UIImage(systemName: nameImage.rawValue, withConfiguration: smallSizeImage), for: .normal)
            } )
            .disposed(by: disposeBag)
    }
    
    
    
}
