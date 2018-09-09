//
//  ChatCell.swift
//  Dalagram
//
//  Created by Toremurat on 21.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SwipeCellKit

class ChatCell: SwipeTableViewCell {

    @IBOutlet weak var fileIconRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fileIconHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fileIcon: UIImageView!
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
    
    var fileConstraints: (right: CGFloat, height: CGFloat) = (0.0, 0.0) {
        didSet {
            fileIconRightConstraint.constant = fileConstraints.right
            fileIconHeightConstraint.constant = fileConstraints.height
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fileConstraints = (right: 0.0, height: 0.0)
        
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        countLabel.layer.cornerRadius = countLabel.frame.width/2
        countLabel.clipsToBounds = true
        countLabel.isHidden = true
        selectionStyle = .none
    }
    
    func setupDialog(_ data: Dialog) {
        if let item = data.dialogItem {
           
            userNameLabel.text  = !item.contact_user_name.isEmpty ? item.contact_user_name : item.chat_name.isEmpty ? item.phone : item.chat_name
            iconMute.isHidden   = item.is_mute == 0 ? true : false
            iconMark.isHidden   = item.is_own_last_message ? false : true
            
            dateLabel.text      = item.chat_date
            messageLabel.text   = item.chat_text
            
            // Read/Unread icon
            if item.is_read == 1 {
                iconMark.setImage(#imageLiteral(resourceName: "icon_mark_green"), for: .normal)
            } else {
                iconMark.setImage(#imageLiteral(resourceName: "icon_mark_double"), for: .normal)
            }
            
            // Action Message
            
            if item.group_id != 0 || item.channel_id != 0 {
                userNameLabel.text = item.chat_name
                if item.chat_kind == "action" {
                     messageLabel.text = item.action_name
                }
            }
            
            // Avatar Fullname initials
            if item.avatar.isEmpty {
                if let firstLetter = item.chat_name.first {
                    prefix = firstLetter.description.capitalized
                    prefixLabel.text = prefix
                }
            } else {
                prefix = ""
            }
       
            // File Message: Document, Video, Image
            if item.is_has_file == 1 {
                fileConstraints = (right: 4.0, height: 15.0)
                switch item.file_format {
                case "file":
                    fileIcon.image = UIImage(named: "icon_mini_doc")
                    messageLabel.text = "Документ"
                case "video":
                    fileIcon.image = UIImage(named: "icon_mini_video")
                    messageLabel.text = "Видеозапись"
                case "image":
                    fileIcon.image = UIImage(named: "icon_mini_photo")
                    messageLabel.text = "Изображение"
                default: break
                }
            } else {
                fileConstraints = (right: 0.0, height: 0.0)
                // Contact Message
                if item.is_contact == 1 {
                    fileIcon.image = UIImage(named: "icon_mini_contact")
                    messageLabel.text = "Контакт"
                    fileConstraints = (right: 4.0, height: 15.0)
                } 
            }
            
            
            
            // User Profile Gradient
            let gradientImage = item.group_id != 0 ? #imageLiteral(resourceName: "bg_gradient_0") : item.channel_id != 0 ? #imageLiteral(resourceName: "bg_gradient_3")  : #imageLiteral(resourceName: "bg_gradient_2")
            userImageView.kf.setImage(with: URL(string: item.avatar), placeholder: gradientImage)
        }
        
        iconMute.isHidden = !data.isMute
        countLabel.text = "\(data.messagesCount)"
        countLabel.isHidden = data.messagesCount == 0 ? true : false
    }
    
}
