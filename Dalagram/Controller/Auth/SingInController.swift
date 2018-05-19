//
//  SingInController.swift
//  Dalagram
//
//  Created by Toremurat on 18.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import InputMask

class SignInController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    // MARK: - Variables
    
    var maskDelegate: MaskedTextFieldDelegate? = nil
    
    // MARK: - Initializer
    
    static func instantiate() -> SignInController {
        return UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "SignInController") as! SignInController
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Регистрация"
        configureUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        setEmptyBackTitle()
        phoneField.keyboardType = .phonePad
        phoneField.returnKeyType = .next
        phoneField.becomeFirstResponder()
        
        // InputMask for PhoneField
        maskDelegate = MaskedTextFieldDelegate(format: "{+7} ([000]) [000] [00] [00]")
        maskDelegate?.put(text: "+7 ", into: phoneField)
        maskDelegate?.listener = self
        phoneField.delegate = maskDelegate
    }
    
    
}

// MARK: - PhoeField Listener

extension SignInController: MaskedTextFieldDelegateListener {
    
    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        if value.count == 12 {
            showConfirmAlert(phone: value)
        }
    }
    
    func showConfirmAlert(phone: String) {
        alert(title: "Подтверждение телефона", message: "Убедитесь что правильно ввели Ваш номер \(phone)", cancelButton: "Отмена", actionButton: "Подтвердить", handler: { () -> (Void) in
            let vc = ConfirmController.instantiate()
            self.show(vc, sender: nil)
        }, cancelHandler: nil)
    }
    
}
