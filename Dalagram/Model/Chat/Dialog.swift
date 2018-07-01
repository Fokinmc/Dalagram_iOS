//
//  Dialog.swift
//  Dalagram
//
//  Created by Toremurat on 15.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

/// id - json["user_id"] recipient user id
/// updateDate - NSDate
/// messageCount - Int
/// dialogItem - Realm Object (refrence)

enum DialogType {
    case single
    case group
    case channel
}

class Dialog: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var updatedDate: Date = Date()
    @objc dynamic var messagesCount: Int = 0
    @objc dynamic var dialogItem: DialogItem? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func initWith(dialogItem: DialogItem, id: String) {
        let realm = try! Realm()
        if let object = getDialogBy(id) {
            // UPDATE
            try! realm.write {
                object.dialogItem = dialogItem
                object.updatedDate = Date()
            }
        } else {
            // CREATE
            let object  = Dialog()
            object.id   = id
            object.dialogItem = dialogItem
            
            try! realm.write {
                realm.add(object)
            }
        }
    }
   
    static func getDialogBy(_ id: String) -> Dialog? {
        let realm = try! Realm()
        let obj = realm.objects(Dialog.self).filter(NSPredicate(format: "id = %@", id))
        return obj.first
    }
    
}

