//
//  AuthViewModel.swift
//  Dalagram
//
//  Created by Toremurat on 06.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SwiftyJSON
import Whisper

struct AuthViewModel {
    
    var phone       = Variable<String>("")
    var isNewUser   = Variable<Bool>(false)
    
    // MARK: SignIn Route
    
    func attempSignIn(_ callback: @escaping (Bool) -> Void) {
        let phoneNum = removeWhiteSpaces(phone.value)
        NetworkManager.makeRequest(.signIn(phone: phoneNum), success: { (json) in
            if let message = json["message"].string {
                WhisperHelper.showSuccessMurmur(title: message)
            }
            callback(json["is_new_user"].boolValue)
        })
    }
    
    // MARK: Confirm Account Route
    
    func confirmAccount(smsCode: String, _ callback: @escaping () -> Void) {
        let phoneNum = removeWhiteSpaces(phone.value)
        NetworkManager.makeRequest(.confirmAccount(phone: phoneNum, code: smsCode), success: { (json) in
            print(json["data"])
            User.initWith(json: json["data"])
            callback()
        })
    }
    
    // MARK: Other Helpers
    
    func removeWhiteSpaces(_ text: String) -> String {
        return text.components(separatedBy: .whitespaces).joined()
    }
    
    
}
