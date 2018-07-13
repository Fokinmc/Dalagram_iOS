//
//  ChatVideoNode.swift
//  MMTextureChat
//
//  Created by Toremurat on 08.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ChatVideoNode : ASDisplayNode {
    
    var videoNode : ASVideoNode
    private let isOutgoing: Bool
    private let playBut : ASButtonNode
    private let videoURL : String
    
    public init(url: String  , isOutgoing: Bool) {
        
        self.isOutgoing = isOutgoing
        
        videoNode = ASVideoNode()
        videoNode.cornerRadius = 6
        videoNode.clipsToBounds = true
        
        videoNode.shouldAutoplay = false
        self.videoURL = url
        videoNode.backgroundColor = UIColor.lightGray
        videoNode.style.preferredSize = CGSize(width: 210, height: 150)
        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        
        playBut = ASButtonNode()
        playBut.style.preferredSize = CGSize(width: 50, height: 50)
        playBut.backgroundColor = UIColor.clear
        playBut.isUserInteractionEnabled = false
        playBut.setImage(#imageLiteral(resourceName: "icon_play"), for: .normal)
        
        super.init()
        
        addSubnode(videoNode)
        addSubnode(playBut)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let verticalSpec = ASStackLayoutSpec()
        verticalSpec.direction = .vertical
        verticalSpec.spacing = 0
        verticalSpec.justifyContent = .start
        verticalSpec.alignItems = isOutgoing == true ? .end : .start
        verticalSpec.setChild(videoNode, at: 0)

        let insets = UIEdgeInsetsMake(0, 0, 0, 0)
        let insetSpec = ASInsetLayoutSpec(insets: insets, child: verticalSpec)
        let overlay = ASOverlayLayoutSpec(child: insetSpec, overlay: playBut)
        return overlay
    }
    
    override public func didLoad() {
        super.didLoad()
        if let temp = URL(string: self.videoURL){
            videoNode.asset = AVAsset(url: temp)
        }
    }
}
