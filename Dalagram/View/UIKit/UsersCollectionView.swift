//
//  UsersCollectionView.swift
//  Dalagram
//
//  Created by Toremurat on 02.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class UsersCollectionView: UIView {
    
    var viewModel: ContactsViewModel!
    var data: [Contact] = []
    let disposeBag = DisposeBag()
    
    var newChatVC: NewChatController?  {
        didSet {
            viewModel = newChatVC?.viewModel
            setupEvents()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 1.0
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(UsersCell.self)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false

        return collectionView
    }()
    
    lazy var placehoderLabel: UILabel = {
        let label = UILabel()
        label.text = "Чтобы начать диалог необходимо выбрать контакты из списка"
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        label.numberOfLines = 5
        label.font = UIFont.systemFont(ofSize: 15.0)
        return label
    }()
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.groupTableViewBackground
        return line
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupEvents() {
        viewModel.selectedContacts.asObservable().subscribe(onNext: { [unowned self] (contacts) in
            self.placehoderLabel.isHidden = !contacts.isEmpty
            self.data.removeAll()
            for value in contacts {
                self.data.append(value.value)
            }
            self.collectionView.reloadData()
            print(self.viewModel.selectedContacts.value)
        }).disposed(by: disposeBag)
    }
    
    func setupViews() {
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(1.0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(lineView.snp.top)
        }
        
        addSubview(placehoderLabel)
        placehoderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20.0)
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UsersCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UsersCell = collectionView.dequeReusableCell(for: indexPath)
        cell.setupUser(data[indexPath.row])
        cell.deleteIcon.isHidden = indexPath.row == (data.count - 1) ? false : true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == data.count - 1 {
            /// Selected Contacts Dictionaty where:
            /// user_id - key
            /// Contact - value
            
            if let lastIndex = viewModel.selectedIndexArray.last {
                print(lastIndex)
                viewModel.selectedIndex.value = lastIndex
                viewModel.selectedContacts.value.removeValue(forKey: lastIndex)
                viewModel.selectedIndexArray.removeLast()
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90.0, height: collectionView.frame.height)
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
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Zholayev Toremurat"
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    lazy var userAvatarView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setupViews() {
        deleteIcon.isHidden = true
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
            make.trailing.equalTo(userImage).offset(3)
            make.top.equalTo(userImage.snp.top).offset(-3)
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
    
    func setupUser(_ data: Contact) {
        nameLabel.text = data.user_name != "" ? data.user_name : data.contact_name
        userImage.kf.setImage(with: URL(string: data.avatar))
    }
}
