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
    
    lazy var usersCollectionView: UsersCollectionView = {
        let header = UsersCollectionView()
        header.newChatVC = self
        return header
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Поиск по контактам"
        searchBar.sizeToFit()
        return searchBar
    }()
    
    let viewModel = ContactsViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Новый диалог"
        configureUI()
        
        viewModel.getContacts(onSuccess: { [weak self] in
            DispatchQueue.main.async { self?.tableView.reloadData() }
        })
        usersCollectionView.viewModel.selectedIndex.asObservable().subscribe(onNext: { [unowned self] (index) in
            self.deselectContactCell(indexPath: IndexPath.init(row: index, section: 0), state: .none)
        }).disposed(by: disposeBag)
        
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        setEmptyBackTitle()
        view.backgroundColor = UIColor.white
        
        //MARK: TableView
        tableView.register(GroupContactCell.self)
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = true
        tableView.separatorColor = UIColor.groupTableViewBackground
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180))
        tableView.tableHeaderView = headerView
        
        headerView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        headerView.addSubview(usersCollectionView)
        usersCollectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
        }
        
        
        // MARK: UIBarButtonItem
        let plusButton = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(nextButtonAction))
        self.navigationItem.rightBarButtonItem = plusButton
    }
    
    // MARK: - Next Button Pressed
    
    @objc func nextButtonAction() {
        if usersCollectionView.viewModel.selectedContacts.value.count != 1 {
            // Group Chat
            let vc = CreateGroupController.fromStoryboard()
            vc.viewModel = usersCollectionView.viewModel
            self.show(vc, sender: nil)
        } else {
            // Single Chat
            if let userData = usersCollectionView.viewModel.selectedContacts.value.first {
                let vc = ChatController(info: DialogInfo(contact: userData.value), dialogId: "none")
                vc.hidesBottomBarWhenPushed = true
                self.show(vc, sender: nil)
            }
        }
    }
    
    func deselectContactCell(indexPath: IndexPath, state: UITableViewCellAccessoryType) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? GroupContactCell {
            cell.accessoryType = state
            cell.markIcon.isHidden = state == .none ? true : false
        }
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
        if let contacts = RealmManager.shared.getObjects(type: Contact.self) {
            let contact = contacts[indexPath.row] as! Contact
            usersCollectionView.viewModel.selectedContacts.value[indexPath.row] = contact
            viewModel.selectedIndexArray.append(indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GroupContactCell
        cell.accessoryType = .none
        cell.markIcon.isHidden = true
        usersCollectionView.viewModel.selectedContacts.value.removeValue(forKey: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.gray
            header.textLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.init(0))
            header.backgroundView?.backgroundColor = UIColor.lightGrayColor
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "КОНТАКТЫ"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
