//
//  RealmManager.swift
//  Dalagram
//
//  Created by Toremurat on 07.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    let realm = try! Realm()
    
    func deleteObject(object: Object) {
        try! realm.write({
            realm.delete(object)
        })
    }
    
    func deleteDatabase() {
        try! realm.write({
            realm.deleteAll()
        })
    }
    func saveObjects(objs: [Object]) {
        try! realm.write({
            realm.add(objs, update: true)
        })
    }
    
    func getObjects(type: Object.Type) -> Results<Object>? {
        return realm.objects(type)
    }
    
}
