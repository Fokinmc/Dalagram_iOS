
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

class JSONChatFile {
    
    var file_url: String = ""
    var file_time: Double = 0.0
    var file_format: String = ""
    var file_name: String = ""
    
    init(json: JSON) {
        self.file_url = json["file_url"].stringValue
        self.file_time = json["file_time"].doubleValue
        self.file_format = json["file_format"].stringValue
        self.file_name = json["file_name"].stringValue
    }
    
}
class ChatFile: Object {
    
    @objc dynamic var file_url: String = ""
    @objc dynamic var file_data: Data = Data()
    @objc dynamic var file_format: String = ""
    @objc dynamic var file_name: String = ""

}
