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
    
    lazy var collectionView: UICollectionView = {
        layout.scrollDirection = .vertical
        let lt = ChatCollectionViewFlowLayout()
        lt.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: lt)
        let backgroundView = UIImageView(image: UIImage(named: "image_chatbg"))
        backgroundView.contentMode = .scaleAspectFill
        collectionView.backgroundView = backgroundView
        return collectionView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            switch viewModel.chatType {
            case .channel:
                return info.is_admin == 1 ? inputBarView : joinButtonView
            default:
                return inputBarView
            }
           
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: Variables
    
    var notificationToken: NotificationToken? = nil
    var viewModel: ChatViewModel!
    var info: DialogInfo!
    
    // MARK: Initializer for Single Chat/Group/Channel
    
    convenience init(type: DialogType = .single, info: DialogInfo, dialogId: String) {
        self.init()
        self.viewModel = ChatViewModel(dialogId)
        self.viewModel.info = info
        self.viewModel.chatType = type
        self.info = info
        self.configureNavBar(info)
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

        NotificationCenter.default.addObserver(self, selector: #selector(loadDialogDetails), name: AppManager.dialogDetailsNotification, object: nil)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bottomOffset = collectionView.contentSize.height - collectionView.bounds.height + 8.0
        self.collectionView.setContentOffset(CGPoint(x: 0, y: bottomOffset), animated: false)
       
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
        NotificationCenter.default.removeObserver(self, name: AppManager.dialogDetailsNotification, object: nil)
        
        // Remove everything with chat_id 0
        viewModel.removeDialogHistory()
        //SocketIOManager.shared.socket.off("message")
    }
    
    // MARK: Load Chat Details
    
    func loadMessages() {
        viewModel.getDialogMessages(success: { [weak self] in
            guard let vc = self else { return }
            vc.collectionView.reloadData()
            vc.collectionView.scrollToLastItem(animated: true)
        })
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
             viewModel.socketMessageEmit(text: messageText, senderId: currentUser.user_id, recipientId: info.user_id, senderName: info.user_name)
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
            vc.contact = info
            self.show(vc, sender: nil)
        case .group:
            let vc = EditGroupController.fromStoryboard()
            vc.groupInfo = info
            self.show(vc, sender: nil)
        case .channel:
            let vc = EditChannelController.fromStoryboard()
            vc.channelInfo = info
            self.show(vc, sender: nil)
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
        if message.chat_kind == "action" && viewModel.chatType != .single {
            let cell: BubleActionCell = collectionView.dequeReusableCell(for: indexPath)
            cell.setupData(message)
            return cell
        } else {
            let textCell: BubbleTextCell = collectionView.dequeReusableCell(for: indexPath)
            textCell.setupData(message, chatType: viewModel.chatType, user_id: info.user_id)
            return textCell
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80.0
        height = estimatedFrameForText(viewModel.messages![indexPath.row].chat_text).height + 20.0
        return CGSize(width: collectionView.frame.width - collectionView.frame.width.truncatingRemainder(dividingBy: 2), height: height)
    }
    
    private func estimatedFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 180, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0)], context: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        keyboardWillHide()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }

}

extension ChatController: ChatLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForBubleAtIndexPath indexPath:IndexPath) -> CGFloat {
        
        return estimatedFrameForText(viewModel.messages![indexPath.row].chat_text).height + 20.0
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
        var bottomInset = keyboardFrameEnd.height - inputBarView.frame.height + 8.0
        if keyboardFrameBegin.height > keyboardFrameEnd.height {
            bottomInset = keyboardFrameEnd.height - inputBarView.frame.height - 8.0
        }
        self.collectionView.contentInset.bottom = bottomInset
        self.collectionView.scrollIndicatorInsets.bottom = bottomInset
        self.collectionView.scrollToLastItem(animated: true)
    }
    
    @objc func keyboardWillHide() {
        collectionView.contentInset.bottom = 8.0
        collectionView.scrollIndicatorInsets.bottom = 8.0
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
        titleView.userStatusLabel.text = info.user_id != 0 ? data.last_visit : ""
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
        
        // Swipe Gesture
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(backItemPressed))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
        
        view.backgroundColor = UIColor.lightGrayColor
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BubbleTextCell.self)
        collectionView.register(BubleActionCell.self)
        collectionView.backgroundColor = UIColor.white
        collectionView.keyboardDismissMode = .interactive
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8.0, right: 0)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8.0, right: 0)
        collectionView.alwaysBounceVertical = true
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(-inputAccessoryView!.frame.height)
        }
    }
}
