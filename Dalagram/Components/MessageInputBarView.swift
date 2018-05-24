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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1.0)
        setupConstraints()
    }
    
    func setupConstraints() {
        
        addSubview(sendButton)
        addSubview(inputTextField)
        
        sendButton.snp.makeConstraints { (make) in
            make.right.equalTo(-8.0)
            make.top.equalTo(3.0)
            make.bottom.equalTo(-3.0)
            make.width.equalTo(sendButton.snp.height).multipliedBy(1/1)
        }
        
        inputTextField.snp.makeConstraints { (make) in
            make.right.equalTo(sendButton.snp.left).offset(-8.0)
            make.top.equalTo(7.0)
            make.bottom.equalTo(-7.0)
            make.left.left.equalTo(16.0)
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

