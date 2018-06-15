//
//  PhoneContact.swift
//  Dalagram
//
//  Created by Toremurat on 13.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation

struct PhoneContact {
    
    var firstName: String   = ""
    var lastName: String    = ""
    var phone: String       = ""
    var image: Data?
    
    init(firstName: String, lastName: String, phone: String, image: Data?) {
        self.firstName  = firstName
        self.lastName   = lastName
        self.phone      = phone
        self.image      = image
    }
    
    func getFullName() -> String {
        return firstName + " " + lastName
    }
    
}



