//
//  ContactInfo.swift
//  Dalagram
//
//  Created by Toremurat on 15.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation

struct DialogInfo {

    var user_id: Int = 0
    var group_id: Int = 0
    var channel_id: Int = 0
    var user_name: String
    var avatar: String
    var last_visit: String
    var phone: String
    var is_admin: Int = 0
    
    /// Init from Contacts Controller
    init(contact: Contact) {
        self.user_id = contact.user_id
        self.user_name = contact.user_name != "" ? contact.user_name : contact.contact_name
        self.avatar = contact.avatar
        self.last_visit = contact.last_visit
        self.phone = contact.contact_name
    }
    
    /// Init from Dialogs Controller
    init(dialog: DialogItem) {
        print(dialog)
        self.user_id = dialog.user_id
        self.user_name = dialog.contact_user_name != "" ? dialog.contact_user_name : dialog.chat_name
        self.avatar = dialog.avatar
        self.last_visit = "Был(а) \(dialog.chat_date)"
        self.phone = dialog.phone
        self.group_id = dialog.group_id
        self.channel_id = dialog.channel_id
        self.is_admin = dialog.is_admin
    }
    
    init(json: JSONContact) {
        self.user_id        = json.user_id
        self.user_name      = json.user_name
        self.phone          = json.phone
        self.avatar         = json.avatar
        self.last_visit     = json.last_visit
        self.is_admin       = json.user_id
    }
    
}
