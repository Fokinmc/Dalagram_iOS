//
//  NewChatController.swift
//  Dalagram
//
//  Created by Toremurat on 01.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class NewChatController: UITableViewController {
    
    let viewModel = ContactsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Новый диалог"
        configureUI()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        
        // MARK: Main UI
        view.backgroundColor = UIColor.white
       
        //MARK: TableView
        let headerView = UsersCollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 130.0))
        tableView.register(GroupContactCell.self)
        tableView.tableHeaderView = headerView
        
        // MARK: UIBarButtonItem
        let plusButton = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(nextButtonAction))
        self.navigationItem.rightBarButtonItem = plusButton
    }
    
    // MARK: - Next Button Pressed
    
    @objc func nextButtonAction() {
        
    }
}

extension NewChatController {
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.aplhabet.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupContactCell = tableView.dequeReusableCell(for: indexPath)
        return cell
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.aplhabet
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.aplhabet[section]
    }
}
