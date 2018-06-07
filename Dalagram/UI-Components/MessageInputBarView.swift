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
            attachButton.addTarget(chatDetailVC, action: #selector(ChatController.sendButtonPressed), for: .touchUpInside)
        }
    }
    
    var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "icon_send"), for: .normal)
        return button
    }()
    
    var inputTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите сообщение.."
        field.backgroundColor = UIColor.white
        field.borderStyle = .roundedRect
        return field
    }()
    
    var attachButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "icon_attache"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func updateBottomConstaints(_ constant: CGFloat) {
        snp.updateConstraints { (make) in
            make.bottom.equalTo(constant)
        }
    }
    
    func setupConstraints() {
        
        let contentView = UIView()
        let bottomView = UIView()
        
        contentView.addSubview(sendButton)
        contentView.addSubview(attachButton)
        contentView.addSubview(inputTextField)
        
        addSubview(contentView)
        addSubview(bottomView)
        
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
            make.height.equalTo(48.0)
            make.bottom.equalTo(bottomView.snp.top)
        }
        

        sendButton.snp.makeConstraints { (make) in
            make.right.equalTo(-8.0)
            make.top.equalTo(3.0)
            make.bottom.equalTo(bottomView.snp.top).offset(-3.0)
            make.width.equalTo(sendButton.snp.height).multipliedBy(1/1)
        }
        
        attachButton.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.centerY.equalTo(contentView)
            make.width.equalTo(attachButton.snp.height).multipliedBy(1/1)
        }
        
        inputTextField.snp.makeConstraints { (make) in
            make.right.equalTo(sendButton.snp.left).offset(-8.0)
            make.top.equalTo(7.0)
            make.bottom.equalTo(bottomView.snp.top).offset(-7.0)
            make.left.equalTo(attachButton.snp.right).offset(16.0)
        }
        
//        // SELF Contraints
//        snp.makeConstraints { (make) in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.bottom.equalToSuperview()
//            if #available(iOS 11.0, *) {
//                make.height.equalTo((UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0) + 48.0)
//            } else {
//                make.height.equalTo(48.0)
//            }
//        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

