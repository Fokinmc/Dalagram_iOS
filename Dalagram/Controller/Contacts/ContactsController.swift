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
    fileprivate let inviteCellIndetifier = InviteFriendCell.defaultReuseIdentifier
    
    // MARK: - Variables
    let aplhabet: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setBlueNavBar()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
       
        view.backgroundColor = UIColor.white
        
        //MARK: SearchBar
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Поиск"
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        //MARK: TableView
        tableView.register(InviteFriendCell.self)
        tableView.registerNib(ContactCell.self)
        
        // MARK: UIBarButtonItem
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        plusButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = plusButton
        
        // MARK:
        
    }
}
extension ContactsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return aplhabet.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0 {
            let cell: InviteFriendCell = tableView.dequeReusableCell(for: indexPath)
            return cell
        } else {
            let cell: ContactCell = tableView.dequeReusableCell(for: indexPath)
            return cell
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.aplhabet
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section != 0 ? self.aplhabet[section - 1] : ""
    }
    

    
}
