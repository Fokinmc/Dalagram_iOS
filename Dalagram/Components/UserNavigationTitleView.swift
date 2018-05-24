//
//  File.swift
//  Dalagram
//
//  Created by Toremurat on 24.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit

class UserNavigationTitleView: UIView {
    
    var userAvatarView: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "userpic"))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Zholayev Toremurat"
        label.textColor = UIColor.white
        return label
    }()
    
    var userStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "last seen"
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = UIFont.systemFont(ofSize: 13.0)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        addSubview(userAvatarView)
        addSubview(userNameLabel)
        addSubview(userStatusLabel)
        
        userAvatarView.snp.makeConstraints { (make) in
            make.left.equalTo(0.0)
            make.top.equalTo(0.0)
            make.bottom.equalTo(-3.0)
            make.width.equalTo(userAvatarView.snp.height).multipliedBy(1/1)
        }
        
        userNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userAvatarView.snp.right).offset(16.0)
            make.top.equalTo(userAvatarView.snp.top)
            make.right.equalTo(-16.0)
        }
        
        userStatusLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(userNameLabel)
            make.bottom.equalTo(userAvatarView.snp.bottom)
        }
        
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
