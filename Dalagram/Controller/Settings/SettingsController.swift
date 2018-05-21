//
//  SettingsController.swift
//  Dalagram
//
//  Created by Toremurat on 21.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {

    // MARK: - IBOutlets
    
    // MARK: - Variables
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBlueNavBar()
        configureUI()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.lightGrayColor
        tableView.tableFooterView = footerView
    }

}

// MARK: TableView Delegate & DataSource

extension SettingsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
}
