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
import AsyncDisplayKit

class ChatViewModel {
    
    var messageGroups = [MessageGroup]()
    var messages: Results<DialogHistory>?
    var info: DialogInfo!
    var chatType: DialogType = .single
    var selectedAsset: PHAsset?
    
    var dialogId: String = ""
    var socket: SocketIOClient!
    var chatVC: NNChatController!
    var lastRecievedChatId: Int = 0
    
    // MARK: - ViewModel Initializer
    
    init(_ dialogId: String, info: DialogInfo, chatType: DialogType) {
        self.dialogId = dialogId
        self.info = info
        self.chatType = chatType
    }
    
    // MARK: - Load Data to MessageGroups
    
    func loadNewMessageFromRealm(success: @escaping ([MessageGroup]) -> Void) {
        var newMessageGroups = [MessageGroup]()
//        for message in realm.objects(DialogHistory.self).filter(NSPredicate(format: "id = %@", dialogId)) {
//            print(message.chat_id, lastRecievedChatId)
//
//                addRealmResults(with: message, newMessageGroup: newMessageGroups)
//            }
//        }
        newMessageGroups = addRealmResults(isFirstLoading: false)
        success(newMessageGroups)
    }
    
    func loadMessagesFromRealm(success: @escaping () -> Void) {
//        let realm = try! Realm()
//        let historyObjects = realm.objects(DialogHistory.self).filter(NSPredicate(format: "id = %@", dialogId))
//        for message in historyObjects {
//            addRealmResults(with: message, newMessageGroup: messageGroups)
//        }
        
        messageGroups = addRealmResults()
        success()
    }
    
    private func addRealmResults(isFirstLoading: Bool = true) -> [MessageGroup] {
        let realm = try! Realm()
        let historyObjects = realm.objects(DialogHistory.self).filter(NSPredicate(format: "id = %@", dialogId))
        var messageGroups: [MessageGroup] = []
        for message in historyObjects {
            if message.chat_id > lastRecievedChatId || isFirstLoading {
                if message.file_list.count > 0 {
                    for file in message.file_list {
                        if file.file_format == "file" {
                            // Documents
                            let documentNode = DocumentContentNode(text: file.file_name, date: message.chat_date, documentUrl: URL(string: file.file_url)!, currentVC: chatVC, bubbleConfiguration: chatVC.sharedBubbleConfiguration)
                            let messageNode = MessageNode(content: documentNode)
                            messageNode.cellPadding = chatVC.messagePadding
                            messageNode.currentViewController = chatVC
                            let newMessageGroup = createMessageGroup()
                            newMessageGroup.addMessageToGroup(messageNode, completion: nil)
                            newMessageGroup.isIncomingMessage = message.sender_user_id != info.user_id ? false : true
                            if chatType != .single {
                                newMessageGroup.isIncomingMessage = true
                            }
                            messageGroups.append(newMessageGroup)
                            lastRecievedChatId = message.chat_id
                            
                        } else if file.file_format == "image" {
                            // Images
                            let imageNode = NetworkImageContentNode(imageURL: file.file_url, date: message.chat_date, currentVC: chatVC, bubbleConfiguration: chatVC.sharedBubbleConfiguration)
                            let messageNode = MessageNode(content: imageNode)
                            messageNode.cellPadding = chatVC.messagePadding
                            
                            let newMessageGroup = createMessageGroup()
                            newMessageGroup.addMessageToGroup(messageNode, completion: nil)
                            newMessageGroup.isIncomingMessage = message.sender_user_id != info.user_id ? false : true
                            if chatType != .single {
                                newMessageGroup.isIncomingMessage = true
                            }
                            messageGroups.append(newMessageGroup)
                            lastRecievedChatId = message.chat_id
                        } else if file.file_format == "video" {
                            // Videos
                            if let videoUrl = URL(string: file.file_url) {
                                let videoContent = VideoContentNode(videoUrl: videoUrl, date: message.chat_date, currentVC: chatVC, bubbleConfiguration: chatVC.sharedBubbleConfiguration)
                                let messageNode = MessageNode(content: videoContent)
                                messageNode.cellPadding = chatVC.messagePadding
                                
                                let newMessageGroup = createMessageGroup()
                                newMessageGroup.addMessageToGroup(messageNode, completion: nil)
                                newMessageGroup.isIncomingMessage = message.sender_user_id != info.user_id ? false : true
                                messageGroups.append(newMessageGroup)
                                lastRecievedChatId = message.chat_id
                            }
                        }
                        
                    }
                    
                } else if message.chat_kind == "action" {
                    // Group, Channel Actions (i.e someone added to the group)
                    let actionNode = ActionContentNode(textMessageString: getActionCredentials(message), bubbleConfiguration: ActionBubbleConfiguration())
                    
                    let messageNode = MessageNode(content: actionNode)
                    messageNode.cellPadding = chatVC.messagePadding
                    
                    let newMessageGroup = createMessageGroup()
                    newMessageGroup.addMessageToGroup(messageNode, completion: nil)
                    newMessageGroup.isCenterMessage = true
                    
                    messageGroups.append(newMessageGroup)
                    lastRecievedChatId = message.chat_id
                    
                } else if message.chat_kind == "message" {
                    // Messages for Chat, Group, Channel
                    let isIncomingMessage = message.sender_user_id != info.user_id ? false : true
                    let textContent = TextContentNode(textMessageString: message.chat_text, dateString: message.chat_date, currentViewController: chatVC, bubbleConfiguration: chatVC.sharedBubbleConfiguration)
                    
                    let messageNode = MessageNode(content: textContent)
                    messageNode.cellPadding = chatVC.messagePadding
                    messageNode.currentViewController = chatVC
                    lastRecievedChatId = message.chat_id
                    
                    if messageGroups.last == nil || messageGroups.last?.isIncomingMessage == !isIncomingMessage {
                        let newMessageGroup = createMessageGroup()
                        if isIncomingMessage && chatType == .group {
                            newMessageGroup.avatarNode = createAvatar(with: message.sender_avatar)
                        }
                        newMessageGroup.isIncomingMessage = isIncomingMessage
                        newMessageGroup.addMessageToGroup(messageNode, completion: nil)
                        messageGroups.append(newMessageGroup)
                    } else {
                        messageGroups.last?.addMessageToGroup(messageNode, completion: nil)
                    }
                    
                    // We save last local chat_id. It need when we pull history from server (getDialogMessages:Method)
                    lastRecievedChatId = message.chat_id
                }
            }
        }
        return messageGroups
        
    }
    
    func getThumbnail(with sourceURL: URL) -> UIImage? {
        let asset = AVAsset(url: sourceURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)

        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print(error)
            return UIImage(named: "some generic thumbnail")
        }
    }
    
    private func getActionCredentials(_ data: DialogHistory) -> String {
        // I.e User One added to ther group User Two
        var text = data.sender_name + " " + data.action_name
        if data.recipient_user_id != 0 {
            text += " \(data.recipient_name)"
        }
        return text
    }
    
    private func createMessageGroup() -> MessageGroup {
        let newMessageGroup = MessageGroup()
        newMessageGroup.currentViewController = chatVC
        newMessageGroup.cellPadding = chatVC.messagePadding
        return newMessageGroup
    }
    
    private func createAvatar(with imageUrl: String = "") -> ASNetworkImageNode {
        let avatar = ASNetworkImageNode()
        avatar.backgroundColor = UIColor.lightGray
        avatar.style.preferredSize = CGSize(width: 26, height: 26)
        avatar.layer.cornerRadius = 13
        avatar.image = #imageLiteral(resourceName: "bg_gradient_3")
        if !imageUrl.isEmpty {
            avatar.image = nil
            avatar.url = URL(string: imageUrl)
        }
        return avatar
    }
    
    // MARK: API ENDPOINT Get Detail of Chat
    
    func getDialogMessages(page: Int = 1, per_page: Int = 40, requestSuccess: @escaping ([MessageGroup]) -> Void) {
        
        var parameters = ["token": User.getToken(), "page": page, "per_page": per_page] as [String : Any]
        
        switch chatType {
        case .single:
            parameters["recipient_user_id"] = info.user_id
        case .group:
            parameters["group_id"] = info.group_id
        case .channel:
             parameters["channel_id"] = info.channel_id
        }
    
        NetworkManager.makeRequest(.getDialogDetails(parameters), success: { (json)  in
            for (_, subJson):(String, JSON) in json["data"] {
                if self.lastRecievedChatId < subJson["chat_id"].intValue {
                    DialogHistory.initWith(json: subJson, dialog_id: self.dialogId)
                }
                //DialogHistory.initWith(json: subJson, dialog_id: self.dialogId)
            }
            self.loadNewMessageFromRealm(success: { newMessages in
                requestSuccess(newMessages)
            })
        })
    }
    
    // MARK: API ENDPOINT Get Detail Info of Chat
    
    func getDialogDetails(success: @escaping (DialogDetail) -> Void) {
        switch chatType {
        case .group:
            NetworkManager.makeRequest(.getGroupDetails(group_id: info.group_id), success: { (json)  in
                success(DialogDetail(type: .group, json: json["data"]))
                print(json)
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
    
    func uploadChatFile(with imageData: Data, format: String, fileExtension: String = "", fileName: String = "", success: @escaping () -> Void) {
        NetworkManager.makeRequest(.uploadChatFile(imageData, format: format, fileExtension: fileExtension, fileName: fileName), success: { (json) in
            print(json)
            let jsonDictionary = ["file_url": json["file_url"].stringValue,
                                  "file_format": json["file_format"].stringValue,
                                  "file_name": json["file_name"].stringValue]
            
            var parameters: [String: Any] = [:]
            switch format {
            case "image":
                parameters["chat_text"] = "Фотография"
            case "document":
                parameters["chat_text"] = "Документ"
            case "video":
                parameters["chat_text"] = "Видео"
            default: break
            }
            
            switch self.chatType {
            case .single:
                parameters["recipient_user_id"] = self.info.user_id
            case .group:
                parameters["group_id"] = self.info.group_id
            case .channel:
                parameters["channel_id"] = self.info.channel_id
            }
            
            NetworkManager.makeRequest(.sendFileMessage(params: parameters, files: [jsonDictionary]), success: { (json) in
                print("makeRequest(.sendFileMessage", json)
                success()
            })
            //DialogHistory.createFileMessage(dialog_id: self.dialogId, chat_id: 0, files: newFiles, sender_user_id: senderId)
//            self.socketFilesEmit(text: "Отправлено изображение", files: json.stringValue, senderId: senderId, recipientId: recipientId)
//            success()
        })
    }
    
    // MARK: - Socket Event: Message
    
    func socketMessageEvent(onSuccess: @escaping (_ text: String) -> Void) {
        SocketIOManager.shared.socket.on("message") { dataArray, ack in
            let dict = dataArray[0] as! NSDictionary
            if let text = dict.value(forKey: "chat_text") as? String,
                let recipiend_id = dict.value(forKey: "recipient_user_id") as? Int {
                if let user = User.currentUser() {
                    if recipiend_id == user.user_id {
                        onSuccess(text)
                    }
                }
            }
        }
    }
    
    // MARK: - Socket Event: Typing
    
    func socketTypingEvet(onSuccess: @escaping (_ isTyping: Bool) -> Void) {
        SocketIOManager.shared.socket.on("message") { dataArray, ack in
            let dict = dataArray[0] as! NSDictionary
            if let value = dict.value(forKey: "typingValue") as? Bool {
                onSuccess(value)
            }
        }
    }
    
    // MARK: - Socket Emit: Message
    
    func socketMessageEmit(text: String, onSuccess: @escaping ()-> Void) {
        if let user = User.currentUser() {
            SocketIOManager.shared.socket.emit("message", ["chat_text": text,
                                                           "sender_user_id": user.user_id,
                                                           "dialog_id": dialogId,
                                                           "sender_name": user.user_name,
                                                           "recipient_user_id": info.user_id])
            sendMessageApi(chat_text: text, success: {
                onSuccess()
            })
        } else {
            WhisperHelper.showErrorMurmur(title: "User does not exist")
        }
    }
    
    func socketFilesEmit(text: String, files: String, senderId: Int, recipientId: Int, senderName: String = "") {
        SocketIOManager.shared.socket.emit("message", ["chat_image": text,
                                                       "sender_user_id": senderId,
                                                       "dialog_id": dialogId,
                                                       "sender_name": senderName,
                                                       "recipient_user_id": recipientId])
        sendMessageApi(chat_text: text, files: files)
    }
    
    func socketTypingEmit() {
        if let user = User.currentUser() {
            SocketIOManager.shared.socket.emit("typing", ["dialog_id": dialogId, "sender_id": user.user_id])
        }
    }
    
    // MARK: - Send Message POST Request
    // In order to see dialogs and full history, need to send request for each message
    
    func sendMessageApi(chat_text: String, files: String = "", success: @escaping ()->Void = {}) {
        
        var parameters = ["chat_text": chat_text] as [String: Any]
        switch chatType {
            case .single:
                parameters["recipient_user_id"] = info.user_id
            case .group:
                parameters["group_id"] = info.group_id
            case .channel:
                parameters["channel_id"] = info.channel_id
        }
        
        if !files.isEmpty {
            parameters["file_list"] = files
        }
        
        NetworkManager.makeRequest(.sendMessage(parameters), success: { (json) in
            if files.isEmpty {
                DialogHistory.initWith(json: json["data"][0], dialog_id: self.dialogId)
            }
            success()
        })
    }
    
    // MARK: - Update Particular Node Cell Data
    
    @objc func updateNodeData() {
        if let group = messageGroups.last {
            if let message = group.messages.last {
                if let messageNode = message as? MessageNode {
                    if let textNode = messageNode.contentNode as? TextContentNode {
                        textNode.sendIconNode.image = nil
                        textNode.sendIconNode.image = #imageLiteral(resourceName: "icon_mark_double")
                        textNode.setNeedsDisplay()
                    }
                }
            }
        }
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
