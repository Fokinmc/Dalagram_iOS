//
//  ViewController.swift
//  Dalagram
//
//  Created by Toremurat on 18.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlets
    
    // MARK: - Variables
    var model: Messages!
    
    // MARK: - Initializer
    
    static func instantiate() -> ViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ID") as! ViewController
    }
    
    convenience init(model: Messages) {
        self.init()
        self.model = model
    }
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        configureUI()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        
    }


}
