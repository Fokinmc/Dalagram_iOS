//
//  ChatCell.swift
//  Dalagram
//
//  Created by Toremurat on 21.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var iconMute: UIImageView!
    @IBOutlet weak var iconMark: UIButton!
    
    var prefix: String = "" {
        didSet {
            prefixLabel.isHidden = prefix.isEmpty ? true : false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        countLabel.layer.cornerRadius = countLabel.frame.width/2
        countLabel.clipsToBounds = true
        countLabel.isHidden = true
        selectionStyle = .none
    }
    
    func setupDialog(_ data: Dialog) {
        if let item = data.dialogItem {
           
            userNameLabel.text  = !item.contact_user_name.isEmpty ? item.contact_user_name : item.chat_name.isEmpty ? item.phone : item.chat_name
            
            dateLabel.text      = item.chat_date
            messageLabel.text   = item.chat_text
            
            if item.group_id != 0 || item.channel_id != 0 {
                userNameLabel.text = item.chat_name
                messageLabel.text = item.chat_text
                if item.chat_kind == "action" {
                     messageLabel.text = item.action_name
                }
            }
            if item.avatar.isEmpty {
                if let firstLetter = item.chat_name.first {
                    prefix = firstLetter.description.capitalized
                    prefixLabel.text = prefix
                }
            } else {
                prefix = ""
            }
            userImageView.kf.setImage(with: URL(string: item.avatar), placeholder: UIImage(named: "bg_gradient_\(arc4random_uniform(4))"))
        }
        countLabel.text = "\(data.messagesCount)"
        countLabel.isHidden = data.messagesCount == 0 ? true : false
    }
    
}
