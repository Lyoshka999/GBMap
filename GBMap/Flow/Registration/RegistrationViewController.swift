//
//  RegistrationViewController.swift
//  GBMap
//
//  Created by Алексей on 03.04.2023.
//

import UIKit
import RxSwift
import RxCocoa

class RegistrationViewController: UIViewController {

    var registrationViewModel: RegistrationViewModel?
    
    var onRegistration: ((_ login: String, _ password: String) -> Void)?
    
    let disposeBag = DisposeBag()
    let isPasswordView = BehaviorRelay<Bool>(value: true)
    
    let isPasswordNumber = BehaviorRelay<Bool>(value: false)
    let isPasswordLowercase = BehaviorRelay<Bool>(value: false)
    let isPasswordUppercase = BehaviorRelay<Bool>(value: false)
    let isPasswordSymbol = BehaviorRelay<Bool>(value: false)
    
    @IBOutlet weak var isNumberLabel: UILabel!
    @IBOutlet weak var isLowercaseLabel: UILabel!
    @IBOutlet weak var isUppercaseLabel: UILabel!
    @IBOutlet weak var isSymbolLabel: UILabel!
    
    @IBOutlet weak var passwordViewButton: UIButton!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var registrationButton: UIButton!
    
    @IBAction func didRegistration(_ sender: Any) {
        guard
            let login = usernameField.text,
            let password = passwordField.text
        else { return}

        onRegistration?(login, password)
        clearFields()
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            self.navigationController?.popViewController(animated: false)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Жест нажатия
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // Присваиваем его UIScrollVIew
        scrollView?.addGestureRecognizer(hideKeyboardGesture)
        
        passwordViewButtonTap()
        passwordViewSecureTextEntry()
        
        checkPasswordInput()
        checkRegistrationButton()
        
    }
    
    func clearFields() {
        usernameField.text = String()
        passwordField.text = String()
        
    }


}

extension RegistrationViewController {
    
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


extension RegistrationViewController {
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
    
    func checkPasswordInput() {
        passwordField.rx.text
            .asObservable()
            .bind(onNext: { val in
                guard let val = val else {return}
                
                    self.isPasswordNumber.accept(false)
                    self.isPasswordLowercase.accept(false)
                    self.isPasswordUppercase.accept(false)
                    self.isPasswordSymbol.accept(false)
                
                    val.forEach { char in
                        if (char.isNumber) { self.isPasswordNumber.accept(true) }
                        if (char.isLowercase) { self.isPasswordLowercase.accept(true) }
                        if (char.isUppercase) { self.isPasswordUppercase.accept(true) }
                        if (["!","#","$","*","(",")","-","=","_","+",".",","].contains(char) ) { self.isPasswordSymbol.accept(true) }
                    }

            })
                
            .disposed(by: disposeBag)
        
        
        isPasswordNumber
            .asObservable()
            .bind(onNext: {[ weak isNumberLabel]  (bool) in isNumberLabel?.isEnabled = !bool} )
            .disposed(by: disposeBag)
        
        isPasswordLowercase
            .asObservable()
            .bind(onNext: {[ weak isLowercaseLabel]  (bool) in isLowercaseLabel?.isEnabled = !bool} )
            .disposed(by: disposeBag)
        
        isPasswordUppercase
            .asObservable()
            .bind(onNext: {[ weak isUppercaseLabel]  (bool) in isUppercaseLabel?.isEnabled = !bool} )
            .disposed(by: disposeBag)
        
        isPasswordSymbol
            .asObservable()
            .bind(onNext: {[ weak isSymbolLabel]  (bool) in isSymbolLabel?.isEnabled = !bool} )
            .disposed(by: disposeBag)
        
    }
    
    func checkRegistrationButton() {
        
        let isUsername = usernameField.rx.text
            .orEmpty
            .map {$0.count > 0}
        
       
        Observable
            .combineLatest(isPasswordNumber,
                           isPasswordLowercase,
                           isPasswordUppercase,
                           isPasswordSymbol,
                           isUsername
            ) { $0 && $1 && $2 && $3 && $4}
            .bind { [weak registrationButton] (bool) in
                registrationButton?.isEnabled = bool
            }
            .disposed(by: disposeBag)
        
    }
    
}

