//
//  ConfirmSmsController.swift
//  Dalagram
//
//  Created by Toremurat on 18.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import InputMask
import RxSwift

class ConfirmController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Variables
    
    var viewModel: AuthViewModel!
    var disposeBag = DisposeBag()
    var maskDelegate: MaskedTextFieldDelegate? = nil
    
    var timer: Timer = Timer()
    lazy var seconds: TimeInterval = 120.0 // 2 minutes
    
    // MARK: - Initializer
    
    static func instantiate() -> ConfirmController {
        return UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "ConfirmController") as! ConfirmController
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Подтверждение"
        configureUI()
        setupTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        setEmptyBackTitle()
        maskDelegate = MaskedTextFieldDelegate(format: "[000000]")
        maskDelegate?.listener = self
        codeField.delegate = maskDelegate
        codeField.placeholder = "000000"
        codeField.becomeFirstResponder()
    }
    
    // MARK: - Setup Timer
    
    func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] (time) in
            self.seconds = self.seconds - time.timeInterval
            let minutes = Int(self.seconds)/60 % 60
            let seconds = Int(self.seconds) % 60
            self.timeLabel.text = "0\(minutes):\(String(format: "%02d", seconds))"
            if minutes == 0 && seconds == 0 {
                self.timer.invalidate()
                self.popController()
            }
        })
    }
    
    func popController() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: CodeField Listener

extension ConfirmController: MaskedTextFieldDelegateListener {
    
    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        if value.count == 6 {
            viewModel.confirmAccount(smsCode: value, {
                if self.viewModel.isNewUser.value {
                    let vc = CredentialsController.fromStoryboard(name: "Auth", bundle: nil)
                    self.show(vc, sender: nil)
                } else {
                    AppDelegate.shared().configureRootController(isLogged: true)
                }
            })
        }
    }
    
}
