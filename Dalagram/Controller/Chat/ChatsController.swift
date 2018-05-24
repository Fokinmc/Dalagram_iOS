//
//  ChatsController.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class ChatsController: UITableViewController {

    // MARK: - IBOutlets
    
    // MARK: - Variables
    
    // MARK: - Initializer
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setBlueNavBar()
        setEmptyBackTitle()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        
        // MARK: View
        view.backgroundColor = UIColor.white
        tableView.registerNib(ChatCell.self)
        
        // MARK: - UIBarButtonItem
        let createItem = UIBarButtonItem(image: UIImage(named: "icon_create"), style: .plain, target: self, action: #selector(createChatAction))
        createItem.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = createItem
        
    }
    
    // MARK: - Create Chat UIBarButton Action
    
    @objc func createChatAction() {
        
    }

}

// MARK: - TableView Delegate & DataSource

extension ChatsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatCell = tableView.dequeReusableCell(for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatDetailController()
        vc.hidesBottomBarWhenPushed = true
        self.show(vc, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}
