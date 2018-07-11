//
//  DialogsController+TableView.swift
//  Dalagram
//
//  Created by Toremurat on 10.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SwipeCellKit

// MARK: - DialogsController TableView Delegate & DataSource

extension DialogsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dialogs?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatCell = tableView.dequeReusableCell(for: indexPath)
        cell.delegate = self
        cell.setupDialog(viewModel.dialogs![indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // FIXME:  OPTIONALS FORCE UNWRAPPING
        let currentDialog = viewModel.dialogs![indexPath.row]
        let chatInfo = DialogInfo(dialog: currentDialog.dialogItem!)
        
        if chatInfo.user_id != 0 { // Single Chat
            let vc = ChatController(type: .single, info: chatInfo, dialogId: currentDialog.id)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if chatInfo.group_id != 0 { // Group Chat
            let vc = ChatController(type: .group, info: chatInfo, dialogId: currentDialog.id)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if chatInfo.channel_id != 0 { // Channel
            let vc = ChatController(type: .channel, info: chatInfo, dialogId: currentDialog.id)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        viewModel.resetMessagesCounter(for: currentDialog)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - SwipeCellKit Delegates

extension DialogsController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let dialog = viewModel.dialogs![indexPath.row]
        
        let deleteAction = SwipeAction(style: .default, title: "Удалить") { action, indexPath in
            if let item = dialog.dialogItem {
                self.showDeleteActionSheet(id: dialog.id, dialogItem: item)
            }
        }
        let muteAction = SwipeAction(style: .default, title: dialog.isMute ? "Вкл. звук" : "Без звука") { [weak self] action, indexPath in
            self?.viewModel.muteDialog(by: dialog.id)
        }
        deleteAction.font = UIFont.systemFont(ofSize: 13)
        deleteAction.hidesWhenSelected = true
        deleteAction.image = UIImage(named: "icon_trash")
        deleteAction.backgroundColor = UIColor.flatRedColor
        
        muteAction.font = UIFont.systemFont(ofSize: 13)
        muteAction.hidesWhenSelected = true
        muteAction.backgroundColor = UIColor.navBlueColor
        muteAction.image = UIImage(named: "icon_nosound")
        
        return [deleteAction, muteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.transitionStyle = .border
        return options
    }
}

