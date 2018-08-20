//
//  File.swift
//  Dalagram
//
//  Created by Toremurat on 17.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit

open class ActionBubbleConfiguration: BubbleConfigurationProtocol {
    
    open var isMasked = false
    
    public init() {}
    
    open func getIncomingColor() -> UIColor
    {
        return UIColor(white: 0.2, alpha: 0.4)
    }
    
    open func getOutgoingColor() -> UIColor
    {
        return UIColor.lightGreenColor
    }
    
    open func getBubble() -> Bubble
    {
        let newBubble = ActionBuble()
        newBubble.hasLayerMask = isMasked
        return newBubble
    }
    
    open func getSecondaryBubble() -> Bubble
    {
        let newBubble = StackedBubble()
        newBubble.hasLayerMask = isMasked
        return newBubble
    }
}
