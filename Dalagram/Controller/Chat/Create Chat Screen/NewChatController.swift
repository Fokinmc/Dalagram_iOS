//
//  NewChatController.swift
//  Dalagram
//
//  Created by Toremurat on 01.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import RxSwift


class NewChatController: UITableViewController {
    
    lazy var usersView: UsersCollectionView = {
        let header = UsersCollectionView(frame: CGRect(x: 16, y: 0, width: view.frame.width, height: 130.0))
        return header
    }()
    
    let viewModel = ContactsViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Новый диалог"
        configureUI()
        
        viewModel.getContacts(onSuccess: {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        usersView.viewModel.selectedIndex.asObservable().subscribe(onNext: { [unowned self] (index) in
            print(index)
            self.deselectContactCell(indexPath: IndexPath.init(row: index, section: 0), state: .none)
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        setEmptyBackTitle()
        view.backgroundColor = UIColor.white
        
        //MARK: TableView
        tableView.register(GroupContactCell.self)
        tableView.tableHeaderView = usersView
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = true
        tableView.separatorColor = UIColor.groupTableViewBackground
        
        // MARK: UIBarButtonItem
        let plusButton = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(nextButtonAction))
        self.navigationItem.rightBarButtonItem = plusButton
    }
    
    // MARK: - Next Button Pressed
    
    @objc func nextButtonAction() {
        print(usersView.viewModel.selectedContacts.value)
        if usersView.viewModel.selectedContacts.value.count != 1 {
            let vc = EditChatController.fromStoryboard()
            vc.viewModel = usersView.viewModel
            self.show(vc, sender: nil)
        } else {
            
            if let userData = usersView.viewModel.selectedContacts.value.first {
                let vc = ChatController()
                vc.contact = userData.value
                self.show(vc, sender: nil)
            }
        }
    }
    
    func deselectContactCell(indexPath: IndexPath, state: UITableViewCellAccessoryType) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! GroupContactCell
        cell.accessoryType = state
        cell.markIcon.isHidden = state == .none ? true : false
    }
    
}


// MARK: - TableView Delegate & DataSource

extension NewChatController {
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RealmManager.shared.getCount(Contact.self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupContactCell = tableView.dequeReusableCell(for: indexPath)
        if let contact = RealmManager.shared.getObjects(type: Contact.self) {
            cell.setupContact(contact[indexPath.row] as! Contact)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GroupContactCell
        cell.accessoryType = .checkmark
        cell.markIcon.isHidden = false
        if let contact = RealmManager.shared.getObjects(type: Contact.self) {
            usersView.viewModel.selectedContacts.value[indexPath.row] = contact[indexPath.row] as! Contact
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GroupContactCell
        cell.accessoryType = .none
        cell.markIcon.isHidden = true
        usersView.viewModel.selectedContacts.value.removeValue(forKey: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
