//
//  MessageInputBarView.swift
//  Dalagram
//
//  Created by Toremurat on 25.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit

class MessageInputBarView: UIView {

    var chatDetailVC: ChatController?  {
        didSet {
            sendButton.addTarget(chatDetailVC, action: #selector(ChatController.sendButtonPressed), for: .touchUpInside)
            attachButton.addTarget(chatDetailVC, action: #selector(ChatController.attachButtonPressed), for: .touchUpInside)
        }
    }
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "icon_audio"), for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(sendButtonDoubleTap))
        tap.numberOfTapsRequired = 2
        button.addGestureRecognizer(tap)
        return button
    }()
    
    lazy var inputTextField: UITextView = {
        let textView = UITextView()
        textView.text = "Введите сообщение.."
        textView.textColor = UIColor.lightGray
        textView.backgroundColor = UIColor.white
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.layer.borderColor = UIColor(white: 0.8, alpha: 0.8).cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5.0
        textView.delegate = self
        return textView
    }()
    
    lazy var attachButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "icon_attache"), for: .normal)
        return button
    }()
    
    var sendButtonState: SendButtonState = .audio {
        didSet {
            sendButton.setImage(sendButtonState == .audio ? #imageLiteral(resourceName: "icon_audio") : #imageLiteral(resourceName: "icon_send"), for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 0.8)
        sendButton.isSelected = true
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc func sendButtonDoubleTap() {
        switch sendButtonState {
        case .audio:
            sendButtonState = .text
        case .text:
            sendButtonState = .audio
        }
    }
    
    func updateBottomConstaints(_ constant: CGFloat) {
        snp.updateConstraints { (make) in
            make.bottom.equalTo(constant)
        }
    }
    
    let contentView = UIView()
    
    func setupConstraints() {
        
        let bottomView = UIView()
        
        contentView.addSubview(sendButton)
        contentView.addSubview(attachButton)
        contentView.addSubview(inputTextField)
        
        addSubview(contentView)
        addSubview(bottomView)
        
        // For iPhone X layout added empty bottomView
        bottomView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.height.equalTo(UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0)
            } else {
               make.height.equalTo(0.0)
            }
        }
        
        //chatDetailVC!.view.safeAreaLayoutGuide.snp.bottomMargin
        contentView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        sendButton.snp.makeConstraints { (make) in
            make.right.equalTo(-8.0)
            make.top.equalTo(contentView.snp.top).offset(8.0)
            make.width.equalTo(sendButton.snp.height).multipliedBy(1/1)
        }
        
        attachButton.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.top.equalTo(contentView.snp.top).offset(10)
            make.width.equalTo(attachButton.snp.height).multipliedBy(1/1)
        }
        
        inputTextField.snp.makeConstraints { (make) in
            make.right.equalTo(sendButton.snp.left).offset(-8.0)
            make.top.equalTo(contentView.snp.top).offset(7.0)
            make.bottom.equalTo(bottomView.snp.top).offset(-7.0)
            make.left.equalTo(attachButton.snp.right).offset(16.0)
        }
        //inputTextField.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageInputBarView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: inputTextField.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        chatDetailVC?.changeInputBarViewFrame(height: estimatedSize.height + 14)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            sendButtonState = .text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите сообщение.."
            textView.textColor = UIColor.lightGray
            sendButtonState = .audio
        }
    }
}

