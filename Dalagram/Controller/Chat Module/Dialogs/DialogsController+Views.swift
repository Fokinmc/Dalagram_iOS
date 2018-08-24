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
    
    // MARK: - Configure Main UI
    
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
    
    // MARK: - Create Chat UIBarButton Action
    
    @objc func createChatAction() {
        let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.darkBlueNavColor
        let groupAction = UIAlertAction(title: "Новая группа", style: .default) { (act) in
            let vc = NewGroupController()
            vc.title = "Новая группа"
            vc.chatType = .group
            self.show(vc, sender: nil)
        }
        let channelAction = UIAlertAction(title: "Новый канал", style: .default) { (act) in
            let vc = NewGroupController()
            vc.chatType = .channel
            vc.title = "Новый канал"
            self.show(vc, sender: nil)
        }
        let singleAction = UIAlertAction(title: "Новый чат", style: .default) { (act) in
            let vc = ChatContactsController(chatType: .single)
            vc.title = "Новый диалог"
            self.show(vc, sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(groupAction)
        alert.addAction(channelAction)
        alert.addAction(singleAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - SwipeCellKit Action
    
    @objc func showDeleteActionSheet(id: String, dialogItem: DialogItem) {
        let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.darkBlueNavColor
        let deleteAction = UIAlertAction(title: "Удалить", style: .default) { (act) in
            self.viewModel.removeDialog(by: id, dialogItem: dialogItem)
        }
        let clearAction = UIAlertAction(title: "Очистить", style: .default) { (act) in
            self.viewModel.clearDialog(by: id, dialogItem: dialogItem)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
