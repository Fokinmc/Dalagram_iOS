//
//  FillCredentialsController.swift
//  Dalagram
//
//  Created by Toremurat on 07.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class CredentialsController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    
    lazy var nextBarButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(saveButtonPressed(_:)))
        item.tintColor = UIColor.darkBlueNavColor
        return item
    }()
    
    // MARK: - Variables
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        configureUI()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        self.title = "Регистрация"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Keyboard Will Show
    
    @objc func keyboardWillShow() {
        self.navigationItem.rightBarButtonItem = nextBarButton
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.alpha = 0.0
        })
    }
    
    // MARK: - Keyboard Will Show
    
    @objc func keyboardWillHide() {
        self.navigationItem.rightBarButtonItem = nil
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.alpha = 1.0
        })
    }

    
    // MARK: - Save Button Action
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let email = emailField.text, !email.isEmpty, let pass = passField.text, !pass.isEmpty, let confirmPass = confirmPassField.text, !confirmPass.isEmpty else {
            WhisperHelper.showErrorMurmur(title: "Заполните все поля")
            return
        }
        let params = ["email": email, "password": pass, "confirm_password": confirmPass]
        NetworkManager.makeRequest(.updateProfile(params), success: { (json) in
            WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
            AppDelegate.shared().configureRootController(isLogged: true)
        })
        
    }
}
