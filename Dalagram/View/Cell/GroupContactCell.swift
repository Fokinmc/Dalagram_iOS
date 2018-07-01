//
//  GroupContactCell.swift
//  Dalagram
//
//  Created by Toremurat on 03.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class GroupContactCell: UITableViewCell {
    
    lazy var markIcon: UIImageView = {
        let img = UIImageView(image: UIImage(named: "icon_mark"))
        img.isHidden = true
        return img
    }()
    
    lazy var userPrefix: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.textColor = UIColor.white
        label.text = ""
        label.isHidden = true
        return label
    }()
    
    lazy var userImage: UIImageView = {
        let img = UIImageView(frame: CGRect.zero)
        img.image = UIImage(named: "userpic")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
    lazy var userName: UILabel = {
        let label = UILabel()
        label.text = "Zholayev Toremurat"
        label.font = UIFont.systemFont(ofSize: 17.0)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset.left = userImage.frame.width + 32
        userImage.layer.cornerRadius = userImage.frame.width/2
    }
    
    func setupViews() {
        addSubview(userImage)
        addSubview(userName)
        addSubview(markIcon)
        userImage.addSubview(userPrefix)
        
        userPrefix.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        userImage.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.top.equalTo(6)
            make.bottom.equalTo(-6)
            make.width.equalTo(userImage.snp.height).multipliedBy(1/1)
        }
        
        markIcon.snp.makeConstraints { (make) in
            make.bottom.equalTo(userImage.snp.bottom).offset(0)
            make.right.equalTo(userImage.snp.right).offset(2)
        }
        
        userName.snp.makeConstraints { (make) in
            make.left.equalTo(userImage.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        
    }
    
    func setupContact(_ data: Contact) {
        let userNameText = data.user_name != "" ? data.user_name : data.contact_name
        userName.text = userNameText
        if data.avatar == "http://dalagram.bugingroup.com/media/default-user.jpg" {
            userImage.image = #imageLiteral(resourceName: "bg_gradient_2")
        } else {
            userImage.kf.setImage(with: URL(string: data.avatar), placeholder: #imageLiteral(resourceName: "bg_gradient_2"))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
