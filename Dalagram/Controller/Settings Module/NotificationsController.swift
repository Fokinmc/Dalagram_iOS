//
//  NotificationsController.swift
//  Dalagram
//
//  Created by Toremurat on 14.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class NotificationsController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Уведомления"
        self.tableView.tableFooterView = UIView()
        setEmptyBackTitle()
    }
   
}

// MARK: - TableView Delegate

extension NotificationsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1: // >> Sound
            let vc = NotificationSoundsController()
            self.show(vc, sender: nil)
        default:
            break
        }
    }
}

