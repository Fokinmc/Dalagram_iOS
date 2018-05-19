//
//  ViewController+Extension.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: Hide Keyboard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: NavigationBar
    
    func setEmptyBackTitle() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setBlueNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barTintColor = UIColor.customBlueColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.init(0.01))]
    }
    
    func navBarTransparent() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
       
    }
    
    // MARK: - Actions
    
    @objc func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissController() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Alerts
    
    func alertTryAgain() {
        alert(title:"Error", message:"Please try again")
    }
    
    func alert(message:String) {
        alert(title: nil, message: message)
    }
    
    func alert(title:String?, message:String?, cancelButton:String = "OK", actionButton:String? = nil, handler: (() -> (Void))? = nil, cancelHandler: (() -> (Void))? = nil) {
        let alert = UIAlertController(title: title ?? "", message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelButton, style: .cancel) { _ in
            if let h = cancelHandler {
                h()
            }
        })
        if let ab = actionButton {
            alert.addAction(UIAlertAction(title: ab, style: .default) { action in
                if let h = handler {
                    h()
                }
            })
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Action Sheet
    func actionSheet(title: String?, message:String?, cancelButton:String = "Cancel", actionButton:String? = nil, handler: (() -> (Void))? = nil, cancelHandler: (() -> (Void))? = nil) {
        let actionSheet = UIAlertController(title: title ?? "", message: message, preferredStyle: .actionSheet)
        
        if let action = actionButton {
            actionSheet.addAction(UIAlertAction(title: action, style: .destructive, handler: { (action) -> Void in
                if let h = handler {
                    h()
                }
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: cancelButton, style: .cancel) { _ in
            if let h = cancelHandler {
                h()
            }
        })
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func actionSheet(title: String?, message:String?, cancelButton:String = "Cancel", actionButton:String? = nil, otherButtons:[String], handler: (() -> (Void))? = nil, cancelHandler: (() -> (Void))? = nil) {
        let actionSheet = UIAlertController(title: title ?? "", message: message, preferredStyle: .actionSheet)
        
        if let action = actionButton {
            actionSheet.addAction(UIAlertAction(title: action, style: .destructive, handler: { (action) -> Void in
                if let h = handler {
                    h()
                }
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: cancelButton, style: .cancel) { _ in
            if let h = cancelHandler {
                h()
            }
        })
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: Activity Indicator View
    func showLoaderInNavigationBar(atLeft: Bool) -> UIActivityIndicatorView {
        let navigationLoader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        navigationLoader.hidesWhenStopped = true
        let barButton = UIBarButtonItem(customView: navigationLoader)
        if atLeft {
            navigationItem.leftBarButtonItem = barButton
        }
        else {
            navigationItem.rightBarButtonItem = barButton
        }
        navigationLoader.startAnimating()
        return navigationLoader
    }
    
    // MARK: - Storyboard
    
    func storyboardViewController(storyboardName name:String, identifier:String) -> UIViewController? {
        return UIViewController.storyboardViewController(storyboardName: name, identifier: identifier)
    }
    
    class func storyboardViewController(storyboardName name:String, identifier:String) -> UIViewController? {
        let s = UIStoryboard(name: name, bundle: nil)
        return s.instantiateViewController(withIdentifier: identifier)
    }
    
    // MARK: - Alerts
    
    //    func alertTryAgain() {
    //        alert(title:"Ошибка", message:APIResponse.tryAgainMessage)
    //    }
    //
    //    func alert(message:String) {
    //        alert(title: nil, message: message)
    //    }
    //
    //    func alert(title:String?, message:String?, cancelButton:String = "OK", actionButton:String? = nil, handler: ((Void) -> (Void))? = nil, cancelHandler: ((Void) -> (Void))? = nil) {
    //        let alert = UIAlertController(title: title ?? "", message:message, preferredStyle: .alert)
    //        alert.addAction(UIAlertAction(title: cancelButton, style: .cancel) { _ in
    //            if let h = cancelHandler {
    //                h()
    //            }
    //        })
    //        if let ab = actionButton {
    //            alert.addAction(UIAlertAction(title: ab, style: .default) { action in
    //                if let h = handler {
    //                    h()
    //                }
    //            })
    //        }
    //        self.present(alert, animated: true, completion: nil)
    //    }
    //
    //    //MARK: Action Sheet
    //    func actionSheet(title: String?, message:String?, cancelButton:String = "Отмена", actionButton:String? = nil, handler: ((Void) -> (Void))? = nil, cancelHandler: ((Void) -> (Void))? = nil) {
    //        let actionSheet = UIAlertController(title: title ?? "", message: message, preferredStyle: .actionSheet)
    //
    ////        actionSheet.view.tintColor = UIColor.customOrangeColor()
    //        if let action = actionButton {
    //            actionSheet.addAction(UIAlertAction(title: action, style: .destructive, handler: { (action) -> Void in
    //                if let h = handler {
    //                    h()
    //                }
    //            }))
    //        }
    //
    //        actionSheet.addAction(UIAlertAction(title: cancelButton, style: .cancel) { _ in
    //            if let h = cancelHandler {
    //                h()
    //            }
    //        })
    //
    //        self.present(actionSheet, animated: true, completion: nil)
    //
    //    }
}
