//
//  ContactCell.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var userCreds: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.layer.cornerRadius = avatarView.frame.width/2
    }
    
    func setupSystemContact(_ data: PhoneContact) {
      
        firstName.text      = data.firstName
        lastName.text       = data.lastName
        statusLabel.text    = data.phone
        avatarView.image = #imageLiteral(resourceName: "img_contact")
        userCreds.isHidden = false
        userCreds.text = "\(data.firstName.first!)\(data.lastName.first!)"
    }
    
    func setupRegisteredContact(_ data: Contact) {
        
        firstName.text      = data.user_name != "" ? data.user_name : data.contact_name
        statusLabel.text    = "Был(а) в сети \(data.last_visit)"
        lastName.text       = ""
        if data.avatar != "" {
            userCreds.isHidden = true
            avatarView.kf.setImage(with: URL(string: data.avatar), placeholder: #imageLiteral(resourceName: "img_contact"))
        } else {
            avatarView.image = #imageLiteral(resourceName: "img_contact")
            userCreds.isHidden = false
            userCreds.text = "\(data.user_name.first!)"
        }
    }
    
}
