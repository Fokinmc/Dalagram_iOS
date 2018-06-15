//
//  ContactsController.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import Contacts

class ContactsController: UITableViewController {

    // MARK: - IBOutlets
    fileprivate var searchBar: UISearchBar = UISearchBar()
    
    lazy var inviteFriendsView: InviteFriendsView = {
        let view = InviteFriendsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 55))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(inviteFriendsPressed))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    // MARK: - Variables
    let viewModel = ContactsViewModel()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setBlueNavBar()
        
        viewModel.fetchContacts {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        self.viewModel.getContacts(onSuccess: {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        print(RealmManager.shared.getCount(Contact.self))
        
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
       
        view.backgroundColor = UIColor.white
        
        //MARK: SearchBar
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Поиск"
        searchBar.sizeToFit()
        tableView.tableHeaderView = inviteFriendsView
        tableView.tableFooterView = UIView()
        
        //MARK: TableView
        tableView.registerNib(ContactCell.self)
        
        // MARK: UIBarButtonItem
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        plusButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = plusButton
        
    }
    
    // MARK: - Invite Friends Action
    
    @objc func inviteFriendsPressed() {
        let vc = InviteController()
        vc.viewModel = viewModel
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    

}
extension ContactsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.phoneContacts.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return RealmManager.shared.getCount(Contact.self)
        default:
            return viewModel.phoneContacts[section - 1].value.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactCell = tableView.dequeReusableCell(for: indexPath)
        if indexPath.section == 0 {
            if let contact = RealmManager.shared.getObjects(type: Contact.self) {
                cell.setupRegisteredContact(contact[indexPath.row] as! Contact)
            }
        } else {
            let contact = viewModel.phoneContacts[indexPath.section - 1].value[indexPath.row]
            cell.setupSystemContact(contact)
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let contact = RealmManager.shared.getObjects(type: Contact.self) {
                let vc = ChatController()
                vc.contact = contact[indexPath.row] as! Contact
                self.show(vc, sender: nil)
            }
        default:
            break
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.letters
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section != 0 ? viewModel.phoneContacts[section - 1].key : " "
    }
    
}
