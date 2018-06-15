//
//  Messages.swift
//  Dalagram
//
//  Created by Toremurat on 29.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation

enum Messages {
    
    case textMessage
    case singlePhoto
    case audioMessage
    
    static let count = 3
    
    func controller() -> ViewController {
        return ViewController(model: self)
    }
    
    var title: String {
        switch self {
        case .textMessage: return "Text Messages"
        case .singlePhoto: return "Photos Collection"
        case .audioMessage: return "Audio Message"
        }
    }
}

struct ChatMessage {
    
    var user_id: Int
    var user_name: String
    var text: String
    
}

