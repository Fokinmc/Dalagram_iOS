//
//  ChatController.swift
//  Dalagram
//
//  Created by Toremurat on 22.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

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
    var messages = ["Hello message", "Test running, or pest concluding",
                    "Some big test test test test test",
                    "Some big test test test test testSome big test test test test testSome big test test test test tests", "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."]
    
    var user: String = "" {
        didSet {
            configureNavBar(user)
        }
    }

    // MARL: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configureNavBar()
        configureUI()
        configureKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Configure NavBar
    
    func configureNavBar(_ user: String = "Klimov Yerbol") {
        let backItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain, target: self, action: #selector(backItemPressed))
        let titleItem = UIBarButtonItem(customView: titleView)
        self.navigationItem.leftBarButtonItems = [backItem, titleItem]
        titleView.userNameLabel.text = user
    }
    
    // MARK: - Configure UI
    
    private func configureUI() {
        view.backgroundColor = UIColor.lightGrayColor
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            //make.bottom.equalTo(-calculateBottomSafeArea(48.0))
            make.bottom.equalToSuperview()
        }
        collectionView.reloadData()
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
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height - view.safeAreaInsets.bottom + 8.0, right: 0)
        } else {
           collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + 8.0, right: 0)
        }
        scrollToLastItem()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
         collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8.0, right: 0)
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
        messages.append(text)
       
        collectionView.reloadData()
        scrollToLastItem()
    }
    
    // MARK: - Scroll To Last Item
    
    func scrollToLastItem() {
        let lastSection = collectionView.numberOfSections - 1
        let lastRow = collectionView.numberOfItems(inSection: lastSection)
        let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
}

// MARK: - UICollectionView DataSource & Delegate

extension ChatController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let textMessageCell: TextMessageCell = collectionView.dequeReusableCell(for: indexPath)
        textMessageCell.textView.text = messages[indexPath.row]
        if indexPath.row % 2 == 0 {
            textMessageCell.bubleView.backgroundColor = UIColor.lightBlueColor
            textMessageCell.textView.textColor = UIColor.white
            textMessageCell.bubleLeftAnchor?.isActive = false
            textMessageCell.bubleRightAnchor?.isActive = true
        } else {
            textMessageCell.bubleView.backgroundColor = UIColor.white
            textMessageCell.textView.textColor = UIColor.black
            textMessageCell.bubleLeftAnchor?.isActive = true
            textMessageCell.bubleRightAnchor?.isActive = false
        }
        textMessageCell.bubleWidthAnchor?.constant = estimatedFrameForText(messages[indexPath.row]).width + 32
        return textMessageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80.0
        height = estimatedFrameForText(messages[indexPath.row]).height + 20.0
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
