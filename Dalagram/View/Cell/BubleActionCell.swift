//
//  DialogActionCell.swift
//  Dalagram
//
//  Created by Toremurat on 01.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class BubleActionCell: BaseCollectionCell {
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5)
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override func setupViews() {
        bgView.addSubview(nameLabel)
        addSubview(bgView)
        
        bgView.snp.makeConstraints { (make) in
            //make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(8.0)
            make.right.lessThanOrEqualTo(-8.0)
            make.centerX.equalToSuperview()
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(4)
            make.right.equalTo(-4)
        }
        
    }
    
    func setupData(_ data: DialogHistory) {
        var actionText = data.sender_name + " " + data.action_name
        if data.recipient_user_id != 0 {
            actionText += " \(data.recipient_name)"
        }
        nameLabel.text = actionText
    }
    
}
