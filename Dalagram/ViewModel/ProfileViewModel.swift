//
//  ProfileViewModel.swift
//  Dalagram
//
//  Created by Toremurat on 07.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

struct ProfileViewModel {
    
    var name    = Variable<String>("")
    var phone   = Variable<String>("")
    var avatar  = Variable<String>("")
    var status  = Variable<String>("")
    var email   = Variable<String>("")
    
    var isNeedToUpdate = Variable<Bool>(false)
    
    func getProfile(onCompletion: @escaping () -> ()) {
        NetworkManager.makeRequest(.getProfile(user_id: nil), success: { (json) in
            let data = json["data"]
            self.name.value     = data["user_name"].stringValue
            self.avatar.value   = data["avatar"].stringValue
            self.phone.value    = data["phone"].stringValue
            self.status.value   = data["user_status"].stringValue
            self.email.value    = data["email"].stringValue
            onCompletion()
        })
    }
    
    func editProfile(_ onCompletion: @escaping () -> Void) {
        let params = ["user_status": status.value,
                      "user_name": name.value,
                      "email" : email.value]
        
        NetworkManager.makeRequest(.editProfile(params), success: { (json) in
            WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
            onCompletion()
        })
    }
    
}
