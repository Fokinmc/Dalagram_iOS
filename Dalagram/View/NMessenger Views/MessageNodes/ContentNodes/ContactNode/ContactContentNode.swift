//
//  ContactNode.swift
//  Dalagram
//
//  Created by Toremurat on 29.08.2018.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import AsyncDisplayKit

open class ContactContentNode: ContentNode {
    
    /** UIFont for incoming text messages*/
    open var incomingTextFont = UIFont.n1B1Font() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** UIFont for outgoinf text messages*/
    open var outgoingTextFont = UIFont.n1B1Font() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** UIColor for incoming text messages*/
    open var incomingTextColor = UIColor.n1DarkestGreyColor() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** UIColor for outgoinf text messages*/
    open var outgoingTextColor = UIColor.black {
        didSet {
            self.updateAttributedText()
        }
    }
    
    // MARK: Private Variables

    open fileprivate(set) var contactImageNode : ASNetworkImageNode = ASNetworkImageNode()
    open fileprivate(set) var contactName: ASTextNode = ASTextNode()
    open fileprivate(set) var contactPhone: ASTextNode = ASTextNode()
    open fileprivate(set) var dateNode: ASTextNode = ASTextNode()
    // MARK: Initialisers
    
    public init(imageUrl: String = "", name: String, phone: String, date: String, currentVC: UIViewController, bubbleConfiguration: BubbleConfigurationProtocol? = nil, userId: Int = 0) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupImageNode(imageUrl, name: name, phone: phone, date: date)
        self.currentViewController = currentVC
    }
    
    // MARK: Initialiser helper method
   
    open override func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol) {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = true
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    fileprivate func setupImageNode(_ imageUrl: String, name: String, phone: String, date: String) {
        
        contactImageNode.clipsToBounds = true
        contactImageNode.contentMode = UIViewContentMode.scaleAspectFill
        contactImageNode.url = URL(string: imageUrl)
        contactImageNode.shouldCacheImage = false
        
        if imageUrl.isEmpty {
            contactImageNode.image = #imageLiteral(resourceName: "bg_gradient_2")
        }
        
        let nameTextAttr = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: self.isIncomingMessage ? incomingTextColor : outgoingTextColor]
        
        let phoneTextAttr = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor:  self.isIncomingMessage ? incomingTextColor : outgoingTextColor]
        
        self.contactName.attributedText = NSMutableAttributedString(string: name, attributes: nameTextAttr)
        
        self.contactPhone.attributedText = NSMutableAttributedString(string: phone, attributes: phoneTextAttr)
        
        let dateTextAttr = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.n1Black50Color()]
        dateNode.attributedText = NSAttributedString(string: date, attributes: dateTextAttr)
        dateNode.textContainerInset = UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 2)
       
        self.addSubnode(contactImageNode)
        self.addSubnode(dateNode)
        self.addSubnode(contactName)
        self.addSubnode(contactPhone)
    }
    
    fileprivate func updateAttributedText() {
        setNeedsLayout()
    }

    // MARK: Override AsycDisaplyKit Methods
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width = constrainedSize.max.width
        let imageWidth: CGFloat = 50.0
        
        self.contactImageNode.style.width = ASDimension(unit: .points, value: imageWidth)
        self.contactImageNode.style.height = ASDimension(unit: .points, value: imageWidth)
        
        DispatchQueue.main.async {
            self.contactImageNode.view.layer.cornerRadius = imageWidth/2
        }
        
        self.dateNode.style.alignSelf = .end
        
        let textStack = ASStackLayoutSpec(direction: .vertical, spacing: 2.0, justifyContent: .start, alignItems: .stretch, children: [contactName, contactPhone, dateNode])
        
        let mainStack = ASStackLayoutSpec(direction: .horizontal, spacing: 8.0, justifyContent: .start, alignItems: .center, children: [contactImageNode, textStack])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), child: mainStack)

    }
    
    // MARK: UIGestureRecognizer Selector Methods

    open override func messageTapSelector(_ recognizer: UITapGestureRecognizer) {
        print("messageTapSelector")
    }
    
}

