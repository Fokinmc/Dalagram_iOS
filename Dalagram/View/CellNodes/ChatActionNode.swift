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
        actionNameNode.text = name
        
        super.init()
        addSubnode(actionNameNode)
    }
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textNodeVerticalOffset = CGFloat(6)
    
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(
            0,
            8,
            0,
            8, child: actionNameNode)
        return insetSpec
        //return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: ASStackLayoutJustifyContent.start, alignItems: .start, children: [insetSpec])
    }

}

