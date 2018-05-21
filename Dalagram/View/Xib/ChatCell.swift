//
//  ChatCell.swift
//  Dalagram
//
//  Created by Toremurat on 21.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var messageCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageCountLabel.layer.cornerRadius = 13.0
        messageCountLabel.clipsToBounds = true
        selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
