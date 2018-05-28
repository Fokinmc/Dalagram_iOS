//
//  ChatDetailController.swift
//  Dalagram
//
//  Created by Toremurat on 22.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit


class ChatDetailController: UIViewController {

    var collectionView: UICollectionView!
    lazy var titleView = UserNavigationTitleView()
    
    lazy var inputBarView: MessageInputBarView = {
        let inputBarView = MessageInputBarView()
        inputBarView.chatDetailVC = self
        return inputBarView
    }()
    
    // MARK: Variables
    var messages = ["Test running, or pest concluding",
                    "Some big test test test test test",
                    "Some big test test test test testSome big test test test test testSome big test test test test test"]
    
    // MARL: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureUI()
        setupInputBar()
    }
    
    // MARK: - Configure NavBar
    func configureNavBar() {

        let backItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain, target: self, action: #selector(backItemPressed))
        let titleItem = UIBarButtonItem(customView: titleView)
        self.navigationItem.leftBarButtonItems = [backItem, titleItem]
        
        titleView.userNameLabel.text = "Klimov Yerbol"
    }
    
    // MARK: Configure UI
    private func configureUI() {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TextMessageCell.self)
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        
        let bgView = UIImageView(image: UIImage(named: "image_chatbg"))
        bgView.contentMode = .scaleAspectFill
        
        collectionView.backgroundView = bgView
        
    }
    
    // MARK: Setup InputBar Components
    
    func setupInputBar() {
        view.addSubview(inputBarView)
        inputBarView.setupConstraints()
    }
    
    // MARK: - Navigation Back Button Action
    
    @objc func backItemPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func sendButtonPressed() {
        
    }
    
}

// MARK: - UICollectionView DataSource & Delegate

extension ChatDetailController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let textMessageCell: TextMessageCell = collectionView.dequeReusableCell(for: indexPath)
        textMessageCell.textView.text = messages[indexPath.row]
        return textMessageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messages[indexPath.row]).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0)], context: nil)
        return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
    }
    

    
    

    
    
}
