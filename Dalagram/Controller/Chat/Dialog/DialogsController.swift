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
import SwipeCellKit

class DialogsController: UITableViewController {

    // MARK: - UIElements
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Поиск по сообщениям и людям"
        searchBar.delegate = self
        searchBar.sizeToFit()
        return searchBar
    }()
    
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
        socketConnectionEvents()
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: AppManager.loadDialogsNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SocketIOManager.shared.socket.off("message")
        listenMessageUpdates()
    }
    
    deinit {
        notificationToken?.invalidate()
        NotificationCenter.default.removeObserver(self, name: AppManager.loadDialogsNotification, object: nil)
    }
    
    // MARK: Listen Socket Connection Evenets
    
    func socketConnectionEvents() {
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
        
        viewModel.socketMessageEvent { [weak self] in
            self?.tableView.reloadData()
        }
        
        notificationToken = viewModel.dialogs?.observe({ [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                print("initial")
            case .update(_):
                print("update")
                tableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        })
    }
    
    // MARK: - Load Data
    
    @objc func loadData() {
        viewModel.getUserDialogs { [weak self] in
            guard let vc = self else { return }
            vc.showNoContentView(dataCount: vc.viewModel.dialogs?.count ?? 0)
        }
    }
    
    // MARK: - Create Chat UIBarButton Action
    
    @objc func createChatAction() {
        let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.darkBlueNavColor
        let groupAction = UIAlertAction(title: "Новая группа", style: .default) { (act) in
            let vc = NewGroupController()
            vc.title = "Новая группа"
            vc.chatType = .group
            self.show(vc, sender: nil)
        }
        let channelAction = UIAlertAction(title: "Новый канал", style: .default) { (act) in
            let vc = NewGroupController()
            vc.chatType = .channel
            vc.title = "Новый канал"
            self.show(vc, sender: nil)
        }
        let singleAction = UIAlertAction(title: "Новый чат", style: .default) { (act) in
            let vc = ChatContactsController(chatType: .single)
            vc.title = "Новый диалог"
            self.show(vc, sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(groupAction)
        alert.addAction(channelAction)
        alert.addAction(singleAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showDeleteActionSheet(id: String, dialogItem: DialogItem) {
        let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.darkBlueNavColor
        let deleteAction = UIAlertAction(title: "Удалить", style: .default) { (act) in
            self.viewModel.removeDialog(by: id, dialogItem: dialogItem)
        }
        let clearAction = UIAlertAction(title: "Очистить", style: .default) { (act) in
            self.viewModel.clearDialog(by: id)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
