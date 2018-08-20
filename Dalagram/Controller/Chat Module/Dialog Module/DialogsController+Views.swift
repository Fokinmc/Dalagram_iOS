//
//  DialogsController+ViewConfiguration.swift
//  Dalagram
//
//  Created by Toremurat on 10.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

// MARK: - Configuring UI

extension DialogsController {
    
    func configureUI() {
        
        // MARK: - Navigation Bar
        setEmptyBackTitle()
        setBlueNavBar()
        
        //MARK: - TableView Configurations
        tableView.tableHeaderView = searchBar
        tableView.registerNib(ChatCell.self)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.init(white: 0.85, alpha: 1.0)
        
        // MARK: - UIBarButtonItem Configurations
        let createItem = UIBarButtonItem(image: UIImage(named: "icon_create"), style: .plain, target: self, action: #selector(createChatAction))
        createItem.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = createItem
        
        // MARK: - UINavigationBar TitleView Configurations
        let titleView = UIView()
        titleView.addSubview(navigationTitle)
        navigationTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        titleView.addSubview(navigationLoader)
        navigationLoader.snp.makeConstraints { (make) in
            make.left.equalTo(navigationTitle.snp.right).offset(8.0)
            make.centerY.equalTo(navigationTitle)
        }
        self.navigationItem.titleView = titleView
        view.backgroundColor = UIColor.init(white: 1.0, alpha: 0.98)
    }
}
