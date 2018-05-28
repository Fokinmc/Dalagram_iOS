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

    var chatDetailVC: ChatDetailController?  {
        didSet {
            sendButton.addTarget(chatDetailVC, action: #selector(ChatDetailController.sendButtonPressed), for: .touchUpInside)
            attachButton.addTarget(chatDetailVC, action: #selector(ChatDetailController.sendButtonPressed), for: .touchUpInside)
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
    }
    
    func setupConstraints() {
        
        snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(48.0)
            
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(chatDetailVC!.view.safeAreaLayoutGuide.snp.bottomMargin)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        addSubview(sendButton)
        addSubview(attachButton)
        addSubview(inputTextField)

        sendButton.snp.makeConstraints { (make) in
            make.right.equalTo(-8.0)
            make.top.equalTo(3.0)
            make.bottom.equalTo(-3.0)
            make.width.equalTo(sendButton.snp.height).multipliedBy(1/1)
        }
        
        attachButton.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.centerY.equalToSuperview()
            make.width.equalTo(attachButton.snp.height).multipliedBy(1/1)
        }
        
        inputTextField.snp.makeConstraints { (make) in
            make.right.equalTo(sendButton.snp.left).offset(-8.0)
            make.top.equalTo(7.0)
            make.bottom.equalTo(-7.0)
            make.left.equalTo(attachButton.snp.right).offset(16.0)
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

