//
//  NewChatController.swift
//  Dalagram
//
//  Created by Toremurat on 04.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import RealmSwift

typealias EditGroupCompletionBlock = () -> Void

class ChatContactsController: UITableViewController {

    // MARK: - IBOutlets
    
    fileprivate var searchBar: UISearchBar = UISearchBar()
    
    // MARK: - Variables
    
    let viewModel = ContactsViewModel()
    var chatType: DialogType = .single
    var dialogInfo: DialogInfo?
    
    var groupCompletion: EditGroupCompletionBlock! = nil
    
    // MARK: - Initializer
    
    convenience init(chatType: DialogType, dialogInfo: DialogInfo? = nil) {
        self.init()
        self.chatType = chatType
        self.dialogInfo = dialogInfo
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setBlueNavBar()
        
        viewModel.fetchContacts { [weak self] in
            self?.viewModel.getContacts(onSuccess: {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
        }
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        view.backgroundColor = UIColor.white
        
        //MARK: SearchBar
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Поиск контактов"
        searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchBar
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.registerNib(ContactCell.self)
   
    }
    
}
extension ChatContactsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RealmManager.shared.getCount(Contact.self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactCell = tableView.dequeReusableCell(for: indexPath)
        if let contact = RealmManager.shared.getObjects(type: Contact.self) {
            cell.setupRegisteredContact(contact[indexPath.row] as! Contact)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch chatType {
        case .single:
            // Need to pass dialogInfo and dialogId which is user_id + prefix "U" as User (28U)
            if let contacts = RealmManager.shared.getObjects(type: Contact.self) {
                if let contact = contacts[indexPath.row] as? Contact {
                    let contactInfo = DialogInfo(contact: contact)
                    let vc = ChatController(info: contactInfo, dialogId: String(contact.user_id) + "U")
                    vc.hidesBottomBarWhenPushed = true
                    self.show(vc, sender: nil)
                }
            }
        case .group:
            if let contacts = RealmManager.shared.getObjects(type: Contact.self) {
                if let contact = contacts[indexPath.row] as? Contact {
                    if let groupInfo = dialogInfo {
                        NetworkManager.makeRequest(.addGroupMember(group_id: groupInfo.group_id, user_id: contact.user_id), success: { [weak self] (json) in
                            guard let vc = self else { return }
                            WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
                            vc.navigationController?.popViewController(animated: true)
                            vc.groupCompletion()
                        })
                    }
                }
            }
            
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}
