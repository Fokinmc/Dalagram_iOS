//
//  ChatController.swift
//  Dalagram
//
//  Created by Toremurat on 16.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RealmSwift
import RxSwift
import AVFoundation

//ChatController
protocol UploadStatusDelegate {
    func uploadBegin()
    func uploadEnd()
}

class ChatController: NMessengerViewController {
    
    // MARK: - Views
    
    lazy var titleView: UserNavigationTitleView = {
        let titleView = UserNavigationTitleView()
        titleView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userTitleViewPressed))
        titleView.addGestureRecognizer(tapGesture)
        return titleView
    }()
    
    // MARK: - Variables
    
    let segmentedControlPadding: CGFloat = 10
    let segmentedControlHeight: CGFloat = 30
    var bootstrapWithRandomMessages : Int = 30
    let disposeBag = DisposeBag()
    
    private(set) var lastMessageGroup: MessageGroup? = nil
    
    var viewModel: ChatViewModel?
    
    private var recordingSession: AVAudioSession!
    private var audoRecorder: AVAudioRecorder!
    
    // MARK: - ViewModel & Controller Initializer
    
    convenience init(type: DialogType = .single, info: DialogInfo, dialogId: String) {
        self.init()
        self.viewModel = ChatViewModel(dialogId, info: info, chatType: type)
        self.viewModel!.chatVC = self
        self.configureNavBar(info)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBubbleMessages()
        setEmptyBackTitle()
        setRequestNotifications()
        socketMessageEvent()
        socketTypingEvent()
        socketOnlineEvent()
        inputBarViewEvents()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            NotificationCenter.default.removeObserver(self, name: AppManager.dialogDetailsNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: AppManager.diloagHistoryNotification, object: nil)
            SocketIOManager.shared.socket.off("message")
            viewModel?.removeEmptyDialogHistory()
        }
    }
    
    // MARK: - Setup Request Notifications
    
    func setRequestNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadDialogDetails), name: AppManager.dialogDetailsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadMessages), name: AppManager.diloagHistoryNotification, object: nil)
    }
    
    // MARK: - Send Socket Event "Typing"
    
    override func sendTypingEvent() {
        viewModel?.socketTypingEmit()
    }
    
    // MARK: - Recieve Socket Event "Typing"
    
    func socketTypingEvent() {
        guard let vm = viewModel else { return }
        SocketIOManager.shared.socket.on("typing") { (data, ack) in
            if let data = data[0] as? NSDictionary {
               if let sender_id = data["sender_id"] as? Int {
                    if sender_id == vm.info.user_id {
                        self.startTypingIndicator(isTyping: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: { [weak self] in
                            guard let vc = self else { return }
                            vc.startTypingIndicator(isTyping: false)
                        })
                    }
                }
            }
        }
    }
    
    @objc func startTypingIndicator(isTyping: Bool) {
        if isTyping {
            titleView.userStatusLabel.text = "Печатает..."
        } else {
            titleView.userStatusLabel.text = "Был(а) недавно"
        }
    }
    
    // MARK: - Socket Event: Online
    
    func socketOnlineEvent() {
        guard let vm = self.viewModel else { return }
        SocketIOManager.shared.socket.on("online") { [weak self] (params, ack) in
            guard let vc = self else { return }
            let dict = params[0] as! NSDictionary
           
            if let sender_id = dict.value(forKey: "sender_id") as? Int {
                if vm.info.user_id == sender_id {
                    vc.titleView.userStatusLabel.text = "В сети"
                    if let _ = dict.value(forKey: "is_online") as? Bool {
                        vc.titleView.userStatusLabel.text = "был(а) недавно"
                    }
                }
            }
        }
    }
    
    // MARK: - Socket Event: Message
    
    func socketMessageEvent() {
        viewModel?.socketMessageEvent(onSuccess: { [weak self] (text) in
            guard let vc = self else { return }
            //vc.sendText(text, date: Date().getStringTime(), isIncomingMessage: true)
            let textContent = TextContentNode(id: 0, textMessageString: text, dateString: Date().getStringTime(), currentViewController: vc, bubbleConfiguration: vc.sharedBubbleConfiguration)
            textContent.sendIconNode.image = nil
            textContent.sendIconNode.image = UIImage(named: "icon_mark_single")
            let newMessage = MessageNode(content: textContent)
            newMessage.cellPadding = vc.messagePadding
            newMessage.currentViewController = self
            vc.postText(newMessage, isIncomingMessage: true)
        })
    }
    
    // MARK: - Setup messages from Realm
    
    func setupBubbleMessages() {
        viewModel?.loadMessagesFromRealm { [weak self] in
            guard let vc = self, let vm = self?.viewModel else { return }
            vc.messengerView.addMessages(vm.messageGroups, scrollsToMessage: false)
            vc.lastMessageGroup = vm.messageGroups.last
            vc.messengerView.scrollToLastMessage(animated: false)
            vc.loadMessages()
        }
    }

    // MARK: - Load Chat History Request
    
    @objc func loadMessages() {
        viewModel?.getDialogMessages(requestSuccess: { [weak self] (newMessages) in
            guard let vc = self else { return }
            print(newMessages)
            vc.messengerView.addMessages(newMessages, scrollsToMessage: false)
            vc.lastMessageGroup = newMessages.last
            vc.messengerView.scrollToLastMessage(animated: true)
        })
    }
    
    // MARK: - Dialog Detail Request
    
    @objc func loadDialogDetails() {
        viewModel?.getDialogDetails { [weak self] (detail) in
            self?.titleView.userNameLabel.text = detail.name
            self?.titleView.userAvatarView.kf.setImage(with: URL(string: detail.avatar), placeholder: #imageLiteral(resourceName: "bg_gradient_3"))
        }
    }
    
    // MARK: - NMessenger Send Image Action
    
    override func sendContact(imageUrl: String, name: String, phone: String, date: String, userId: Int, isIncomingMessage: Bool) -> GeneralMessengerCell {
        return self.postContact(imageUrl: imageUrl, name: name, phone: phone, date: date, userId: userId, isIncomingMessage: isIncomingMessage)
    }
    override func sendImage(_ image: UIImage, isIncomingMessage: Bool) -> GeneralMessengerCell {
        return self.postImage(image, isIncomingMessage: isIncomingMessage)
    }
    
    override func sendVideo(_ thumbImage: UIImage, videoUrl: URL, videoData: Data, isIncomingMessage: Bool) -> GeneralMessengerCell {
        return self.postVideo(thumbImage, videoUrl: videoUrl,videoData: videoData, isIncomingMessage: isIncomingMessage)
    }
    
    override func sendCollectionViewWithNodes(_ nodes: [ASDisplayNode], numberOfRows: CGFloat, isIncomingMessage: Bool) -> GeneralMessengerCell {
        return self.postCollectionView(nodes, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
    }
    
    override func sendDocument(_ fileName: String, fileExtension: String, fileData: Data,  isIncomingMessage: Bool) -> GeneralMessengerCell {
        return self.postDocument(fileName:fileName, fileExtension: fileExtension, fileData: fileData, isIncomingMessage: isIncomingMessage)
    }
    
    override func sendText(_ text: String, date: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        //create a new text message
        let textContent = TextContentNode(id: 0, textMessageString: text, dateString: date, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
        textContent.sendIconNode.image = nil
        textContent.sendIconNode.image = UIImage(named: "icon_mark_single")
        let newMessage = MessageNode(content: textContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        self.postText(newMessage, isIncomingMessage: false)
        
        // We set double mark icon when messages saved to db
        viewModel?.socketMessageEmit(text: text, onSuccess: {
            textContent.sendIconNode.image = nil
            textContent.sendIconNode.image = UIImage(named: "icon_mark_double")
            textContent.setNeedsDisplay()
            self.inputBarView.changeReplyArea(with: "")
        })
        return newMessage
    }
    
    // MARK: - NMessenger Post Text Delegate
    
    private func postImage(_ image: UIImage, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let imageContent = ImageContentNode(image: image, date: Date().getStringTime(), currentVC: self, bubbleConfiguration: self.sharedBubbleConfiguration)
        imageContent.uploadBegin()
        let newMessage = MessageNode(content: imageContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        self.addMessageToMessenger(newMessage)

        // Upload to server process
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            viewModel?.uploadChatFile(with: data, format: "image", success: {
                print("image uploaded to server")
                imageContent.uploadEnd()
            })
        }
        return newMessage
    }
    
    private func postDocument(fileName: String, fileExtension: String, fileData: Data, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let node = DocumentContentNode(text: fileName, date: Date().getStringTime(), currentVC: self, bubbleConfiguration: self.sharedBubbleConfiguration)
        node.uploadBegin()
        let newMessage = MessageNode(content: node)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        self.addMessageToMessenger(newMessage)
        let serverFileName = fileName.replacingOccurrences(of: " ", with: "_")
        viewModel?.uploadChatFile(with: fileData, format: "document", fileExtension: fileExtension, fileName: serverFileName, success: {
            print("document uploaded to server")
            node.uploadEnd()
        })
        return newMessage
    }
    
    private func postVideo(_ image: UIImage, videoUrl: URL, videoData: Data, isIncomingMessage: Bool) -> GeneralMessengerCell {
        print(image)
        let videoContent = VideoContentNode(image: image, videoUrl: videoUrl, date: Date().getStringTime(), currentVC: self, bubbleConfiguration: self.sharedBubbleConfiguration)
        videoContent.uploadBegin()
        let newMessage = MessageNode(content: videoContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        self.addMessageToMessenger(newMessage)
        
        // Upload to server process
        var videoExtension = videoUrl.lastPathComponent
        videoExtension = NSString(string: videoExtension).pathExtension
        print(videoExtension)
        viewModel?.uploadChatFile(with: videoData, format: "video", fileExtension: videoExtension, success: {
            videoContent.uploadEnd()
        })
        return newMessage
    }
    
    private func postContact(imageUrl: String, name: String, phone: String, date: String, userId: Int, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let contactContent = ContactContentNode(imageUrl: imageUrl, name: name, phone: phone, date: date, currentVC: self, bubbleConfiguration: self.sharedBubbleConfiguration, userId: userId)
        let newMessage = MessageNode(content: contactContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        self.addMessageToMessenger(newMessage)
        
        viewModel?.sendMessageApi(isContact: true, contactPhone: phone, contactName: name)
        return newMessage
    }
    
    private func postCollectionView(_ nodes: [ASDisplayNode], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let collectionViewContent = CollectionViewContentNode(withCustomNodes: nodes, andNumberOfRows: numberOfRows, bubbleConfiguration: self.sharedBubbleConfiguration)
        
        let newMessage = MessageNode(content: collectionViewContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        self.addMessageToMessenger(newMessage)
        
        // Upload to server process
        for imageNode in nodes {
            if let imageContent = imageNode as? ImageContentNode {
                imageContent.uploadBegin()
                if let data = UIImageJPEGRepresentation(imageContent.image!, 0.5) {
                    viewModel?.uploadChatFile(with: data, format: "image", success: {
                        print("image uploaded task")
                        imageContent.uploadEnd()
                    })
                }
            }
        }
        
        return newMessage
    }
    
    private func postText(_ message: MessageNode, isIncomingMessage: Bool) {
        if self.lastMessageGroup == nil || self.lastMessageGroup?.isIncomingMessage == !isIncomingMessage {
            self.lastMessageGroup = self.createMessageGroup()
            self.lastMessageGroup!.isIncomingMessage = isIncomingMessage
            self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: false)
            self.messengerView.addMessage(self.lastMessageGroup!, scrollsToMessage: true, withAnimation: isIncomingMessage ? .left : .right)
        } else {
            self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: true)
        }
    }
    
    /**
     Creates a new message group for *lastMessageGroup*
     -returns: MessageGroup
     */
    
    private func createMessageGroup() -> MessageGroup {
        let newMessageGroup = MessageGroup()
        newMessageGroup.currentViewController = self
        newMessageGroup.cellPadding = self.messagePadding
        return newMessageGroup
    }
    
    func inputBarViewEvents() {
        self.inputBarView.isReplyMessage.asObservable().subscribe(onNext: { [weak self] (value) in
            self?.viewModel?.isReplyMessage = value
            print(value)
        }).disposed(by: disposeBag)
    }
    
}

extension ChatController {
    
    // MARK: - Configuring NavBar TitleView
    
    func configureNavBar(_ data: DialogInfo) {

        let titleItem = UIBarButtonItem(customView: titleView)
        self.navigationItem.leftBarButtonItem = titleItem
        self.navigationItem.leftItemsSupplementBackButton = true
        let userNameText = data.user_name.isEmpty ? data.phone : data.user_name
        titleView.userNameLabel.text = userNameText
        
        guard let vm = viewModel else { return }
        var imagePlaceholder = #imageLiteral(resourceName: "bg_gradient_2")
        var statusPlaceholder = ""
        
        switch vm.chatType {
        case .single:
            statusPlaceholder = data.last_visit
            imagePlaceholder = #imageLiteral(resourceName: "bg_gradient_2")
        case .group:
            statusPlaceholder = "Группа"
            imagePlaceholder = #imageLiteral(resourceName: "bg_gradient_1")
        case .channel:
            statusPlaceholder = "Канал"
            imagePlaceholder = #imageLiteral(resourceName: "bg_gradient_3")
        }
        titleView.userStatusLabel.text = statusPlaceholder
        titleView.userAvatarView.kf.setImage(with: URL(string: data.avatar), placeholder: imagePlaceholder)
        
    }
    
    // MARK: - NavBar TitleView Action
    
    @objc func userTitleViewPressed() {
        
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)

        guard let vm = viewModel else { return }
        switch vm.chatType {
        case .single:
            let vc = UserProfileController.fromStoryboard()
            vc.contact = viewModel!.info
            vc.dialogId = viewModel!.dialogId
            self.show(vc, sender: nil)
        case .group:
            let vc = EditGroupController.fromStoryboard()
            vc.groupInfo = viewModel!.info
            self.show(vc, sender: nil)
        case .channel:
            let vc = EditChannelController.fromStoryboard()
            vc.channelInfo = viewModel!.info
            self.show(vc, sender: nil)
        }
    }
}

extension ChatController: TextContentNodeOutput {
    
    func messageReplyAction(text: String, messageId: Int) {
        print(text)
        self.viewModel?.replyMessageId = messageId
        self.inputBarView.changeReplyArea(with: text)
        self.inputBarView.isReplyMessage.value = true
    }
    
}
