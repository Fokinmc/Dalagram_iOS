//
//  NotificationSoundsController.swift
//  Dalagram
//
//  Created by Toremurat on 14.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class NotificationSoundsController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Звук уведомления"
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor.groupTableViewBackground
    }
    
}

// MARK: - TableView Delegate

extension NotificationSoundsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "SoundCell")
        cell.textLabel?.text = "Sample Sound"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    
}
