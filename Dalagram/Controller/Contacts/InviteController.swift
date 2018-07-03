//
//  InviteController.swift
//  Dalagram
//
//  Created by Toremurat on 09.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class InviteController: UITableViewController {
    
    // MARK: - IBOutlets
    fileprivate var searchBar: UISearchBar = UISearchBar()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отправить", for: .normal)
        button.backgroundColor = UIColor.darkBlueNavColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Variables
    var viewModel: ContactsViewModel!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Выберите контакты"
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
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = true
        tableView.separatorColor = UIColor.groupTableViewBackground
        
        //MARK: TableView
        tableView.registerNib(ContactCell.self)
        
        // MARK: UIBarButtonItem
        let closeButton = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(closePressed))
        closeButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = closeButton
        
        let shareButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_share"), style: .plain, target: self, action: #selector(sharePressed))
        closeButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = shareButton
        
        // MARK: Send UIButton
        self.navigationController?.view.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(-calculateBottomSafeArea(0.0))
            make.height.equalTo(50.0)
        }
        
    }
    
    // MARK: - UIBarButton Actions
    
    @objc func closePressed() {
        self.dismissController()
    }
    
    @objc func sharePressed() {
        self.dismissController()
    }
    
    // MARK: - Send Button Action
    
    @objc func sendButtonPressed() {
        if let url = URL(string:"sms:+77087042247&body=Хей") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            UIApplication.shared.open(URL(string:"sms:")!, options: [:], completionHandler: nil)
        }
    }
}

extension InviteController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.phoneContacts.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.phoneContacts[section].value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactCell = tableView.dequeReusableCell(for: indexPath)
        let contact = viewModel.phoneContacts[indexPath.section].value[indexPath.row]
        cell.setupSystemContact(contact, section: indexPath.section)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.letters
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.phoneContacts[section].key
    }
    
}
