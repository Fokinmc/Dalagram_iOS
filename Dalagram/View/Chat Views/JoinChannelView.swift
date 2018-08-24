//
//  JoinChannelView.swift
//  Dalagram
//
//  Created by Toremurat on 05.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class JoinChannelView: UIView {

    var chatDetailVC: ChatController?  {
        didSet {
//            joinButton.addTarget(chatDetailVC, action: #selector(ChatController.joinChannelPressed), for: .touchUpInside)
        }
    }
    
    var joinButton: UIButton = {
        let button = UIButton()
        button.setTitle("Присоединиться", for: .normal)
        button.backgroundColor = UIColor.navBlueColor
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 0.8)
        setupConstraints()
    }
    
    
    func setupConstraints() {
        
        let bottomView = UIView()
        
        addSubview(joinButton)
        addSubview(bottomView)
        
        
        bottomView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.height.equalTo(UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0)
            } else {
                make.height.equalTo(0.0)
            }
        }
        
        joinButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(48.0)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
