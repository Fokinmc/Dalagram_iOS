//
//  ContactsController.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import Contacts
import RealmSwift

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
    
    // : isMainController resposible for reusing controller as contacts picker
    
    var isMainController: Bool = false
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        tableView.tableHeaderView = inviteFriendsView
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.registerNib(ContactCell.self)
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
            cell.setupSystemContact(contact, section: indexPath.section)
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            /// Need to pass dialogInfo and dialogId which is user_id + prefix "U" as User
            if let contact = RealmManager.shared.getObjects(type: Contact.self) {
                if let contactItem = contact[indexPath.row] as? Contact {
                    let contactInfo = DialogInfo(contact: contactItem)
                    let vc = ChatController(info: contactInfo, dialogId: String(contactItem.user_id) + "U")
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        default:
            break
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
