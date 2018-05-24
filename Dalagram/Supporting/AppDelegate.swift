//
//  AppDelegate.swift
//  Dalagram
//
//  Created by Toremurat on 18.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        configureRootController()
        configureNavBar()
        configureTabBar()
  
        return true
    }
    
    func configureRootController() {
        //let vc = UINavigationController.init(rootViewController: SignInController.instantiate())
        let vc = TabBarController.instantiate()
        window?.translatesAutoresizingMaskIntoConstraints = true
        window?.rootViewController = vc
    }
    
    func configureNavBar() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.init(0.01))]
    }
    
    func configureTabBar() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.init(red: 140, green: 140, blue: 140, alpha: 1.0)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.init(red: 63/255.0, green: 93/255.0, blue: 161/255.0, alpha: 1.0)], for: .selected)
    }
    
    
    func configureKeyboard() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemText = "↓"
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().toolbarTintColor = UIColor.gray
    }
    
    static func shared() -> AppDelegate {
        return (UIApplication.shared.delegate as? AppDelegate)!
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }


}

