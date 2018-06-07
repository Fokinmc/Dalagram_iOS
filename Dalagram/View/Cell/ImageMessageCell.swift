//
//  ImageMessageCell.swift
//  Dalagram
//
//  Created by Toremurat on 31.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class ImageMessageCell: BaseCollectionCell {
    
    let bubleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightBlueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 1.0
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        return view
    }()
    
    override func setupViews() {
        addSubview(bubleView)
        
    }
}
