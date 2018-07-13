//
//  ChatActionNode.swift
//  Dalagram
//
//  Created by Toremurat on 11.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ChatActionNode: ASDisplayNode {
    
    let actionNameNode: ASTextNode

    public init(name: String) {
        
        actionNameNode = ASTextNode()
        actionNameNode.style.alignSelf = .center
        actionNameNode.textContainerInset = UIEdgeInsetsMake(5, 20, 5, 20)
        actionNameNode.backgroundColor = UIColor.init(white: 0.1, alpha: 0.4)
        actionNameNode.cornerRadius = 12
        actionNameNode.clipsToBounds = true
        actionNameNode.style.descender = 10
        actionNameNode.attributedText = NSAttributedString(string: name, attributes: ChatCellNodeActionTextAttributes)
        
        super.init()
        addSubnode(actionNameNode)
    }
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(8, 8, 8, 8), child: actionNameNode)
        return insetSpec
        //return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: ASStackLayoutJustifyContent.start, alignItems: .start, children: [insetSpec])
    }

}

