//
//  ChatController.swift
//  Dalagram
//
//  Created by Toremurat on 22.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatController: UIViewController {
    
    // MARK: - UI Elements
    
    lazy var titleView = UserNavigationTitleView()
    
    lazy var inputBarView: MessageInputBarView = {
        let inputBarView = MessageInputBarView()
        inputBarView.chatDetailVC = self
        return inputBarView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TextMessageCell.self)
        collectionView.backgroundColor = UIColor.white
        collectionView.keyboardDismissMode = .interactive
        collectionView.contentOffset = CGPoint(x: 0, y: 100)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8.0, right: 0)
        collectionView.alwaysBounceVertical = true
        let bgView = UIImageView(image: UIImage(named: "image_chatbg"))
        bgView.contentMode = .scaleAspectFill
        collectionView.backgroundView = bgView
        return collectionView
    }()
    
    lazy var containterView: MessageInputBarView = {
        var height: CGFloat = calculateBottomSafeArea(48.0)
        let view = MessageInputBarView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: height))
        view.chatDetailVC = self
        return view
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return containterView
        }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    // MARK: Variables
    
    var messages: [ChatMessage] = []
    
    var contact: Contact! {
        didSet {
            configureNavBar(contact)
        }
    }

    // MARL: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configureNavBar()
        configureUI()
        configureKeyboard()
       
        SocketIOManager.shared.establishConnection()
        SocketIOManager.shared.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected \(data)")
        }

        SocketIOManager.shared.socket.on("message") { dataArray, ack in
            print("socket message \(dataArray)")
            let dict = dataArray[0] as! NSDictionary
            if let text = dict.value(forKey: "message") as? String, let id = dict.value(forKey: "user_id") as? Int, let name = dict.value(forKey: "name") as? String  {
                
                let message = ChatMessage(user_id: id, user_name: name, text: text)
                self.messages.append(message)
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Configure NavBar
    
    func configureNavBar(_ contact: Contact) {
        let backItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain, target: self, action: #selector(backItemPressed))
        let titleItem = UIBarButtonItem(customView: titleView)
        self.navigationItem.leftBarButtonItems = [backItem, titleItem]
        titleView.userNameLabel.text = contact.user_name.isEmpty ? contact.contact_name : contact.user_name
        titleView.userStatusLabel.text = contact.user_status != "" ? contact.user_status : contact.last_visit
        titleView.userAvatarView.kf.setImage(with: URL(string: contact.avatar))
    }
    
    // MARK: - Configure UI
    
    private func configureUI() {
        view.backgroundColor = UIColor.lightGrayColor
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            //make.bottom.equalTo(-containterView.frame.height)
        }
    }
    
    // MARK: - Keyboard Observer
    
    func configureKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }

    // MARK: - Keyboard Will Show & Hide methods
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if #available(iOS 11.0, *) {
            collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: keyboardFrame.height - view.safeAreaInsets.bottom + 8.0, right: 0)
        } else {
           collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: keyboardFrame.height + 8.0, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
         collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8.0, right: 0)
    }
    
    // MARK: - Navigation Back Button Action
    
    @objc func backItemPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - InputBar Send Button Action
    
    @objc func sendButtonPressed() {
        guard let text = containterView.inputTextField.text, !text.isEmpty else {
            return
        }
        inputBarView.inputTextField.text = nil
        SocketIOManager.shared.socket.emit("message",
                                           ["message": text,
                                            "name": User.currentUser()!.user_name,
                                            "user_id": contact.user_id])
        //scrollToLastItem()
    }
    
    // MARK: - Scroll To Last Item
    
    func scrollToLastItem() {
        let lastSection = collectionView.numberOfSections - 1
        let lastRow = collectionView.numberOfItems(inSection: lastSection)
        let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
}

// MARK: - Buble UICollectionView DataSource & Delegate

extension ChatController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let textCell: TextMessageCell = collectionView.dequeReusableCell(for: indexPath)
        textCell.textView.text = messages[indexPath.row].text
        
        messages[indexPath.row].user_id == contact.user_id ? textCell.setupRightBuble() : textCell.setupLeftBuble()
        
        textCell.bubleWidthAnchor?.constant = estimatedFrameForText(messages[indexPath.row].text).width + 32
        return textCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80.0
        height = estimatedFrameForText(messages[indexPath.row].text).height + 20.0
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }

}
