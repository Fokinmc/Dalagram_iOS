//
//  File.swift
//  Dalagram
//
//  Created by Toremurat on 13.08.2018.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import SafariServices

open class DocumentContentNode: ContentNode {
    
    open var insets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8) {
        didSet {
            setNeedsLayout()
        }
    }
    
    open override var isIncomingMessage: Bool
        {
        didSet {
            if isIncomingMessage {
                self.backgroundBubble?.bubbleColor = self.bubbleConfiguration.getIncomingColor()
                self.updateAttributedText()
            } else {
                self.backgroundBubble?.bubbleColor = self.bubbleConfiguration.getOutgoingColor()
                self.updateAttributedText()
            }
        }
    }
    
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
    
    var documentUrl: URL?
    open fileprivate(set) var loaderNode: ASDisplayNode = ASDisplayNode()
    open fileprivate(set) var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    open fileprivate(set) var documentText: ASTextNode = ASTextNode()
    open fileprivate(set) var documentIcon: ASImageNode = ASImageNode()
    open fileprivate(set) var documentDate: ASTextNode = ASTextNode()
    open fileprivate(set) var sendIconNode: ASImageNode = ASImageNode()

    public init(text: String, date: String, documentUrl: URL? = nil, currentVC: UIViewController, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupDocumentNode(text, date: date)
        self.currentViewController = currentVC
        self.documentUrl = documentUrl
    }
    
    fileprivate func setupDocumentNode(_ text: String, date: String)
    {
        self.backgroundBubble = self.bubbleConfiguration.getBubble()
        self.backgroundColor = UIColor.lightGreenColor
        
        sendIconNode.image = UIImage(named: "icon_mark_double")
        documentIcon.image = UIImage(named: "icon_document")
        documentIcon.contentMode = UIViewContentMode.scaleAspectFit
        
        let dateTextAttr = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.n1Black50Color()]
        documentDate.attributedText = NSMutableAttributedString(string: date, attributes: dateTextAttr)
        
        let attributes =  [ NSAttributedStringKey.font: self.isIncomingMessage ? incomingTextFont : outgoingTextFont, NSAttributedStringKey.foregroundColor: self.isIncomingMessage ? incomingTextColor : outgoingTextColor
        ]
        
        documentText.maximumNumberOfLines = 3
        documentText.truncationMode = .byTruncatingTail
        documentText.attributedText = NSAttributedString(string: text, attributes: attributes)
        
        self.addSubnode(documentIcon)
        self.addSubnode(documentText)
        self.addSubnode(documentDate)
        self.addSubnode(sendIconNode)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: 28, y: 28)
        loaderNode.view.addSubview(activityIndicator)
        self.addSubnode(loaderNode)
    }
    
    //MARK: Helper Methods
    /** Updates the attributed string to the correct incoming/outgoing settings and lays out the component again*/
    fileprivate func updateAttributedText() {
        let tmpString = NSMutableAttributedString(attributedString: documentText.attributedText!)
        tmpString.addAttributes([NSAttributedStringKey.foregroundColor: isIncomingMessage ? incomingTextColor : outgoingTextColor, NSAttributedStringKey.font: isIncomingMessage ? incomingTextFont : outgoingTextFont], range: NSMakeRange(0, tmpString.length))
        self.documentText.attributedText = tmpString
       // self.sendIconNode.isHidden = isIncomingMessage
        setNeedsLayout()
    }
    
    // MARK: Upload Status Delegates
    
    func uploadBegin() {
        print("start")
        activityIndicator.startAnimating()
    }
    
    func uploadEnd() {
        print("ended")
        activityIndicator.stopAnimating()
    }
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
         let width = constrainedSize.max.width - self.insets.left - self.insets.right
        
        self.documentIcon.style.width = ASDimension(unit: .points, value: 40)
        self.documentIcon.style.height = ASDimension(unit: .points, value: 40)

        let dateStack = ASStackLayoutSpec(direction: .vertical, spacing: 3, justifyContent: .end, alignItems: .end, children: [sendIconNode])
        
        let textStack = ASStackLayoutSpec(direction: .vertical, spacing: 3, justifyContent: .spaceAround, alignItems: .stretch, children: [documentText])
        
        textStack.style.width = ASDimension(unit: .points, value: width - 40 - self.insets.left - self.insets.right - 20)
        
        let stackLayout = ASStackLayoutSpec(direction: .horizontal, spacing: 8, justifyContent: .start, alignItems: .center, children: [documentIcon, textStack, dateStack])
        
        //let stackLayout = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .spaceAround, alignItems: .stretch, children: [documentText])

        stackLayout.style.maxWidth = ASDimension(unit: .points, value: width)
        stackLayout.style.maxHeight = ASDimension(unit: .fraction, value: 1)
        
        return ASInsetLayoutSpec(insets: insets, child: stackLayout)
        
    }
    
    /**
     Override messageTapSelector Method
     */
    open override func messageTapSelector(_ recognizer: UITapGestureRecognizer) {
        if let documentUrl = documentUrl {
            let vc = SFSafariViewController(url: documentUrl)
            currentViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    
}
