//
//  DialogsViewModel.swift
//  Dalagram
//
//  Created by Toremurat on 15.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class DialogsViewModel {

    var dialogs: Results<Dialog>?
    let realm = try! Realm()
    
    init() {
        dialogs = realm.objects(Dialog.self).sorted(byKeyPath: "updatedDate")
    }
    
    // MARK: - Dialogs GET Request
    
    func getUserDialogs(page: Int = 1, per_page: Int = 40, success: @escaping (() -> Void) = {}) {
        let parameters = ["token": User.getToken(), "page": page, "per_page": per_page] as [String : Any]
        NetworkManager.makeRequest(.getDialogs(parameters), success: { (json)  in
            print(json)
            for (_, subJson):(String, JSON) in json["data"] {
                let primaryKeyId = subJson["dialog_id"].stringValue
                let dialogItem = DialogItem.initWith(json: subJson, id: primaryKeyId)
                Dialog.initWith(dialogItem: dialogItem, id: primaryKeyId)
            }
            success()
        })
    }
    
    // MARK: - Socket Event: Message
    
    func socketMessageEvent(onEvent: @escaping () -> Void) {
        SocketIOManager.shared.socket.on("message") { [weak self] (dataArray, ack)  in
            print("socketMessageEvent \(dataArray)")
            let dict = dataArray[0] as! NSDictionary
            if let text = dict.value(forKey: "chat_text") as? String,
                let dialog_id = dict.value(forKey: "dialog_id") as? String,
                let recipiend_id = dict.value(forKey: "recipient_user_id") as? Int,
                let sender_user_id = dict.value(forKey: "sender_user_id") as? Int {
                
                print(recipiend_id, sender_user_id)
                
                if recipiend_id == User.currentUser()!.user_id || sender_user_id == User.currentUser()!.user_id {
                    // Edit existing dialog
                    if let currentDialog = self?.dialogs?.filter(NSPredicate(format: "id = %@", dialog_id)).first {
                        let realm = try! Realm()
                        try! realm.write {
                            currentDialog.dialogItem?.chat_text = text
                            currentDialog.dialogItem?.chat_date = "Сейчас"
                            if sender_user_id != User.currentUser()!.user_id {
                                currentDialog.messagesCount = currentDialog.messagesCount + 1
                            }
                        }
                        onEvent()
                    } else {
                        // Dialog don't exist, need to pull from server
                        self?.getUserDialogs()
                    }
                }
            }
        }
    }
    
    // MARK: - Connect to Socket
    
    func connectToSocket(onConnect: @escaping () -> Void, onDisconnect:  @escaping () -> Void ) {
        SocketIOManager.shared.socket.on(clientEvent: .connect) {data, ack in
            onConnect()
        }
        SocketIOManager.shared.socket.on(clientEvent: .disconnect) { (data, ack) in
            onDisconnect()
        }
        SocketIOManager.shared.socket.on(clientEvent: .reconnectAttempt) { (data, ack) in
            onDisconnect()
        }
    }
    
    // MARK: - Reset Messages Counter
    
    func resetMessagesCounter(for item: Dialog) {
        if item.messagesCount != 0 {
            try! realm.write {
                item.messagesCount = 0
            }
        }
    }
    
    // MARK: - Mute Dialog
    
    func muteDialog(by identifier: String, muteValue: Bool = true) {
        if let item = realm.object(ofType: Dialog.self, forPrimaryKey: "\(identifier)") {
            try! realm.write {
                item.isMute = !item.isMute
            }
        }
    }
    
    // MARK: - Delete Dialog
    
    func removeDialog(by identifier: String, dialogItem: DialogItem) {
        if let item = realm.object(ofType: Dialog.self, forPrimaryKey: "\(identifier)") {
            try! realm.write {
                realm.delete(item)
            }
        }
        for item in realm.objects(DialogHistory.self).filter(NSPredicate(format: "id = %@", identifier)) {
            try! realm.write {
                realm.delete(item)
            }
        }
        /// Endpoing Parameters for signle/group/channel dialogs
        var endpointParam: [String: Any] = [:]
        
        if dialogItem.user_id != 0 {
            endpointParam["partner_id"] = dialogItem.user_id
        } else if dialogItem.group_id != 0 {
            endpointParam["group_id"] = dialogItem.group_id
        } else if dialogItem.channel_id != 0 {
            endpointParam["channel_id"] = dialogItem.channel_id
        }
        
        NetworkManager.makeRequest(.removeChat(endpointParam), success: { (json) in
            WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
        })
    }
    
    // MARK: - Clear Dialog History
    
    func clearDialog(by identifier: String) {
        for object in realm.objects(DialogHistory.self)
            .filter(NSPredicate(format: "id = %@", identifier)) {
            try! realm.write {
                realm.delete(object)
            }
        }
        if let item = realm.object(ofType: Dialog.self, forPrimaryKey: "\(identifier)") {
            try! realm.write {
                item.dialogItem?.chat_text = ""
            }
        }
    }
    
    // MARK: - Search dialog by Message text and Contact name
    // CONTAINS[c] is case insensitive keyword
    
    func searchDialog(by text: String, onReload: @escaping() -> Void?) {
        let searchResults = realm.objects(Dialog.self).filter("dialogItem.chat_text CONTAINS[c] '\(text)' OR dialogItem.chat_name CONTAINS[c] '\(text)'")
        if searchResults.count != 0 {
            self.dialogs = searchResults
            onReload()
        }
    }
    
    func getAllDialogs(onReload: @escaping () -> Void) {
        self.dialogs = realm.objects(Dialog.self).sorted(byKeyPath: "updatedDate")
        onReload()
    }
    
}
