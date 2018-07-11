//
//  MessageCell.swift
//  Dalagram
//
//  Created by Toremurat on 22.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SnapKit

class BubbleTextCell: BaseCollectionCell {
    
    lazy var top: NSLayoutConstraint = self.bubleView.topAnchor.constraint(equalTo: self.contentView.topAnchor)
    lazy var left: NSLayoutConstraint = self.bubleView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor)
    lazy var bottom: NSLayoutConstraint = self.bubleView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    lazy var right: NSLayoutConstraint = self.bubleView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor)
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.text = "Simple message"
        textView.textColor = UIColor.black
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.text = "09:00 PM"
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    lazy var markIcon: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "icon_mark_green"))
        image.contentMode = .scaleAspectFit
        return image
    }() 
    
    lazy var bubleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGreenColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 1.0
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        return view
    }()
    
    
    var bubleRightAnchor: NSLayoutConstraint?
    var bubleLeftAnchor: NSLayoutConstraint?
    var bubleWidthAnchor: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        addSubview(bubleView)
        addSubview(textView)
        addSubview(dateLabel)
        addSubview(markIcon)
        
        // Right And Left Constraints
        bubleRightAnchor = bubleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8.0)
        bubleLeftAnchor = bubleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8.0)
        
        if #available(iOS 11.0, *) {
            bubleLeftAnchor = bubleView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 8.0)
            bubleRightAnchor = bubleView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -8.0)
        }
        
        bubleLeftAnchor?.isActive = true
        bubleRightAnchor?.isActive = true
        
        // Top & Height Constraints
        bubleView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        //bubleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        bubleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //Width Contraints

        markIcon.snp.makeConstraints { (make) in
            make.right.equalTo(bubleView).offset(-8.0)
            make.bottom.equalTo(bubleView).offset(-4.0)
            make.width.equalTo(15.0)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(markIcon.snp.left).offset(-4.0)
            make.centerY.equalTo(markIcon)
        }
        
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(bubleView).offset(8.0)
            make.right.lessThanOrEqualTo(dateLabel.snp.left).offset(-3.0)
            make.top.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    func setupData(_ data: DialogHistory, chatType: DialogType, user_id: Int) {
        textView.text   = data.chat_text
        dateLabel.text  = data.chat_date
        let bubleWidth = (round((estimatedFrameForText(data.chat_text).width +
            estimatedFrameForText(data.chat_date).width)/2.0) * 2) + 40.0
        if let widthConstraint = bubleWidthAnchor {
            widthConstraint.constant = bubleWidth
        } else {
            bubleWidthAnchor = bubleView.widthAnchor.constraint(equalToConstant: bubleWidth)
        }
    
        switch chatType {
        case .group, .channel:
            setupLeftBuble()
        default:
            data.sender_user_id != user_id ? setupRightBuble() : setupLeftBuble()
        }
    }
    
    func setupLeftBuble() {
        dateLabel.textColor         = UIColor.lightGray
        bubleView.backgroundColor   = UIColor.white
        bubleLeftAnchor?.isActive   = true
        bubleRightAnchor?.isActive  = false
        bubleWidthAnchor?.isActive  = true
    }
    
    func setupRightBuble() {
        dateLabel.textColor         = UIColor.init(red: 90/255.0, green: 184/255.0, blue: 20/255.0, alpha: 1.0)
        bubleView.backgroundColor   = UIColor.lightGreenColor
        bubleLeftAnchor?.isActive   = false
        bubleRightAnchor?.isActive  = true
        bubleWidthAnchor?.isActive  = true
    }
    
    private func estimatedFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 180, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0)], context: nil)
    }
    
}
