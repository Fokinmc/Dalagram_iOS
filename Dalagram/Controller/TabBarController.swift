//
//  TabBarController.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    
    static func instantiate() -> TabBarController {
        let vc = TabBarController()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeControllers()
        configUI()
    }
    
    func initializeControllers() {
        
        let vc1 = ContactsController()
        vc1.title = "Контакты"
        let nc1 = UINavigationController.init(rootViewController: vc1)

        let vc2 = ChatsController()
        vc2.title = "Чаты"
        let nc2 = UINavigationController.init(rootViewController: vc2)
        
        let vc3 = UIViewController()
        vc3.title = "Новости"
        vc3.view.backgroundColor = UIColor.white
        let nc3 = UINavigationController.init(rootViewController: vc3)
        
        let vc4 = SettingsController.fromStoryboard()
        vc4.title = "Настройки"
        let nc4 = UINavigationController.init(rootViewController: vc4)
    
        self.viewControllers = [nc2, nc1, nc3, nc4]
        
    }
    
    func configUI() {
        
        self.tabBar.isTranslucent = true
        
        let tabBarItem0 = self.tabBar.items?.first
        tabBarItem0?.image = UIImage.init(named: "icon_contacts")?.withRenderingMode(.alwaysOriginal)
        tabBarItem0?.selectedImage = UIImage.init(named: "icon_contacts_ac")?.withRenderingMode(.alwaysOriginal)
        
        let tabBarItem1 = self.tabBar.items?[1]
        tabBarItem1?.image = UIImage.init(named: "icon_chat")?.withRenderingMode(.alwaysOriginal)
        tabBarItem1?.selectedImage = UIImage.init(named: "icon_chat_ac")?.withRenderingMode(.alwaysOriginal)
        
        let tabBarItem2 = self.tabBar.items?[2]
        tabBarItem2?.image = UIImage.init(named: "icon_news")?.withRenderingMode(.alwaysOriginal)
        tabBarItem2?.selectedImage = UIImage.init(named: "icon_news_ac")?.withRenderingMode(.alwaysOriginal)
        
        let tabBarItem3 = self.tabBar.items?[3]
        tabBarItem3?.image = UIImage.init(named: "icon_settings")?.withRenderingMode(.alwaysOriginal)
        tabBarItem3?.selectedImage = UIImage.init(named: "icon_settings_ac")?.withRenderingMode(.alwaysOriginal)
        
    }
    
}




