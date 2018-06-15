//
//  ChatViewModel.swift
//  Dalagram
//
//  Created by Toremurat on 01.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ChatViewModel {
    
    var messages: [Messages] = []
    
    // MARK: - Send Message
    func sendMessage(success: @escaping()-> Void, params: [String : String]) {
        NetworkManager.makeRequest(.sendMessage(params), success: { (json) in
            print(json)
            success()
        })
    }
    
    
    
    
}
