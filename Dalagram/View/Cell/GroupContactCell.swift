//
//  GroupContactCell.swift
//  Dalagram
//
//  Created by Toremurat on 03.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class GroupContactCell: UITableViewCell {
    
    var markIcon: UIImageView = {
        let img = UIImageView(image: UIImage(named: "icon_mark"))
        return img
    }()
    
    var userImage: UIImageView = {
        let img = UIImageView(frame: CGRect.zero)
        img.image = UIImage(named: "userpic")
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    var userName: UILabel = {
        let label = UILabel()
        label.text = "Zholayev Toremurat"
        
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(userImage)
        addSubview(userName)
        addSubview(markIcon)
        userImage.layer.cornerRadius = userImage.frame.width/2
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
