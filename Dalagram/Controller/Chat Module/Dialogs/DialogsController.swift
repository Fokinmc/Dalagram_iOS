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
        socketTypingEvent()
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
        // Listen "message" event and update tableView
        viewModel.socketMessageEvent { [weak self] in
            self?.tableView.reloadData()
        }
        
        // Updating No Content View
        if viewModel.dialogs?.count != 0 {
            showNoContentView(dataCount: viewModel.dialogs?.count ?? 0)
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
    
    // MARK: - Recieve Socket Event "Typing"
    
    func socketTypingEvent() {
        SocketIOManager.shared.socket.on("typing") { (data, ack) in
            if let data = data[0] as? NSDictionary {
                if let sender_id = data["sender_id"] as? Int, let dialog_id = data["dialog_id"] as? String {
                    if dialog_id.contains("U") { // User
                        self.showTypingIndicator(dialog_id: "\(sender_id)U")
                    } else if dialog_id.contains("G") { // Group
                        self.showTypingIndicator(dialog_id: dialog_id)
                        
                    } else if dialog_id.contains("C") { // Channel
                        self.showTypingIndicator(dialog_id: dialog_id)
                    }
                }
            }
        }
    }
    
    func showTypingIndicator(dialog_id: String) {
        guard let dialogs = self.viewModel.dialogs else { return }
        for index in 0 ..< dialogs.count {
            if dialog_id == dialogs[index].id {
                self.startTypingIndicator(isTyping: true, cellIndex: index)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: { [weak self] in
                    guard let vc = self else { return }
                    vc.startTypingIndicator(isTyping: false, cellIndex: index, lastMessage: dialogs[index].dialogItem!.chat_text)
                })
            }
        }
    }
    
    func startTypingIndicator(isTyping: Bool, cellIndex: Int, lastMessage: String = "") {
        let index = IndexPath.init(row: cellIndex, section: 0)
        if let cell = self.tableView.cellForRow(at: index) as? ChatCell {
            cell.messageLabel.text = isTyping ? "Печатает..." : lastMessage
        }
    }
    
    // MARK: - Load Data
    
    @objc func loadData() {
        viewModel.getUserDialogs { [weak self] in
            guard let vc = self else { return }
            vc.showNoContentView(dataCount: vc.viewModel.dialogs?.count ?? 0)
        }
    }
}
