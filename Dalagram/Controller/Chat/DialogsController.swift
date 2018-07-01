//
//  DialogsController.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SVProgressHUD
import RealmSwift

class DialogsController: UITableViewController {

    // MARK: - UIElements
    
    fileprivate var searchBar: UISearchBar {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Поиск по сообщениям и людям"
        searchBar.sizeToFit()
        return searchBar
    }
    
    lazy var navigationTitle: UILabel = {
        let label = UILabel()
        label.text = "Чаты"
        label.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.init(0.01))
        label.textColor = UIColor.white
        return label
    }()
    
    lazy var navigationLoader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loader.hidesWhenStopped = true
        return loader
    }()
    
    // MARK: - Variables
    
    var viewModel = DialogsViewModel()
    var notificationToken: NotificationToken? = nil
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadData()
        connetToSocket()
        listenMessageUpdates()
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name("loadDialogsFromServer"), object: nil)
        
    }
    
    deinit {
        notificationToken?.invalidate()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("loadDialogsFromServer"), object: nil)
    }
    
    // MARK: Connect to socket
    
    func connetToSocket() {
        viewModel.connectToSocket(onConnect: { [weak self] in
            self?.navigationTitle.text = "Чаты"
            self?.navigationLoader.stopAnimating()
        }, onDisconnect: { [weak self] in
            guard let vc = self else { return }
            vc.navigationTitle.text = "Соединение"
            vc.navigationLoader.startAnimating()
        })
    }
    
    // MARK: - Socket Event: Message
    
    func listenMessageUpdates() {
        viewModel.socketMessageEvent()
        viewModel.messageEventHandler = { [weak self] in
            // need to update model and reload. not make request
            self?.tableView.reloadData()
        }
        
        notificationToken = viewModel.dialogs?.observe({ [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_):
                print("update")
                //tableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        })
    }
    
    // MARK: - Load Data
    
    @objc func loadData() {
        /// Dialogs loading to Realm database
        viewModel.getUserDialogs { [weak self] in
            guard let vc = self else { return }
            vc.tableView.reloadData()
            vc.showNoContentView(dataCount: vc.viewModel.dialogs?.count ?? 0)
        }
    }
    
    // MARK: - Create Chat UIBarButton Action
    
    @objc func createChatAction() {
        let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.darkBlueNavColor
        let groupAction = UIAlertAction(title: "Новая группа", style: .default) { (act) in
            let vc = NewChatController()
            self.show(vc, sender: nil)
        }
        let channelAction = UIAlertAction(title: "Новый канал", style: .default) { (act) in
            let vc = CreateChannelController.fromStoryboard()
            self.show(vc, sender: nil)
        }
        let singleAction = UIAlertAction(title: "Новый чат", style: .default) { (act) in
            print(0)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(groupAction)
        alert.addAction(channelAction)
        alert.addAction(singleAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: - TableView Delegate & DataSource

extension DialogsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dialogs?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatCell = tableView.dequeReusableCell(for: indexPath)
        cell.iconMute.isHidden = indexPath.row % 3 == 0 ? false : true
        cell.setupDialog(viewModel.dialogs![indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // FIXME:  OPTIONALS FORCE UNWRAPPING
        let currentDialog = viewModel.dialogs![indexPath.row]
        let chatInfo = DialogInfo(dialog: currentDialog.dialogItem!)
        
        if chatInfo.user_id != 0 {
            let vc = ChatController(type: .single, info: chatInfo, dialogId: currentDialog.id)
            vc.hidesBottomBarWhenPushed = true
            self.show(vc, sender: nil)
        } else if chatInfo.group_id != 0 {
            let vc = ChatController(type: .group, info: chatInfo, dialogId: currentDialog.id)
            vc.hidesBottomBarWhenPushed = true
            self.show(vc, sender: nil)
        }
        viewModel.resetMessagesCounter(for: currentDialog)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Configuring UI

extension DialogsController {

    func configureUI() {
        setEmptyBackTitle()
        setBlueNavBar()
        view.backgroundColor = UIColor.init(white: 1.0, alpha: 0.98)
        
        //MARK: SearchBar
        tableView.tableHeaderView = searchBar
        
        tableView.registerNib(ChatCell.self)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.init(white: 0.85, alpha: 1.0)

        // MARK: - UIBarButtonItem Configurations
        let createItem = UIBarButtonItem(image: UIImage(named: "icon_create"), style: .plain, target: self, action: #selector(createChatAction))
        createItem.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = createItem
        
        let editItem = UIBarButtonItem(title: "Изм.", style: .plain, target: self, action: nil)
        editItem.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = editItem
        
        // MARK: - UINavigationBar TitleView Configurations
        let titleView = UIView()
        titleView.addSubview(navigationTitle)
        navigationTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        titleView.addSubview(navigationLoader)
        navigationLoader.snp.makeConstraints { (make) in
            make.left.equalTo(navigationTitle.snp.right).offset(8.0)
            make.centerY.equalTo(navigationTitle)
        }
        self.navigationItem.titleView = titleView
    }
}
