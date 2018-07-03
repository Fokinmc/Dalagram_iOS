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
    
    typealias MessageEventHandler = (() -> Void)

    var dialogs: Results<Dialog>?
    var messageEventHandler: MessageEventHandler?
    
    init() {
        let realm = try! Realm()
        dialogs = realm.objects(Dialog.self)
    }
    
    // MARK: - Dialogs GET Request
    
    func getUserDialogs(page: Int = 1, per_page: Int = 100, success: @escaping (() -> Void) = {}) {
        let parameters = ["token": User.getToken(), "page": page, "per_page": per_page] as [String : Any]
        NetworkManager.makeRequest(.getDialogs(parameters), success: { [weak self] (json)  in
            guard let vc = self else { return }
            print(json)
            for (_, subJson):(String, JSON) in json["data"] {
                let primaryKeyId = subJson["dialog_id"].stringValue
                let dialogItem = DialogItem.initWith(json: subJson, id: primaryKeyId)
                Dialog.initWith(dialogItem: dialogItem, id: primaryKeyId)
            }
            let realm = try! Realm()
            vc.dialogs = realm.objects(Dialog.self).sorted(byKeyPath: "updatedDate")
            success()
        })
    }
    
    // MARK: - Socket Event: Message
    
    func socketMessageEvent() {
        SocketIOManager.shared.socket.on("message") { [weak self] (dataArray, ack)  in
            print("socketMessageEvent \(dataArray)")
            let dict = dataArray[0] as! NSDictionary
            if let text = dict.value(forKey: "chat_text") as? String, let dialog_id = dict.value(forKey: "dialog_id") as? String {
                if let currentDialog = self?.dialogs?.filter(NSPredicate(format: "id = %@", dialog_id)).first {
                    let realm = try! Realm()
                    try! realm.write {
                        currentDialog.dialogItem?.chat_text = text
                        currentDialog.dialogItem?.chat_date = "Сейчас"
                        currentDialog.updatedDate = Date()
                        currentDialog.messagesCount = currentDialog.messagesCount + 1
                    }
                    self?.messageEventHandler?()
                } else {
                    // load dialogs
                    self?.getUserDialogs()
                    print("dialog don't exist")
                }
            }
        }
    }
    
    func resetMessagesCounter(for item: Dialog) {
        if item.messagesCount != 0 {
            let realm = try! Realm()
            try! realm.write {
                item.messagesCount = 0
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
}
