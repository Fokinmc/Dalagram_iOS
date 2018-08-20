//
//  ViewController+Extension.swift
//  Dalagram
//
//  Created by Toremurat on 19.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import MediaPlayer

extension UIViewController {
    
    // MARK: Safe Area Bottom Inset
    func calculateBottomSafeArea(_ value: CGFloat) -> CGFloat {
        var holder = value
        if #available(iOS 11.0, *) {
            holder += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        }
        return holder
    }
    
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
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "bg_navbar_sky"), for: .default)
        self.navigationController?.navigationBar.barTintColor = UIColor.darkBlueNavColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
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
    
    // MARK: - Empty Content View
    
    func showNoContentView(dataCount: Int) {
        dataCount == 0 ? self.showNoContent(title: "У вас пока нет сообщений", message: "Выберите пользователя из списка контактов или же создайте чат", iconName: "icon_empty_chat") : self.removeNoContentView()
    }
    
    func showNoContent(title:String?, message:String?, iconName:String?) {
        self.view.showNoContent(title: title, message: message, iconName: iconName)
    }
    
    func removeNoContentView() {
        self.view.removeNoContentView()
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

}

public extension UICollectionView {
    func scrollToLastItem(animated: Bool = true, position: UICollectionViewScrollPosition = .bottom) {
        scrollToLastItem(animated: animated, atScrollPosition: position)
    }
    
    func scrollToLastItem(animated: Bool, atScrollPosition scrollPosition: UICollectionViewScrollPosition) {
        guard numberOfSections > 0 else {
            return
        }
        
        var sectionWithItems: SectionInfo?
        for section in Array(0...(numberOfSections - 1)) {
            let itemCount = numberOfItems(inSection: section)
            if itemCount > 0 {
                sectionWithItems = SectionInfo(numberOfItems: itemCount, sectionIndex: section)
            }
        }
        
        guard let lastSectionWithItems = sectionWithItems else {
            return
        }
        
        let lastItemIndexPath = IndexPath(row: lastSectionWithItems.numberOfItems - 1, section: lastSectionWithItems.sectionIndex)
        scrollToItem(at: lastItemIndexPath, at: scrollPosition, animated: animated)
    }
}

struct SectionInfo {
    var numberOfItems: Int
    var sectionIndex: Int
}

extension String {
    
    func removeWhitespace() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension CGRect {
    var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self = CGRect(x: newValue, y: self.y, width: self.width, height: self.height)
        }
    }
    
    var y: CGFloat {
        get {
            return self.origin.y
        }
        set {
            self = CGRect(x: self.x, y: newValue, width: self.width, height: self.height)
        }
    }
    
    var width: CGFloat {
        get {
            return self.size.width
        }
        set {
            self = CGRect(x: self.x, y: self.y, width: newValue, height: self.height)
        }
    }
    
    var height: CGFloat {
        get {
            return self.size.height
        }
        set {
            self = CGRect(x: self.x, y: self.y, width: self.width, height: newValue)
        }
    }
    
    
    var top: CGFloat {
        get {
            return self.origin.y
        }
        set {
            y = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.origin.y + self.size.height
        }
        set {
            self = CGRect(x: x, y: newValue - height, width: width, height: height)
        }
    }
    
    var left: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self.x = newValue
        }
    }
    
    var right: CGFloat {
        get {
            return x + width
        }
        set {
            self = CGRect(x: newValue - width, y: y, width: width, height: height)
        }
    }
    
    
    var midX: CGFloat {
        get {
            return self.x + self.width / 2
        }
        set {
            self = CGRect(x: newValue - width / 2, y: y, width: width, height: height)
        }
    }
    
    var midY: CGFloat {
        get {
            return self.y + self.height / 2
        }
        set {
            self = CGRect(x: x, y: newValue - height / 2, width: width, height: height)
        }
    }
    
    
    var center: CGPoint {
        get {
            return CGPoint(x: self.midX, y: self.midY)
        }
        set {
            self = CGRect(x: newValue.x - width / 2, y: newValue.y - height / 2, width: width, height: height)
        }
    }
    
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}

extension AVAsset{
    
    var videoThumbnail:UIImage? {
        
        let assetImageGenerator = AVAssetImageGenerator(asset: self)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMake(1, 60)
       
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbNail = UIImage.init(cgImage: imageRef)
            print("Video Thumbnail genertated successfuly")
            return thumbNail
            
        } catch {
            
            print("error getting thumbnail video",error.localizedDescription)
            return nil
            
            
        }
        
    }
}
