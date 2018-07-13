//
//  DialogItem.swift
//  Dalagram
//
//  Created by Toremurat on 19.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class DialogItem: Object {
    
    @objc dynamic var dialog_id: String     = ""
    @objc dynamic var chat_id: Int          = 0
    @objc dynamic var chat_kind: String     = ""
    @objc dynamic var chat_name: String     = ""
    @objc dynamic var chat_text: String     = ""
    @objc dynamic var chat_date: String     = ""
    
    @objc dynamic var group_id: Int         = 0
    @objc dynamic var channel_id: Int       = 0
    @objc dynamic var user_id: Int          = 0
     
    @objc dynamic var action_name: String   = ""
    @objc dynamic var avatar: String        = ""
    @objc dynamic var phone: String         = ""
    @objc dynamic var contact_user_name: String = ""
    
    @objc dynamic var is_admin: Int         = 0
    @objc dynamic var is_read: Int          = 0
    @objc dynamic var is_mute: Int          = 0
    @objc dynamic var is_own_last_message: Bool = false
    
    override static func primaryKey() -> String? {
        return "dialog_id"
    }
    
    static func initWith(json: JSON, id: String) -> DialogItem {
        let realm = try! Realm()
        if let existingItem = getCurrentDialog(id) {
            try! realm.write {
                existingItem.avatar             = json["avatar"].stringValue
                existingItem.chat_date          = json["chat_date"].stringValue
                existingItem.chat_text          = json["chat_text"].stringValue
                existingItem.contact_user_name  = json["contact_user_name"].stringValue
                existingItem.chat_name          = json["chat_name"].stringValue
                existingItem.chat_kind          = json["chat_kind"].stringValue
                existingItem.is_mute            = json["is_mute"].intValue
                existingItem.action_name        = json["action_name"].stringValue
                existingItem.is_own_last_message = json["is_own_last_message"].boolValue
                existingItem.is_read            = json["is_read"].intValue
                existingItem.is_admin           = json["is_admin"].intValue
            }
            return existingItem
        } else {
            
            let item = DialogItem()
            item.dialog_id   = id
            item.chat_id     = json["chat_id"].intValue
            item.chat_kind   = json["chat_kind"].stringValue
            item.action_name = json["action_name"].stringValue
            item.group_id    = json["group_id"].intValue
            item.channel_id  = json["channel_id"].intValue
            item.is_mute     = json["is_mute"].intValue
            item.user_id     = json["user_id"].intValue
            item.chat_name   = json["chat_name"].stringValue
            item.avatar      = json["avatar"].stringValue
            item.phone       = json["phone"].stringValue
            item.chat_text   = json["chat_text"].stringValue
            item.chat_date   = json["chat_date"].stringValue
            item.is_read     = json["is_read"].intValue
            item.is_admin    = json["is_admin"].intValue
            item.contact_user_name = json["contact_user_name"].stringValue
            item.is_own_last_message = json["is_own_last_message"].boolValue
            return item
        }
        
        
    }
    
    static func getCurrentDialog(_ id: String) -> DialogItem? {
        let realm = try! Realm()
        let obj = realm.objects(DialogItem.self).filter(NSPredicate(format: "dialog_id = %@", id))
        return obj.first
    }
    
}


