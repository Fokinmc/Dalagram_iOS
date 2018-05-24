//
//  MessageCell.swift
//  Dalagram
//
//  Created by Toremurat on 22.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class TextMessageCell: BaseCollectionCell {
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.text = "Simple message"
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        // Customization
        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 5.0
        
        // Constraints
        addSubview(textView)
        
        textView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
    }
}
