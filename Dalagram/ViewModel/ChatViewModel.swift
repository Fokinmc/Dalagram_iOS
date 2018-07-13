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
import Photos
import SVProgressHUD

class ChatViewModel {
    
    var messages: Results<DialogHistory>?
    var info: DialogInfo!
    var chatType: DialogType = .single
    var selectedAsset: PHAsset?
    
    var dialogId: String = ""
    var socket: SocketIOClient!
    
    init(_ dialogId: String) {
        let realm = try! Realm()
        self.dialogId = dialogId
        self.messages = realm.objects(DialogHistory.self).filter(NSPredicate(format: "id = %@", dialogId))
    }
    
    // MARK: API ENDPOINT Get Detail of Chat
    
    func getDialogMessages(page: Int = 1, per_page: Int = 40, success: @escaping () -> Void) {
        
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
            if json["data"].count != self.messages?.count {
                for (_, subJson):(String, JSON) in json["data"] {
                    DialogHistory.initWith(json: subJson, dialog_id: self.dialogId)
                }
                success()
            }
        })
    }
    
    // MARK: API ENDPOINT Get Detail Info of Chat
    
    func getDialogDetails(success: @escaping (DialogDetail) -> Void) {
        switch chatType {
        case .group:
            NetworkManager.makeRequest(.getGroupDetails(group_id: info.group_id), success: { (json)  in
                success(DialogDetail(type: .group, json: json["data"]))
            })
        case .channel:
            NetworkManager.makeRequest(.getChannelDetails(channel_id: info.channel_id), success: { (json) in
                success(DialogDetail(type: .channel, json: json["data"]))
            })
        default:
            break
        }
    }
    
    // MARK: API ENDPOINT: Upload chat file
    
    func uploadChatFile(success: @escaping () -> Void) {
        if let asset = selectedAsset {
            let selectedImage = getAssetThumbnail(asset: asset)
            let newFiles = List<ChatFile>()
            let file = ChatFile()
            file.file_format = "image"
            file.file_data = selectedImage
            newFiles.append(file)
            
            let chat_id = -1
            
            DialogHistory.createFileMessage(dialog_id: dialogId, chat_id: chat_id, files: newFiles, sender_user_id: (User.currentUser()?.user_id)!)
            
            success()
            NetworkManager.makeRequest(.uploadChatFile(selectedImage), success: { (json) in
                print(json)
                
                file.file_url = json["file_full_url"].stringValue
                newFiles.removeAll()
                newFiles.append(file)

                DialogHistory.createFileMessage(chat_id: chat_id, files: newFiles, sender_user_id: User.currentUser()!.user_id)
                success()
            })
        }
    }
    
    func getAssetThumbnail(asset: PHAsset) -> Data {
        let options = PHImageRequestOptions()
        var thumbnail = Data()
        options.isSynchronous = true
        options.version = .current
        options.deliveryMode = .fastFormat
     
        PHImageManager.default().requestImageData(for: asset, options: options) { data, _, _, _ in
            if let data = data {
                thumbnail = data
            }
        }
        return thumbnail
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
                let name = dict.value(forKey: "sender_name") as? String ?? ""
                DialogHistory.initWith(dialog_id: dialogID, chat_text: text, sender_user_id: sender_user_id, sender_name: name)
                success()
            }
        }
    
    }
    
    // MARK: - Socket Emit: Message
    
    func socketMessageEmit(text: String, senderId: Int, recipientId: Int, senderName: String) {
        SocketIOManager.shared.socket.emit("message", ["chat_text": text,
                                                       "sender_user_id": senderId,
                                                       "dialog_id": dialogId,
                                                       "sender_name": senderName,
                                                       "recipient_user_id": recipientId])
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
    
    // MARK: Remove DialogHistory with chat_id 0
    
    func removeEmptyDialogHistory() {
        let realm = try! Realm()
        for object in realm.objects(DialogHistory.self).filter("chat_id = 0") {
            try! realm.write {
                realm.delete(object)
            }
        }
    }

}
