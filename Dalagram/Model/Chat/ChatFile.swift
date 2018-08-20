
//
//  ChatFiel.swift
//  Dalagram
//
//  Created by Toremurat on 13.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class ChatFile: Object {
    
    @objc dynamic var file_url: String = ""
    @objc dynamic var file_data: Data = Data()
    @objc dynamic var file_format: String = ""
    @objc dynamic var file_name: String = ""

}
