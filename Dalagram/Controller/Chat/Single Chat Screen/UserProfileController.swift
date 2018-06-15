//
//  UserProfileController.swift
//  Dalagram
//
//  Created by Toremurat on 10.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class UserProfileController: UITableViewController {

    // MARK: - IBOutlets
    
    // MARK: - Variables
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Контакная информация"
        configureUI()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        
    }

}

extension UserProfileController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
}
