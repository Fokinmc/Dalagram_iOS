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
        
        if !Contact.isset(id: json["user_id"].intValue) {
            let object = Contact()
            object.user_id        = json["user_id"].intValue
            object.user_name      = json["user_name"].stringValue
            object.contact_name   = json["contact_user_name"].stringValue
            object.avatar         = AppManager.baseUrl + json["avatar"].stringValue
            object.user_status    = json["user_status"].stringValue
            object.last_visit     = json["last_visit"].stringValue
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(object)
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
