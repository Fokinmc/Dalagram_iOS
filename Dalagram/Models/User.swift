//
//  User.swift
//  Dalagram
//
//  Created by Toremurat on 07.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class User: Object {
    
    @objc dynamic var user_id: Int      = 0
    @objc dynamic var user_name: String = ""
    @objc dynamic var is_new_user: Bool = false
    @objc dynamic var avatar: String    = ""
    @objc dynamic var token: String     = ""
    
    override class func primaryKey() -> String? {
        return "user_id"
    }
    
    static func initWith(json: JSON) {
        
        let id = json["user_id"].intValue
        if User.isset() {
            print("Realm - User with id \(id) already exists")
            let realm = try! Realm()
            if let obj = realm.objects(User.self).first {
                try! realm.write {
                    obj.user_name   = json["user_name"].stringValue
                    obj.is_new_user = json["is_new_user"].boolValue
                    obj.avatar      = imageWithEncoding(json["avatar"].stringValue)
                }
            }
            return
        }
        
        let object = User()
        object.user_id      = id
        object.user_name    = json["user_name"].stringValue
        object.is_new_user  = json["is_new_user"].boolValue
        object.avatar       = imageWithEncoding(json["avatar"].stringValue)
        object.token        = json["token"].stringValue

        let realm = try! Realm()
        try! realm.write {
            realm.add(object)
        }
    
    }
    
    static func getToken() -> String {
        if let user = User.currentUser() {
            return user.token
        } else {
            return ""
        }
    }
    
    static func currentUser() -> User? {
        let realm = try! Realm()
        let users = realm.objects(User.self)
        if users.count > 0 {
            return users.first!
        }
        return nil
    }
    
    static func isset() -> Bool {
        return User.currentUser() != nil
    }
    
    static func removeUser() {
        let realm = try! Realm()
        if let obj = realm.objects(User.self).first {
            realm.beginWrite()
            realm.delete(obj)
            try! realm.commitWrite()
        }
    }
    
    static func imageWithEncoding(_ str: String) -> String {
        return str.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed) ?? str
    }
}
