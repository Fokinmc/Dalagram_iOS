//
//  Contact.swift
//  Dalagram
//
//  Created by Toremurat on 08.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift

class Contact: Object {
    
    @objc dynamic var user_id: Int          = 0
    @objc dynamic var user_name: String     = ""
    @objc dynamic var contact_name: String  = ""
    @objc dynamic var avatar: String        = ""
    @objc dynamic var user_status: String   = ""
    @objc dynamic var last_visit: String    = ""
    
    override class func primaryKey() -> String? {
        return "user_id"
    }
    
    static func initWith(json: JSON) {
        let realm = try! Realm()
        if !Contact.isset(id: json["user_id"].intValue) {
            let object = Contact()
            object.user_id        = json["user_id"].intValue
            object.user_name      = json["user_name"].stringValue
            object.contact_name   = json["contact_user_name"].stringValue
            object.avatar         = json["avatar"].stringValue
            object.user_status    = json["user_status"].stringValue
            object.last_visit     = json["last_visit"].stringValue
            
            try! realm.write {
                realm.add(object)
            }
        } else {
            let contact = realm.object(ofType: Contact.self, forPrimaryKey: json["user_id"].intValue)
            try! realm.write {
                contact?.avatar         = json["avatar"].stringValue
                contact?.user_status     = json["user_status"].stringValue
                contact?.last_visit      = json["last_visit"].stringValue
            }
        }
    }
    
    static func currentContact() -> Contact? {
        let realm = try! Realm()
        let contacts = realm.objects(Contact.self)
        if contacts.count > 0 {
            return contacts.first!
        }
        return nil
    }
    
    static func isset(id: Int) -> Bool {
        let realm = try! Realm()
        return realm.object(ofType: Contact.self, forPrimaryKey: id) != nil
    }
}
