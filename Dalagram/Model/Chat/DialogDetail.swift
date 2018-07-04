//
//  DialogDetail.swift
//  Dalagram
//
//  Created by Toremurat on 04.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import SwiftyJSON

struct DialogDetail {
    
    var id: Int = 0
    var isAdmin: Int    = 0
    var name: String    = ""
    var isMute: Int     = 0
    var login: String   = ""
    var avatar: String  = ""
    
    init(type: DialogType, json: JSON) {
        if type == .group {
            self.id         = json["group_id"].intValue
            self.isAdmin    = json["is_admin"].intValue
            self.name       = json["group_name"].stringValue
            self.isMute     = json["is_mute"].intValue
            self.avatar     = json["group_avatar"].stringValue
        } else if type == .channel {
            self.id         = json["channel_id"].intValue
            self.isAdmin    = json["is_admin"].intValue
            self.name       = json["channel_name"].stringValue
            self.isMute     = json["is_mute"].intValue
            self.login      = json["channel_login"].stringValue
            self.avatar     = json["channel_avatar"].stringValue
        }
    }
}
