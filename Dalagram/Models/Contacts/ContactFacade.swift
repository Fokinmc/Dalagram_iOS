//
//  ContactFacade.swift
//  Dalagram
//
//  Created by Toremurat on 31.08.2018.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation

struct ContactFacade {
    
    var phoneContact: PhoneContact? = nil
    var dalagramContact: Contact? = nil
    var jsonContact: JSONContact? = nil
    
    init(phoneContact: PhoneContact? = nil, dalagramContact: Contact? = nil, jsonContact: JSONContact? = nil) {
        self.phoneContact = phoneContact
        self.dalagramContact = dalagramContact
        self.jsonContact = jsonContact
    }
    
}
