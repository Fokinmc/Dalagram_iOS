//
//  ChatViewModel.swift
//  Dalagram
//
//  Created by Toremurat on 01.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import SwiftyJSON
import SocketIO

class ChatViewModel {
    
    var messages: Results<DialogHistory>?
    var info: DialogInfo!
    var chatType: DialogType = .single
    
    var dialogId: String = ""
    var socket: SocketIOClient!
    
    init(_ dialogId: String) {
        let realm = try! Realm()
        self.dialogId = dialogId
        self.messages = realm.objects(DialogHistory.self).filter(NSPredicate(format: "id = %@", dialogId))
    }
    
    // MARK: Get Detail of Chat
    
    func getDialogDetails(page: Int = 1, per_page: Int = 100, success: @escaping () -> Void) {
        
        var parameters = ["token": User.getToken(), "page": page, "per_page": per_page] as [String : Any]
        
        switch chatType {
        case .single:
            parameters["recipient_user_id"] = info.user_id
        case .group:
            parameters["group_id"] = info.group_id
        case .channel:
             parameters["channel_id"] = info.channel_id
        }
    
        NetworkManager.makeRequest(.getDialogDetails(parameters), success: { [unowned self] (json)  in
            print(json)
            for (_, subJson):(String, JSON) in json["data"] {
                DialogHistory.initWith(json: subJson, dialog_id: self.dialogId)
            }
            success()
        })
    }
    
    // MARK: - Socket Event: Message
    
    func socketMessageEvent(success: @escaping () -> Void) {
        SocketIOManager.shared.socket.on("message") { dataArray, ack in
            let dict = dataArray[0] as! NSDictionary
            if let text = dict.value(forKey: "chat_text") as? String, let sender_user_id = dict.value(forKey: "sender_user_id") as? Int, let dialog_id = dict.value(forKey: "dialog_id") as? String {
                print(sender_user_id, dialog_id)
                var dialogID = dialog_id
                if sender_user_id != User.currentUser()?.user_id {
                   dialogID = "\(sender_user_id)U"
                }
                DialogHistory.initWith(dialog_id: dialogID, chat_text: text, sender_user_id: sender_user_id)
                success()
            }
        }
    
    }
    
    // MARK: - Socket Emit: Message
    
    func socketMessageEmit(text: String, senderId: Int, recipientId: Int, senderName: String) {
        SocketIOManager.shared.socket.emit("message", ["chat_text": text, "sender_user_id": senderId, "dialog_id": dialogId])
        sendMessageApi(chat_text: text)
    }
    
    // MARK: - Send Message POST Request
    // In order to see dialogs and full history, need to send request for each message
    
    func sendMessageApi(chat_text: String) {
        
        var parameters = ["chat_text": chat_text] as [String: Any]
        switch chatType {
        case .single:
            parameters["recipient_user_id"] = info.user_id
        case .group:
            parameters["group_id"] = info.group_id
        case .channel:
            parameters["channel_id"] = info.channel_id
        }
        NetworkManager.makeRequest(.sendMessage(parameters), success: { (json) in
            print("makeRequest(.sendMessage", json)
            //DialogHistory.initWith(json: json["data"], dialog_id: self.dialogId)
        })
    }
    
}
