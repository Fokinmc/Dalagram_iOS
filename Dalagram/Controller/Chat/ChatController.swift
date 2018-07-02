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

class ChatController: UIViewController {
    
    // MARK: - UI Elements
    
    lazy var titleView: UserNavigationTitleView = {
        let titleView = UserNavigationTitleView()
        titleView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userTitleViewPressed))
        titleView.addGestureRecognizer(tapGesture)
        return titleView
    }()
    
    lazy var inputBarView: MessageInputBarView = {
        var height: CGFloat = calculateBottomSafeArea(48.0)
        let view = MessageInputBarView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: height))
        view.chatDetailVC = self
        return view
    }()
    
    lazy var layout = BouncyLayout(style: BouncyLayout.BounceStyle.subtle)
    
    lazy var collectionView: UICollectionView = {
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        let backgroundView = UIImageView(image: UIImage(named: "image_chatbg"))
        backgroundView.contentMode = .scaleAspectFill
        collectionView.backgroundView = backgroundView
        return collectionView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputBarView
        }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    // MARK: Variables
    
    var notificationToken: NotificationToken? = nil
    var viewModel: ChatViewModel!
    var info: DialogInfo!
    
    // MARK: Initializer of Single Chat/Group/Channel
    convenience init(type: DialogType = .single, info: DialogInfo, dialogId: String) {
        self.init()
        self.viewModel = ChatViewModel(dialogId)
        self.viewModel.info = info
        self.viewModel.chatType = type
        self.info = info
        configureNavBar(info)
    }
    
    
    // MARL: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setEmptyBackTitle()
        addKeyboardObservers()
        loadMessages()
        
        viewModel.socketMessageEvent { [weak self] in
            self?.collectionView.reloadData()
            self?.collectionView.scrollToLastItem(animated: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadGroupDetails), name: AppManager.dialogDetailsNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        let bottomOffset = collectionView.contentSize.height - collectionView.bounds.height + 8.0
        self.collectionView.setContentOffset(CGPoint(x: 0, y: bottomOffset), animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        // Remove everything with chat_id 0
        let realm = try! Realm()
        for object in realm.objects(DialogHistory.self).filter("chat_id = 0") {
            try! realm.write {
                realm.delete(object)
            }
        }
        
        SocketIOManager.shared.socket.off("message")
    }
    
    // MARK: Load Chat Details
    
    func loadMessages() {
        viewModel.getDialogDetails(success: { [weak self] in
            guard let vc = self else { return }
            vc.collectionView.reloadData()
            vc.collectionView.scrollToLastItem(animated: false)
        })
    }
    
    @objc func loadGroupDetails() {
        viewModel.getGroupDetails { [weak self] (groupName, groupAva) in
            self?.titleView.userNameLabel.text = groupName
            self?.titleView.userAvatarView.kf.setImage(with: URL(string: groupAva), placeholder: #imageLiteral(resourceName: "bg_gradient_0"))
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
             viewModel.socketMessageEmit(text: messageText, senderId: currentUser.user_id, recipientId: info.user_id, senderName: info.user_name)
        }
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
            vc.contact = info
            self.show(vc, sender: nil)
        case .group:
            let vc = EditGroupController.fromStoryboard()
            vc.groupInfo = info
            self.show(vc, sender: nil)
        default:
            break
        }
       
    }
    
}

// MARK: - Bubble UICollectionView DataSource & Delegate

extension ChatController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = viewModel.messages![indexPath.row]
        if message.chat_kind == "action" {
            let cell: DialogActionCell = collectionView.dequeReusableCell(for: indexPath)
            cell.setupData(message)
            return cell
        } else {
            let textCell: BubbleTextCell = collectionView.dequeReusableCell(for: indexPath)
        
            textCell.textView.text = message.chat_text
            textCell.dateLabel.text = message.chat_date
            textCell.bubleWidthAnchor?.constant = (round((estimatedFrameForText(message.chat_text).width + estimatedFrameForText(message.chat_date).width)/2.0) * 2) + 38.0
            
            if viewModel.chatType == .group {
                textCell.setupLeftBuble()
            } else {
                message.sender_user_id != info.user_id ? textCell.setupRightBuble() : textCell.setupLeftBuble()
            }
            
            //textCell.bubleWidthAnchor?.isActive = true
            return textCell
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80.0
        height = estimatedFrameForText(viewModel.messages![indexPath.row].chat_text).height + 20.0
        return CGSize(width: collectionView.frame.width - collectionView.frame.width.truncatingRemainder(dividingBy: 2), height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        keyboardWillHide()
    }
    
    private func estimatedFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 180, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }

}

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
        let bottomInset = keyboardFrameEnd.height - inputBarView.frame.height + 8.0
        self.collectionView.contentInset.bottom = bottomInset
        self.collectionView.scrollIndicatorInsets.bottom = bottomInset
        self.collectionView.scrollToLastItem(animated: true)
    }
    
    @objc func keyboardWillHide() {
        collectionView.contentInset.bottom = 8.0
        collectionView.scrollIndicatorInsets.bottom = 0.0
    }
}


// MARK: - UI Conrigurations

extension ChatController {
    
    // MARK: - Configure NavBar
    
    func configureNavBar(_ data: DialogInfo) {
        let backItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain, target: self, action: #selector(backItemPressed))
        let titleItem = UIBarButtonItem(customView: titleView)
        self.navigationItem.leftBarButtonItems = [backItem, titleItem]
        titleView.userNameLabel.text = data.user_name
        titleView.userStatusLabel.text = data.last_visit
        titleView.userAvatarView.kf.setImage(with: URL(string: data.avatar), placeholder: UIImage(named: "bg_gradient_\(arc4random_uniform(4))"))
    }
    
    // MARK: - Configure UI
    
    private func configureUI() {
        
        // Swipe Gesture
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(backItemPressed))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
        
        view.backgroundColor = UIColor.lightGrayColor
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BubbleTextCell.self)
        collectionView.register(DialogActionCell.self)
        collectionView.backgroundColor = UIColor.white
        collectionView.keyboardDismissMode = .interactive
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8.0, right: 0)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8.0, right: 0)
        collectionView.contentOffset = CGPoint(x: 0, y: collectionView.contentSize.height - collectionView.bounds.height + 8.0)
        collectionView.alwaysBounceVertical = true
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(-inputBarView.frame.height)
        }
    }
}
