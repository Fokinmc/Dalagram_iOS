//
//  ActionContentNode.swift
//  Dalagram
//
//  Created by Toremurat on 17.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

open class ActionContentNode: ContentNode, ASTextNodeDelegate {
    
    // MARK: Public Variables
    /** Insets for the node */
    open var insets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10) {
        didSet {
            setNeedsLayout()
        }
    }
    
    /** String to present as the content of the cell*/
    open var textMessageString: NSAttributedString? {
        get {
            return self.actionMessageNode.attributedText
        } set {
            self.actionMessageNode.attributedText = newValue
        }
    }
   
    // MARK: Private Variables
    /** ASTextNode as the content of the cell*/
    
    open fileprivate(set) var actionMessageNode: ASTextNode = ASTextNode()

    
    // MARK: Initialisers
    
    /**
     Initialiser for the cell.
     - parameter textMessageString: Must be String. Sets text for cell.
     Calls helper method to setup cell
     */
    public init(textMessageString: String, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupTextNode(textMessageString)
    }
    /**
     Initialiser for the cell.
     - parameter textMessageString: Must be String. Sets text for cell.
     - parameter currentViewController: Must be an UIViewController. Set current view controller holding the cell.
     Calls helper method to setup cell
     */
    public init(textMessageString: String, currentViewController: UIViewController, bubbleConfiguration: BubbleConfigurationProtocol? = nil)
    {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.currentViewController = currentViewController
        self.setupTextNode(textMessageString)
    }
    
    // MARK: Initialiser helper method
    
    /**
     Creates the text to be display in the cell. Finds links and phone number in the string and creates atrributed string.
     - parameter textMessageString: Must be String. Sets text for cell.
     */
    fileprivate func setupTextNode(_ textMessageString: String)
    {
        self.backgroundBubble = self.bubbleConfiguration.getBubble()
        actionMessageNode.delegate = self
        actionMessageNode.isUserInteractionEnabled = true
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        let actionTextAttr = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.white, .paragraphStyle: titleParagraphStyle] as [NSAttributedStringKey : Any]
        let outputString = NSMutableAttributedString(string: textMessageString, attributes: actionTextAttr)
       
        self.actionMessageNode.attributedText = outputString
        self.actionMessageNode.accessibilityIdentifier = "labelMessage"
        self.actionMessageNode.isAccessibilityElement = true
        self.actionMessageNode.maximumNumberOfLines = 3

        self.addSubnode(actionMessageNode)
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width = constrainedSize.max.width - self.insets.left - self.insets.right - 10
        let stackLayout = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .center, alignItems: .center, children: [actionMessageNode])
        stackLayout.style.maxWidth = ASDimension(unit: .points, value: width)
        stackLayout.style.maxHeight = ASDimension(unit: .fraction, value: 1)
        
        return ASInsetLayoutSpec(insets: insets, child: stackLayout)
    }
    
}
