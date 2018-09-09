
//
//  File.swift
//  Dalagram
//
//  Created by Toremurat on 29.08.2018.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

enum PlayIconState {
    case play
    case pause
}

class AudioContentNode: ContentNode {
    
    // MARK: Private Variables
    
    fileprivate(set) var playIconNode : ASImageNode = ASImageNode()
    fileprivate(set) var audioSlider: ASDisplayNode = ASDisplayNode()
    fileprivate(set) var audioTimeNode: ASTextNode = ASTextNode()
    fileprivate(set) var dateNode: ASTextNode = ASTextNode()
    
    private var playIconState: PlayIconState = PlayIconState.play {
        didSet {
            switch playIconState {
            case .play:
                playIconNode.image = UIImage(named: "icon_mini_play")
            case .pause:
                playIconNode.image = UIImage(named: "icon_mini_pause")
            }
        }
    }
    
    // MARK: Initialisers
    
    public init(duration: String, date: String, currentVC: UIViewController, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupAudioNode(duration: duration, date: date)
        self.currentViewController = currentVC
    }
    
    // MARK: Initialiser helper method
    
    fileprivate func setupAudioNode(duration: String, date: String) {
        
        playIconNode.image = UIImage(named: "icon_mini_play")
        playIconNode.contentMode = .scaleAspectFit
        let dateTextAttr = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.n1Black50Color()]
        dateNode.attributedText = NSAttributedString(string: date, attributes: dateTextAttr)
        dateNode.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        audioTimeNode.attributedText = NSAttributedString(string: duration, attributes: dateTextAttr)
        audioTimeNode.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        DispatchQueue.main.async {
            let slider = UISlider(frame: CGRect.init(x: 8, y: 0, width: 150, height: 20))
            slider.setThumbImage(UIImage(named: "icon_slider_thumb"), for: .normal)
            slider.maximumValue = 10
            slider.minimumValue = 1
            slider.tintColor = UIColor.darkBlueNavColor
            slider.value = 0
            self.audioSlider.view.addSubview(slider)
        }
        playIconNode.addTarget(self, action: #selector(playButtonPressed), forControlEvents: .touchUpInside)
        self.addSubnode(playIconNode)
        self.addSubnode(audioSlider)
        self.addSubnode(audioTimeNode)
        self.addSubnode(dateNode)

    }
    
    open override func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol) {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = true
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    fileprivate func updateAttributedText() {
        setNeedsLayout()
    }
    
    @objc fileprivate func playButtonPressed() {
        playIconState = playIconState == .play ? .pause : .play
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
        playIconNode.style.width = ASDimension(unit: .points, value: 25)
        playIconNode.style.height = ASDimension(unit: .points, value: 25)

        let playLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0), child: playIconNode)
        
        dateNode.style.alignSelf = .end
        audioTimeNode.style.alignSelf = .start
        
        let dateLayout = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .spaceBetween, alignItems: .stretch, children: [audioTimeNode, dateNode])
        
        audioSlider.style.height = ASDimension(unit: .points, value: 20)
        audioSlider.style.width = ASDimension(unit: .points, value: 170)
        
        dateLayout.style.width = ASDimension(unit: .points, value: 160)
       
        let verticalLayout = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .start, alignItems: .center, children: [audioSlider, dateLayout])
        
        let insetVert = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0), child: verticalLayout)
        
        let stackLayout = ASStackLayoutSpec(direction: .horizontal, spacing: 8.0, justifyContent: .start, alignItems: .center, children: [playLayout, insetVert])
        
        return stackLayout
    }
    
    // MARK: UIGestureRecognizer Selector Methods
    
    open override func messageTapSelector(_ recognizer: UITapGestureRecognizer) {
        print("messageTapSelector")
    }
}
