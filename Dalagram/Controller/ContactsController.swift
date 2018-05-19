//
//  ContactsController.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class ContactsController: UITableViewController {

    // MARK: - IBOutlets
    fileprivate var searchBar: UISearchBar = UISearchBar()
    
    // MARK: - Variables
    
    // MARK: - Initializer
    
    static func instantiate() -> ContactsController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ID") as! ContactsController
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setBlueNavBar()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        
        view.backgroundColor = UIColor.white
        
        // SearchBar
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Поиск"
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        // TableView
        tableView.register(UINib.init(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        
        
    }
}
extension ContactsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section != 0 ? "A" : ""
    }
    

    
}
