//
//  InviteFriendCell.swift
//  Dalagram
//
//  Created by Toremurat on 20.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SnapKit

class InviteFriendsView: UIView {
    
    lazy var plusIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "icon_plus"))
        icon.contentMode = .center
        return icon
    }()
    
    lazy var inviteLabel: UILabel = {
        let label = UILabel()
        label.text = "Пригласить друзей"
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.textColor = UIColor.lightBlueColor
        return label
    }()
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.groupTableViewBackground
        return line
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        addSubview(plusIcon)
        addSubview(inviteLabel)
        addSubview(lineView)
        
        // Configure Constraints
        plusIcon.snp.makeConstraints { (make) in
            make.left.equalTo(10.0)
            make.top.equalTo(3.0)
            make.bottom.equalTo(-3.0)
            make.width.equalTo(plusIcon.snp.height).multipliedBy(1/1)
        }
        
        inviteLabel.snp.makeConstraints { (make) in
            make.left.equalTo(plusIcon.snp.right).offset(16.0)
            make.centerY.equalTo(plusIcon)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(0)
            make.height.equalTo(1.0)
        }
        
        //separatorInset = UIEdgeInsets(top: 0, left: 76.0, bottom: 0, right: 0)
    }
}
