//
//  NewsController.swift
//  Dalagram
//
//  Created by Toremurat on 11.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class NewsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setBlueNavBar()
        view.backgroundColor = UIColor.white
        let label = UILabel()
        label.text = "Данный раздел в разработке"
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
