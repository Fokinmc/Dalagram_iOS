//
//  ChatTextNode.swift
//  MMTextureChat
//
//  Created by Toremurat on 08.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ChatTextNode: ASDisplayNode, ASTextNodeDelegate {
    
    let isOutgoing: Bool
    let textNode: ASTextNode
    
    public init(text: NSAttributedString, isOutgoing: Bool) {
        self.isOutgoing = isOutgoing
        textNode = MessageTextNode()
        
        let attr = NSMutableAttributedString(attributedString: text)
        textNode.attributedText = attr
        
        super.init()
        addSubnode(textNode)

        // Target delegate
        textNode.isUserInteractionEnabled = true
        textNode.delegate = self
        let linkcolor = isOutgoing ? UIColor.white : UIColor.blue
        textNode.addLinkDetection(attr.string, highLightColor: linkcolor)
        textNode.addUserMention(highLightColor: linkcolor)
    }
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textNodeVerticalOffset = CGFloat(6)
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(
            0,
            0 + (isOutgoing ? 0 : textNodeVerticalOffset),
            0,
            0 + (isOutgoing ? textNodeVerticalOffset : 0)), child: textNode)
        return insetSpec
        //return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: ASStackLayoutJustifyContent.start, alignItems: .start, children: [insetSpec])
    }
    
    //MARK: - Text Delegate
    
    public func textNode(_ textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
        return true
    }
    
    public func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        print("ChatTextNode: link tap")
        
    }
}

class MessageTextNode: ASTextNode {
    
    override init() {
        super.init()
        placeholderColor = UIColor.clear
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let size = super.calculateSizeThatFits(constrainedSize)
        return CGSize(width: max(size.width, 15), height: size.height)
    }
    
}

extension ASTextNode {
    
    func addLinkDetection(_ text: String, highLightColor: UIColor) {
        self.isUserInteractionEnabled = true
        let types: NSTextCheckingResult.CheckingType = [.link]
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let range = NSMakeRange(0, (text as NSString).length)
            if let attributedText = self.attributedText {
                let mutableString = NSMutableAttributedString()
                mutableString.append(attributedText)
                detector.enumerateMatches(in: text, range: range) {
                    (result, _, _) in
                    if let fixedRange = result?.range {
                        mutableString.addAttribute(NSAttributedStringKey.underlineColor, value: highLightColor, range: fixedRange)
                        mutableString.addAttribute(NSAttributedStringKey.link, value: result?.url as Any , range: fixedRange)
                        mutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: highLightColor, range: fixedRange)
                    }
                }
                self.attributedText = mutableString
            }
        }
        catch { }
    }
}

extension ASTextNode {
    
    func addUserMention(highLightColor : UIColor){
        if let attrText = self.attributedText{
            let replaced = NSMutableAttributedString(attributedString: attrText)
            do{
                let regex = try NSRegularExpression(pattern: "@(\\w+){1,}?", options: .caseInsensitive)
                let result = regex.matches(in: attrText.string, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSMakeRange(0,(attrText.string as NSString).length))
                
                for range in result{
                    replaced.addAttribute(NSAttributedStringKey.link, value: "ptuser", range: range.range)
                    replaced.addAttribute(NSAttributedStringKey.underlineColor, value: highLightColor, range: range.range)
                    replaced.addAttribute(NSAttributedStringKey.foregroundColor, value: highLightColor, range: range.range)
                }
                self.attributedText = replaced
            }catch { }
        }
    }
    
}


