//
//  UsersCollectionView.swift
//  Dalagram
//
//  Created by Toremurat on 02.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit

class UsersCollectionView: UIView {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 1.0
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(UsersCell.self)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension UsersCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UsersCell = collectionView.dequeReusableCell(for: indexPath)
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80.0, height: collectionView.frame.height)
    }
    
}

class UsersCell: BaseCollectionCell {
    
    let deleteIcon = UIImageView(image: #imageLiteral(resourceName: "icon_delete"))
    
    lazy var userImage: UIImageView = {
        let img = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width ))
        img.image = UIImage(named: "userprofile")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Zholayev Toremurat"
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    var userAvatarView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setupViews() {
        
        userAvatarView.addSubview(userImage)
        userAvatarView.addSubview(deleteIcon)
        
        addSubview(nameLabel)
        addSubview(userAvatarView)
        userImage.layer.cornerRadius = (frame.width * 0.6)/2
        
        userImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(8.0)
            make.height.equalTo(frame.width * 0.65)
            make.width.equalTo(userImage.snp.height).multipliedBy(1/1)
            make.bottom.equalTo(0.0)
        }
        
        deleteIcon.snp.makeConstraints { (make) in
            make.trailing.equalTo(userImage)
            make.top.equalTo(userImage.snp.top)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-8.0)
            make.left.equalTo(8.0)
            make.right.equalTo(-8.0)
        }
        
        userAvatarView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(nameLabel.snp.top)
        }
        
    }
}
