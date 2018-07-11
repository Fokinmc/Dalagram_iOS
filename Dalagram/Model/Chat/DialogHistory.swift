//
//  DialogHistory.swift
//  Dalagram
//
//  Created by Toremurat on 19.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class DialogHistory: Object {
    
    @objc dynamic var id: String            = "" // foreign key (dialog_id)
    @objc dynamic var chat_id: Int          = 0
    @objc dynamic var chat_kind: String     = ""
    @objc dynamic var action_name: String   = ""
    @objc dynamic var answer_chat_id: Int   = 0
    @objc dynamic var chat_text: String     = ""
    @objc dynamic var chat_date: String     = ""
    
    @objc dynamic var sender_phone: String  = ""
    @objc dynamic var sender_avatar: String = ""
    @objc dynamic var sender_user_id: Int   = 0
    @objc dynamic var sender_name: String   = ""
    
    @objc dynamic var recipient_phone: String  = ""
    @objc dynamic var recipient_avatar: String = ""
    @objc dynamic var recipient_user_id: Int   = 0
    @objc dynamic var recipient_name: String   = ""
    
    // Create new message
    
    static func initWith(dialog_id: String, chat_text: String, sender_user_id: Int) {
        let realm = try! Realm()
        
        let item = DialogHistory()
        item.id = dialog_id
        item.chat_text = chat_text
        item.sender_user_id = sender_user_id
        
        try! realm.write {
            realm.add(item)
        }
        
    }
    
    // Synscronize and update from server
    static func initWith(json: JSON, dialog_id: String) {
        let realm = try! Realm()
        
        if let existingItem = getCurrentObject(chat_id: json["chat_id"].intValue) {
            // UPDATE
            try! realm.write {
                existingItem.action_name            = json["action_name"].stringValue
                existingItem.answer_chat_id         = json["answer_chat_id"].intValue
                existingItem.chat_text              = json["chat_text"].stringValue
                existingItem.chat_date              = json["chat_date"].stringValue
                existingItem.sender_name            = json["sender"]["user_name"].string ?? json["sender"]["contact_user_name"].string ?? json["sender"]["phone"].stringValue
            }
        } else {
            // CREATE
            let item = DialogHistory()
            
            item.id             = dialog_id
            item.chat_id        = json["chat_id"].intValue
            item.chat_kind      = json["chat_kind"].stringValue
            item.action_name    = json["action_name"].stringValue
            item.answer_chat_id = json["answer_chat_id"].intValue
            item.chat_text      = json["chat_text"].stringValue
            item.chat_date      = json["chat_date"].stringValue
            item.sender_phone   = json["sender"]["phone"].stringValue
            item.sender_avatar  = json["sender"]["avatar"].stringValue
            item.sender_user_id = json["sender"]["user_id"].intValue
            item.sender_name    = json["sender"]["user_name"].string ?? json["sender"]["contact_user_name"].string ?? json["sender"]["phone"].stringValue
            item.recipient_phone = json["recipient"]["phone"].stringValue
            item.recipient_user_id = json["recipient"]["user_id"].intValue
            item.recipient_avatar = json["recipient"]["avatar"].stringValue
            item.recipient_name = json["recipient"]["contact_user_name"].string ?? json["recipient"]["chat_name"].stringValue
            
            try! realm.write {
                realm.add(item)
            }
        }
    }
    
    static func getCurrentObject(chat_id: Int) -> DialogHistory? {
        let realm = try! Realm()
        let obj = realm.objects(DialogHistory.self).filter("chat_id = \(chat_id)")
        return obj.first
    }
    
}


