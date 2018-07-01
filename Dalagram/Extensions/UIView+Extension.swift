//
//  UIView+Extension.swift
//  Dalagram
//
//  Created by Toremurat on 15.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    static let noContentViewTag = 404
    
    func showNoContent(title:String?, message:String?, iconName:String? = nil) {
        
        removeNoContentView()
        
        let container = UIView()
        container.tag = UIView.noContentViewTag
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.75)
            make.center.equalToSuperview()
        }
        
        var aboveView : UIView? = nil
        if let icon = iconName {
            let iv = UIImageView(image: UIImage(named: icon))
            container.addSubview(iv)
            iv.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
            })
            aboveView = iv
        }
        
        var titleLabel: UILabel?
        if let title = title {
            titleLabel = UILabel()
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            titleLabel?.textColor = UIColor.black
            titleLabel?.numberOfLines = 0
            titleLabel?.lineBreakMode = .byWordWrapping
            titleLabel?.textAlignment = .center
            titleLabel?.text = title
            container.addSubview(titleLabel!)
            
            titleLabel?.snp.makeConstraints { make in
                if let view = aboveView {
                    make.top.equalTo(view.snp.bottom).offset(20)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.right.equalToSuperview()
            }
            aboveView = titleLabel
        }
        
        var messageLabel: UILabel?
        if let message = message {
            messageLabel = UILabel()
            messageLabel?.font = UIFont.systemFont(ofSize: 13)
            messageLabel?.textColor = UIColor.black
            messageLabel?.numberOfLines = 0
            messageLabel?.lineBreakMode = .byWordWrapping
            messageLabel?.textAlignment = .center
            messageLabel?.text = message
            container.addSubview(messageLabel!)
            messageLabel?.snp.makeConstraints { make in
                if let view = aboveView {
                    make.top.equalTo(view.snp.bottom).offset(5)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.right.equalToSuperview()
            }
        }
        
        
        if let label = messageLabel {
            label.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
        }
        
    }
    
    func removeNoContentView() {
        if let oldView = self.viewWithTag(UIView.noContentViewTag) {
            oldView.removeFromSuperview()
        }
    }
    
    func animateView(imageView:UIView) {
        UIView.animate(withDuration: 1.0, animations: {
            imageView.transform = imageView.transform.rotated(by: CGFloat(Double.pi))
        }, completion: { b in
            if let _ = self.viewWithTag(UIView.noContentViewTag) {
                self.animateView(imageView: imageView)
            }
        })
    }
    
}
