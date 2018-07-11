//
//  ChatBubleNodeCell.swift
//  Dalagram
//
//  Created by Toremurat on 08.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import AsyncDisplayKit


public let ChatCellNodeTopTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)]

public let ChatCellNodeBottomTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]

public let ChatCellNodeContentTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0)]

protocol ChatDelegate: class {
    func openImageGallery(message: ASNodeCellData)
    func openUserProfile(message: ASNodeCellData)
}

struct ASNodeCellData {
    // Cell initializing in background thread, so need to pass ASNodeCellData object instead of Realm object (Accessing to realm objects must be in in same thread)
    var chat_text: NSAttributedString?
    var chat_date: String
    var recipient_name: String
    var chat_image: String = ""
    var chat_video: String = ""
    var chat_kind: String = ""
    var action_name: String = ""
    
    init(text: String, date: String, name: String, kind: String, action_name: String, image: String = "", video: String = "") {
        self.chat_text = NSAttributedString(string: text ,attributes : ChatCellNodeContentTextAttributes)
        self.chat_date = date
        self.recipient_name = name
        self.chat_image = image
        self.chat_video = video
        self.chat_kind = kind
        self.action_name = action_name
    }
    
}
class ChatBubleNodeCell: ASCellNode, ASVideoNodeDelegate {
    
    private let isOutgoing: Bool
    private let bubbleImageNode: ASImageNode
    private let timeNode: ASTextNode
    private let sectionNode: ASTextNode
    private let nameNode: ASTextNode
    private var bubbleNode: ASDisplayNode
    
    let message : ASNodeCellData
    weak var delegate : ChatDelegate!
    
    // MARK: - Video Action
    func didTap(_ videoNode: ASVideoNode) {
        print("didTap")
        if let delegate = delegate {
            delegate.openImageGallery(message: message)
        }
    }
    
    // MARK: - Zoom Action
    @objc func handleZoomTap() {
        print("handleZoomTap")
        if let delegate = delegate {
            delegate.openImageGallery(message: message)
        }
    }
    
    // MARK: - User Action
    @objc func handleUserTap() {
        print("handleUserTap")
        if let delegate = delegate {
            delegate.openUserProfile(message: message)
        }
    }
    
    // MARK: - Initializer
    init(message: ASNodeCellData, isOutgoing: Bool, bubbleImage: UIImage) {
        self.isOutgoing = isOutgoing
        self.message = message
        
        bubbleImageNode = ASImageNode()
        bubbleImageNode.image = bubbleImage
        timeNode = ASTextNode()
        nameNode = ASTextNode()
        bubbleNode = ASDisplayNode()
        sectionNode = ASTextNode()
        
        super.init()
        
        if !message.chat_video.isEmpty {
            bubbleNode = ChatVideoNode(url: message.chat_video, isOutgoing: isOutgoing)
        }
        if !message.chat_image.isEmpty {
            let caption = NSAttributedString(string: "Caption")
            bubbleNode = ChatNetworkImageNode(img: message.chat_image, text: caption, isOutgoing: isOutgoing)
        } else {
            if let text = message.chat_text {
                bubbleNode = ChatTextNode(text: text, isOutgoing: isOutgoing)
            }
        }
        
        addSubnode(bubbleImageNode)
        addSubnode(bubbleNode)
        
        if !message.chat_date.isEmpty {
            timeNode.attributedText = NSAttributedString(string: message.chat_date, attributes : ChatCellNodeBottomTextAttributes)
            addSubnode(timeNode)
        }
        
        if !message.recipient_name.isEmpty {
            nameNode.textContainerInset = UIEdgeInsetsMake(0, (isOutgoing ? 0 : 6), 0, (isOutgoing ? 6 : 0))
            nameNode.attributedText = NSAttributedString(string: message.recipient_name, attributes: ChatCellNodeTopTextAttributes)
            addSubnode(nameNode)
        }
        
        if message.chat_kind == "action" {
            addSubnode(sectionNode)
            sectionNode.style.alignSelf = .center
            sectionNode.textContainerInset = UIEdgeInsetsMake(5, 20, 5, 20)
            sectionNode.backgroundColor = UIColor.lightText
            sectionNode.cornerRadius = 12
            sectionNode.clipsToBounds = true
            sectionNode.style.descender = 10
            sectionNode.attributedText = NSAttributedString(string: message.action_name), attributes: ChatCellNodeTopTextAttributes)
        }
        
    }
    
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec()
        stack.direction = .vertical
        stack.style.flexShrink = 1.0
        stack.style.flexGrow = 1.0
        stack.spacing = 5
        
        if !message.recipient_name.isEmpty {
            nameNode.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)
            stack.setChild(nameNode, at: 0)
        }
        
        stack.setChild(bubbleNode, at: 1)
        
        let textNodeVerticalOffset = CGFloat(6)
        timeNode.style.alignSelf = .end
        
        let verticalSpec = ASBackgroundLayoutSpec()
        verticalSpec.background = bubbleImageNode
        
        if let _ = bubbleNode as? ChatTextNode {
            if let text = message.chat_text {
                if text.string.characters.count <= 20 {
                    let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: ASStackLayoutAlignItems.start, children: [stack , timeNode])
                    verticalSpec.child = ASInsetLayoutSpec(
                        insets: UIEdgeInsetsMake(8,12 + (isOutgoing ? 0 : textNodeVerticalOffset),8,12 + (isOutgoing ? textNodeVerticalOffset : 0)),child: horizon)
                } else {
                    stack.setChild(timeNode, at: 2)
                    verticalSpec.child = ASInsetLayoutSpec(
                        insets: UIEdgeInsetsMake(8,12 + (isOutgoing ? 0 : textNodeVerticalOffset),8,12 + (isOutgoing ? textNodeVerticalOffset : 0)),child: stack)
                }
            }
        }
        
        if let imgnode = bubbleNode as? ChatNetworkImageNode {
            imgnode.messageImageNode.addTarget(self, action: #selector(handleZoomTap), forControlEvents: ASControlNodeEvent.touchUpInside)
            if let _ = message.chat_text {
                stack.setChild(timeNode, at: 2)
                verticalSpec.child = ASInsetLayoutSpec(
                    insets:UIEdgeInsetsMake(8,(isOutgoing ? 8 : 16),8,(isOutgoing ? 16 : 8)),child: stack)
            } else {
                let insets = UIEdgeInsets(top: CGFloat.infinity, left: CGFloat.infinity, bottom: 10, right: 14)
                let textInsetSpec = ASInsetLayoutSpec(insets: insets, child: timeNode)
                let check = ASOverlayLayoutSpec(child: bubbleImageNode, overlay: textInsetSpec)
                verticalSpec.child = ASInsetLayoutSpec(
                    insets: UIEdgeInsetsMake(8,(isOutgoing ? 8 : 16),8,(isOutgoing ? 16 : 8)),child: stack)
                verticalSpec.background = check
            }
        }
        
        if let video = bubbleNode as? ChatVideoNode {
            video.videoNode.delegate = self
            let insets = UIEdgeInsets(top: CGFloat.infinity, left: CGFloat.infinity, bottom: 10, right: 14)
            let textInsetSpec = ASInsetLayoutSpec(insets: insets, child: timeNode)
            let check = ASOverlayLayoutSpec(child: bubbleImageNode, overlay: textInsetSpec)
            verticalSpec.child = ASInsetLayoutSpec(
                insets: UIEdgeInsetsMake(8,(isOutgoing ? 8 : 16),8,(isOutgoing ? 16 : 8)),child: stack)
            verticalSpec.background = check
        }
        
        // Cell Spacing
        let insetSpec = ASInsetLayoutSpec(insets: isOutgoing ? UIEdgeInsetsMake(1, 32, 5, 4) : UIEdgeInsetsMake(1, 4, 5, 32), child: verticalSpec)
        let stackSpec = ASStackLayoutSpec()
        stackSpec.direction = .vertical
        stackSpec.justifyContent = .spaceAround
        stackSpec.alignItems = isOutgoing ? .end : .start
        stackSpec.spacing = 0
        stackSpec.children = [insetSpec]
        
        //        if let _ = message.sectionStamp {
        //            stackSpec.spacing = 10
        //            stackSpec.children = [sectionNode,insetSpec]
        //        } else {
        //            stackSpec.spacing = 0
        //            stackSpec.children = [insetSpec]
        //        }
        
        return stackSpec
    }
    
}

