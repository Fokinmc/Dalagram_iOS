//
//  SingInController.swift
//  Dalagram
//
//  Created by Toremurat on 18.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import InputMask
import RxSwift
import RxCocoa
import DropDown

class SignInController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    // MARK: - Variables
    
    var viewModel = AuthViewModel()
    var maskDelegate: MaskedTextFieldDelegate? = nil
    var disBag = DisposeBag()
    let dropDown = DropDown()
    
    // MARK: - Initializer
    
    static func instantiate() -> SignInController {
        return SignInController.fromStoryboard(name: "Auth", bundle: nil)
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Регистрация"
        configureUI()
        phoneField.rx.text.orEmpty.bind(to: viewModel.phone).disposed(by: disBag)
        setBlueNavBar()
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
        
        // DropDown for CountyField
        countryField.allowsEditingTextAttributes = false
        countryField.addTarget(self, action: #selector(openDropDown), for: UIControlEvents.touchDown)
        dropDown.anchorView = countryField
        dropDown.dataSource = ["+7 Kazakhstan", "+9 Russia", "+8 Kyrgyzstan", "+1 United States", "+998 Uzbekistan"]
        dropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            self.countryField.text = item
        }
    }
    
    @objc func openDropDown() {
        dropDown.show()
    }
    
}

// MARK: - PhoeField Listener

extension SignInController: MaskedTextFieldDelegateListener {
    
    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        if value.count == 12 {
            alert(title: "Подтверждение телефона",
                message: "Убедитесь что правильно ввели Ваш номер \(value)",
                cancelButton: "Отмена",
                actionButton: "Подтвердить", handler: { [unowned self] () -> (Void) in
                self.viewModel.attempSignIn({ [unowned self] (value) in
                    self.showNextController(isNewUser: value)
                })
            })
        }
    }

    func showNextController(isNewUser: Bool) {
        let vc = ConfirmController.instantiate()
        viewModel.isNewUser.value = isNewUser
        vc.viewModel = viewModel
        self.show(vc, sender: nil)
    }

}
