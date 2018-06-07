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
        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    let bubleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightBlueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 1.0
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        return view
    }()
    
    var bubleRightAnchor: NSLayoutConstraint?
    var bubleLeftAnchor: NSLayoutConstraint?
    var bubleWidthAnchor: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        
        // Constraints
        addSubview(bubleView)
        addSubview(textView)
        
        
        bubleRightAnchor = bubleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8.0)
        bubleLeftAnchor = bubleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8.0)
        if #available(iOS 11.0, *) {
            bubleLeftAnchor = bubleView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 8.0)
            bubleRightAnchor = bubleView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -8.0)
        }
       
        bubleRightAnchor?.isActive = true
        bubleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        bubleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubleWidthAnchor = bubleView.widthAnchor.constraint(equalToConstant: 200.0)
        bubleWidthAnchor?.isActive = true
        
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(bubleView).offset(8.0)
            make.right.equalTo(bubleView)
            make.top.equalToSuperview()
            make.height.equalToSuperview()
        }
    
    }
}
