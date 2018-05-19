//
//  ChatsController.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class ChatsController: UIViewController {

    // MARK: - IBOutlets
    
    // MARK: - Variables
    
    // MARK: - Initializer
    
    static func instantiate() -> ChatsController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatsController") as! ChatsController
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setBlueNavBar()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        
    }


}
