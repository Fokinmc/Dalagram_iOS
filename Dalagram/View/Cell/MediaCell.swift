//
//  MediaCell.swift
//  Dalagram
//
//  Created by Toremurat on 15.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class MediaCell: BaseCollectionCell {
    
    let mediaImageView: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "placeholder"))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 3.0
        return image
    }()
    
    override func setupViews() {
        addSubview(mediaImageView)
        mediaImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}
