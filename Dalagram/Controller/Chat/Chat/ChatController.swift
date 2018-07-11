//
//  ChatController.swift
//  Dalagram
//
//  Created by Toremurat on 22.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import BouncyLayout
import AsyncDisplayKit

class ChatController: UIViewController {
    
    // MARK: - UI Elements
    lazy var layout = BouncyLayout(style: BouncyLayout.BounceStyle.subtle)
    
    lazy var titleView: UserNavigationTitleView = {
        let titleView = UserNavigationTitleView()
        titleView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userTitleViewPressed))
        titleView.addGestureRecognizer(tapGesture)
        return titleView
    }()
    
    lazy var inputBarView: MessageInputBarView = {
        let height: CGFloat = calculateBottomSafeArea(48.0)
        let view = MessageInputBarView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: height))
        view.chatDetailVC = self
        return view
    }()
    
    lazy var joinButtonView: JoinChannelView = {
        let height: CGFloat = calculateBottomSafeArea(48.0)
        let view = JoinChannelView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: height))
        return view
    }()
    
    var collectionView: ASCollectionNode?
    
    override var inputAccessoryView: UIView? {
        get {
            switch viewModel.chatType {
            case .channel:
                return viewModel.info.is_admin == 1 ? inputBarView : joinButtonView
            default:
                return inputBarView
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    deinit {
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
    }
    
    let bubleImageOut = UIImage(named: "BubbleOutgoing")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14).withRenderingMode(.alwaysTemplate)
    
    let bubleImageIn = UIImage(named: "BubbleIncoming")!.stretchableImage(withLeftCapWidth: 21, topCapHeight: 14).withRenderingMode(.alwaysTemplate)
    
    // MARK: Variables
    
    var notificationToken: NotificationToken? = nil
    var viewModel: ChatViewModel!
    
    // MARK: Initializer for Single Chat/Group/Channel
    
    convenience init(type: DialogType = .single, info: DialogInfo, dialogId: String) {
        self.init()
        self.viewModel = ChatViewModel(dialogId)
        self.viewModel.info = info
        self.viewModel.chatType = type
        self.configureNavBar(info)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setEmptyBackTitle()
        addKeyboardObservers()
        loadMessages()

        viewModel.socketMessageEvent { [weak self] in
            self?.collectionView?.reloadData()
            self?.scrollToLastItem()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(loadDialogDetails), name: AppManager.dialogDetailsNotification, object: nil)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        scrollToLastItem(animated: false)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            NotificationCenter.default.removeObserver(self, name: AppManager.dialogDetailsNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
            SocketIOManager.shared.socket.off("message")
            viewModel.removeDialogHistory()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: Load Chat Details
    
    func loadMessages() {
        viewModel.getDialogMessages(success: { [weak self] in
            guard let vc = self else { return }
            vc.collectionView?.reloadData()
            vc.scrollToLastItem()
        })
    }
    
    func scrollToLastItem(animated: Bool = true) {
        guard let count = viewModel.messages?.count else { return }
        let indexPath = IndexPath(item: count - 1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }
    
    @objc func loadDialogDetails() {
        viewModel.getDialogDetails { [weak self] (detail) in
            self?.titleView.userNameLabel.text = detail.name
            self?.titleView.userAvatarView.kf.setImage(with: URL(string: detail.avatar), placeholder: #imageLiteral(resourceName: "bg_gradient_3"))
        }
    }
    
    // MARK: - Navigation Back Button Action
    
    @objc func backItemPressed() {
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.removeObserver(self, name: AppManager.dialogDetailsNotification, object: nil)
    }
    
    // MARK: - InputBar Send Button Action
    
    @objc func sendButtonPressed() {
        guard let messageText = inputBarView.inputTextField.text, !messageText.isEmpty else {
            return
        }
        inputBarView.inputTextField.text = nil
        if let currentUser = User.currentUser() {
            self.collectionView?.insertItems(at: [IndexPath(item: (viewModel.messages?.count ?? 1) - 1, section: 0)])
             viewModel.socketMessageEmit(text: messageText, senderId: currentUser.user_id, recipientId: viewModel.info.user_id, senderName: viewModel.info.user_name)
        }
    }
    
    // MARK: - Join to Channel Action
    
    @objc func joinChannelPressed() {
        print("yea")
    }
    
    // MARK: - UserNavigationView TapGesture Action
    
    @objc func userTitleViewPressed() {
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        
        switch viewModel.chatType {
        case .single:
            let vc = UserProfileController.fromStoryboard()
            vc.contact = viewModel.info
            self.show(vc, sender: nil)
        case .group:
            let vc = EditGroupController.fromStoryboard()
            vc.groupInfo = viewModel.info
            self.show(vc, sender: nil)
        case .channel:
            let vc = EditChannelController.fromStoryboard()
            vc.channelInfo = viewModel.info
            self.show(vc, sender: nil)
        }
    }
}

// MARK: - Bubble UICollectionView DataSource & Delegate

extension ChatController : ASCollectionDelegate {
    
    public func shouldBatchFetch(for collectionView: ASCollectionView) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize(width: UIScreen.main.bounds.size.width, height: 0), CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
}
extension ChatController : ASCollectionDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages?.count ?? 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let message = viewModel.messages![indexPath.row]
        let isOut = message.sender_user_id != viewModel.info.user_id ? true : false
        let bubbleImg = message.sender_user_id != viewModel.info.user_id ? bubleImageOut : bubleImageIn
        let nodeData = ASNodeCellData(text: message.chat_text, date: message.chat_date, name: message.sender_name, kind: message.chat_kind)
        let node = ChatBubleNodeCell(message: nodeData, isOutgoing: isOut, bubbleImage: bubbleImg)
        node.delegate = self
        return node
    }
}

//MARK: - Chat Cell delegates

extension ChatController: ChatDelegate {
    
    func openUserProfile(message: ASNodeCellData) {
        print("openuserProfile click")
    }
    
    func openImageGallery(message: ASNodeCellData) {
        print("openImageGallery click")
    }
    
    func openGallery(message: ASNodeCellData){
        print("openGallery click")
    }
}

//extension ChatController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return viewModel.messages?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let message = viewModel.messages![indexPath.row]
//        if message.chat_kind == "action" && viewModel.chatType != .single {
//            let cell: BubleActionCell = collectionView.dequeReusableCell(for: indexPath)
//            cell.setupData(message)
//            return cell
//        } else {
//            let textCell: BubbleTextCell = collectionView.dequeReusableCell(for: indexPath)
//            textCell.setupData(message, chatType: viewModel.chatType, user_id: info.user_id)
//            return textCell
//        }
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var height: CGFloat = 80.0
//        height = estimatedFrameForText(viewModel.messages![indexPath.row].chat_text).height + 20.0
//        return CGSize(width: collectionView.frame.width - collectionView.frame.width.truncatingRemainder(dividingBy: 2), height: height)
//    }
//
//    private func estimatedFrameForText(_ text: String) -> CGRect {
//        let size = CGSize(width: 180, height: 1000)
//        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
//        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0)], context: nil)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        keyboardWillHide()
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        collectionView.collectionViewLayout.invalidateLayout()
//    }
//
//}
//
//extension ChatController: ChatLayoutDelegate {
//    func collectionView(_ collectionView: UICollectionView,
//                        heightForBubleAtIndexPath indexPath:IndexPath) -> CGFloat {
//
//        return estimatedFrameForText(viewModel.messages![indexPath.row].chat_text).height + 20.0
//    }
//}

// MARK: - UIKeyboard Observers

extension ChatController {
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Keyboard Will Show & Hide Selectors
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        /// FIXME: Selector called when view loaded
        /// InputAccessoryView automatically called notification when view loaded
        /// But KeyboardBeginFrame CGRect is equal to zero, so we don't need to change view insets
        
        let keyboardFrameEnd = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardFrameBegin = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as!
            NSValue).cgRectValue
        if keyboardFrameBegin.height.isEqual(to: 0.0) || keyboardFrameEnd.height == inputBarView.frame.height {
            return
        }
        if keyboardFrameBegin.height > keyboardFrameEnd.height {
            return
        }
        let bottomInset = keyboardFrameEnd.height - inputBarView.frame.height
        self.collectionView?.contentInset.bottom = bottomInset + 8.0
        self.collectionView?.view.scrollIndicatorInsets.bottom = bottomInset - 8.0
        scrollToLastItem()
    }
    
    @objc func keyboardWillHide() {
        self.collectionView?.contentInset.bottom = 8.0
        self.collectionView?.view.scrollIndicatorInsets.bottom = 0.0
    }
}


// MARK: - UI Conrigurations

extension ChatController {
    
    // MARK: - Configure NavBar
    
    func configureNavBar(_ data: DialogInfo) {
        let titleItem = UIBarButtonItem(customView: titleView)
        self.navigationItem.leftBarButtonItem = titleItem
        self.navigationItem.leftItemsSupplementBackButton = true
        
        titleView.userNameLabel.text = data.user_name
        titleView.userStatusLabel.text = viewModel.info.user_id != 0 ? data.last_visit : ""
        var placeholderImage = #imageLiteral(resourceName: "bg_gradient_2")
        switch viewModel.chatType {
        case .single:
            placeholderImage = #imageLiteral(resourceName: "bg_gradient_2")
        case .group:
            placeholderImage = #imageLiteral(resourceName: "bg_gradient_1")
        case .channel:
            placeholderImage = #imageLiteral(resourceName: "bg_gradient_3")
        }
        titleView.userAvatarView.kf.setImage(with: URL(string: data.avatar), placeholder: placeholderImage)
    }
    
    // MARK: - Configure UI

    private func configureUI() {
        view.backgroundColor = UIColor.lightGrayColor
        
        let layout = ChatCollectionViewFlowLayout()
        layout.minimumLineSpacing  = 0
        layout.minimumInteritemSpacing = 0
        let backgroundView = UIImageView(image: UIImage(named: "image_chatbg"))
        backgroundView.contentMode = .scaleAspectFill
        
        let collectionNode = ASCollectionNode(collectionViewLayout: layout)
        self.collectionView = collectionNode
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.view.backgroundView = backgroundView
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.view.keyboardDismissMode = .interactive
        self.collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8.0, right: 0)
        
        view.addSubnode(self.collectionView!)
        view.bringSubview(toFront: inputAccessoryView!)
        
        self.collectionView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - inputBarView.bounds.height)

        collectionView?.view.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(-inputAccessoryView!.frame.height)
        }
        
        if let collection = collectionView?.view{
            // Swift
            if #available(iOS 10, *) {
                collection.isPrefetchingEnabled = false
            }
        }
    }
}
