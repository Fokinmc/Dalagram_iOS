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
    
    func setupSystemContact(_ data: PhoneContact, section: Int) {
        firstName.text      = data.firstName
        lastName.text       = data.lastName
        statusLabel.text    = data.phone
        avatarView.image    = UIImage(named: "bg_gradient_\(section % 4)")
        userCreds.isHidden  = false
        var credits = ""
        if let nameFirst = data.firstName.first {
            credits += String(nameFirst).capitalized
        }
        if let surnameFirst = data.lastName.first {
            credits += String(surnameFirst).capitalized
        }
        userCreds.text = "\(credits)"
    }
    
    func setupRegisteredContact(_ data: Contact) {
        let contactName = data.user_name != "" ? data.user_name : data.contact_name
        firstName.text      = contactName
        statusLabel.text    = "Был(а) в сети \(!data.last_visit.isEmpty ? data.last_visit : "недавно")"
        lastName.text       = ""
        if !data.avatar.isEmpty {
            userCreds.isHidden = true
            userCreds.text = ""
            avatarView.kf.setImage(with: URL(string: data.avatar), placeholder: #imageLiteral(resourceName: "bg_gradient_2"))
        } else {
            avatarView.image = UIImage(named: "bg_gradient_2")
            userCreds.isHidden = false
            userCreds.text = "\(contactName.first!)"
        }
    }
    
    func setupRegisteredContact(_ data: JSONContact) {
        let contactName = data.user_name != "" ? data.user_name : !data.contact_name.isEmpty ? data.contact_name : data.phone
        firstName.text      = contactName
        statusLabel.text    = "Был(а) в сети \(data.last_visit)"
        lastName.text       = ""
        
        if data.is_admin == 1 {
            statusLabel.text    = "Был(а) в сети \(data.last_visit) - Админ"
        }
        
        if data.avatar != "http://dalagram.bugingroup.com/media/default-user.jpg" {
            userCreds.isHidden = true
            avatarView.kf.setImage(with: URL(string: data.avatar), placeholder: #imageLiteral(resourceName: "bg_gradient_2"))
        } else {
            avatarView.image = UIImage(named: "bg_gradient_\(arc4random_uniform(4))")
            userCreds.isHidden = false
            userCreds.text = "\(contactName.first!)"
        }
    }
    
}
