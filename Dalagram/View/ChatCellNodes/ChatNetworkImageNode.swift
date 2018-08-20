//
//  ChatNetworkImageNode.swift
//  MMTextureChat
//
//  Created by Toremurat on 08.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ChatNetworkImageNode: ASDisplayNode, ASNetworkImageNodeDelegate {
    
    private let isOutgoing: Bool
    private let textNode: ASTextNode
    private let caption : NSAttributedString
    let messageImageNode: ASNetworkImageNode
    private var activity : UIActivityIndicatorView
    
    public init(imageUrl: String, imageData: Data, text: NSAttributedString , isOutgoing: Bool) {
        self.isOutgoing = isOutgoing
        messageImageNode = ASNetworkImageNode()
        messageImageNode.cornerRadius = 6
        messageImageNode.clipsToBounds = true
        
        textNode = MessageCaptionNode()
        self.caption = text
        
        activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activity.hidesWhenStopped = true
        
        super.init()
    
        self.backgroundColor =  UIColor.clear
        messageImageNode.style.preferredSize = CGSize(width: 210, height: 150)
        
        if !imageUrl.isEmpty {
            // for uploaded image with url
            messageImageNode.url = URL(string: imageUrl)
            messageImageNode.delegate = self
            messageImageNode.shouldRenderProgressImages = true
        } else {
            // offline uploaded image
            messageImageNode.image = UIImage.init(data: imageData)
            messageImageNode.delegate = self
            messageImageNode.shouldRenderProgressImages = true
        }
        
        if text.string != "" {
            textNode.textContainerInset = UIEdgeInsetsMake(6, 6, 0, 8)
            textNode.attributedText = text
            textNode.backgroundColor = UIColor.clear
            textNode.placeholderEnabled = false
            addSubnode(textNode)
        }
        
        addSubnode(messageImageNode)
        
        self.view.addSubview(activity)
        activity.center = CGPoint(x: 105, y: 75)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let verticalSpec = ASStackLayoutSpec()
        verticalSpec.direction = .vertical
        verticalSpec.spacing = 0
        verticalSpec.justifyContent = .start
        verticalSpec.alignItems = isOutgoing == true ? .end : .start
        verticalSpec.setChild(messageImageNode, at: 0)
        
        if self.caption.string != "" {
            textNode.style.alignSelf = .start //(isOutgoing ? .start : .end)
            verticalSpec.setChild(textNode, at: 1)
        }
        
        let insets = UIEdgeInsetsMake(0, 0, 0, 0)
        let insetSpec = ASInsetLayoutSpec(insets: insets, child: verticalSpec)
        return insetSpec
    }
    
    //MARK:- Network delegates
    
    public func imageNodeDidStartFetchingData(_ imageNode: ASNetworkImageNode) {
        activity.startAnimating()
    }
    
    public func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        activity.stopAnimating()
        
    }
    
    public func imageNode(_ imageNode: ASNetworkImageNode, didFailWithError error: Error) {
        activity.stopAnimating()
        
    }
}

class MessageCaptionNode: ASTextNode {
    
    override init() {
        super.init()
        placeholderColor = UIColor.gray
        isLayerBacked = true
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let size = super.calculateSizeThatFits(CGSize(width: 210, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: max(size.width, 15), height: size.height)
    }
    
}

