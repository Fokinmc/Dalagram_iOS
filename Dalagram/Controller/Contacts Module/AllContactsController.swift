//
//  ViewController.swift
//  Dalagram
//
//  Created by Toremurat on 31.08.2018.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import Contacts
import RealmSwift

typealias AllContactsCompletion = (_ selectedContact: ContactFacade) -> Void

class AllContactsController: UITableViewController {

    // MARK: - IBOutlets
    
    fileprivate var searchBar: UISearchBar = UISearchBar()
    
    lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(closeButtonAction))
        button.tintColor = UIColor.white
        return button
    }()
    
    // MARK: - Variables
    
    let viewModel = ContactsViewModel()
    var completionBlock: AllContactsCompletion! = nil
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Выберите"
        
        configureUI()
        setBlueNavBar()
        
        viewModel.fetchContacts { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
            self?.viewModel.getContacts(onSuccess: {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
        }
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        setEmptyBackTitle()
        view.backgroundColor = UIColor.white
        
        //MARK: SearchBar
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Поиск"
        searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchBar
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.registerNib(ContactCell.self)
        
        self.navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc func closeButtonAction() {
        self.dismissController()
    }
}

extension AllContactsController {
    
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
            cell.setupSystemContact(contact, section: indexPath.section)
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let contact = RealmManager.shared.getObjects(type: Contact.self) {
                if let contactObj = contact[indexPath.row] as? Contact {
                    let systemContact = ContactFacade(dalagramContact: contactObj)
                    completionBlock(systemContact)
                    dismissController()
                }
                
            }
        default:
            let contact = viewModel.phoneContacts[indexPath.section - 1].value[indexPath.row]
            let phoneContact = ContactFacade(phoneContact: contact)
            completionBlock(phoneContact)
            dismissController()
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.letters
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let sectioView = view as! UITableViewHeaderFooterView
        sectioView.textLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.init(0))
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
