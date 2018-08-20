//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit
import AVKit

//MARK: ImageContentNode
/**
 ImageContentNode for NMessenger. Extends ContentNode.
 Defines content that is an image.
 */
open class VideoContentNode: ContentNode, UploadStatusDelegate {
    
    // MARK: Public Variables
    /** UIImage as the image of the cell*/
    open var image: UIImage? {
        get {
            return imageMessageNode.image
        } set {
            imageMessageNode.image = newValue
        }
    }
    
    private var videoUrl: URL?
    
    // MARK: Private Variables
    /** ASImageNode as the content of the cell*/
    open fileprivate(set) var loaderNode = ASDisplayNode()
    open fileprivate(set) var imageMessageNode: ASImageNode = ASImageNode()
    open fileprivate(set) var videoNode : ASVideoNode = ASVideoNode()
    open fileprivate(set) var loadingGifNode: ASImageNode = ASImageNode()
    open fileprivate(set) var dateNode: ASTextNode = ASTextNode()
    open fileprivate(set) var playIcon: ASImageNode = ASImageNode()
    open fileprivate(set) var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    // MARK: Initialisers
    
    /**
     Initialiser for the cell.
     - parameter image: Must be UIImage. Sets image for cell.
     Calls helper method to setup cell
     */
    public init(image: UIImage? = nil, videoUrl: URL, date: String, currentVC: UIViewController, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.videoUrl = videoUrl
        self.setupImageNode(image, date: date)
        self.currentViewController = currentVC
    }
    
    // MARK: Initialiser helper method
    /** Override updateBubbleConfig to set bubble mask */
    open override func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol) {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = true
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    /**
     Sets the image to be display in the cell. Clips and rounds the corners.
     - parameter image: Must be UIImage. Sets image for cell.
     */
    fileprivate func setupImageNode(_ image: UIImage?, date: String)
    {
        if let previewImage = image {
            imageMessageNode.image = previewImage
        } else {
            imageMessageNode.image = UIImage(named: "userprofile")
            if let videoUrl = videoUrl {
                let asset = AVAsset(url: videoUrl)
                if let thumbImage = asset.videoThumbnail {
                    imageMessageNode.image = thumbImage
                }
            }
            
            
        }
       
        imageMessageNode.clipsToBounds = true
        imageMessageNode.contentMode = UIViewContentMode.scaleAspectFill
        
        let dateTextAttr = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.white]
        dateNode.attributedText = NSAttributedString(string: date, attributes: dateTextAttr)
        dateNode.backgroundColor = UIColor.darkGray
        dateNode.cornerRadius = 5.0
        dateNode.clipsToBounds = true
        dateNode.textContainerInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        playIcon.image = UIImage(named: "icon_play")
        playIcon.contentMode = UIViewContentMode.scaleAspectFit

        self.imageMessageNode.accessibilityIdentifier = "imageNode"
        self.imageMessageNode.isAccessibilityElement = true
        
        self.addSubnode(imageMessageNode)
        self.addSubnode(dateNode)
        self.addSubnode(playIcon)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: 20, y: 20)
        loaderNode.view.addSubview(activityIndicator)
        self.addSubnode(loaderNode)
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
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width = constrainedSize.max.width
        
        self.imageMessageNode.style.width = ASDimension(unit: .points, value: width)
        self.imageMessageNode.style.height = ASDimension(unit: .points, value: width/4*3)
        
        self.loadingGifNode.style.width = ASDimension(unit: .points, value: 100)
        self.loadingGifNode.style.height = ASDimension(unit: .points, value: 50)
        
        let insets = UIEdgeInsets(top: CGFloat.infinity, left: CGFloat.infinity, bottom: 8, right: 8)
        let dateLayout = ASInsetLayoutSpec(insets: insets, child: dateNode)
        
        playIcon.style.width = ASDimension(unit: .points, value: 40)
        playIcon.style.height = ASDimension(unit: .points, value: 40)
        
        let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: playIcon)
        let overlay = ASOverlayLayoutSpec(child: self.imageMessageNode, overlay: dateLayout)
        
        return ASOverlayLayoutSpec(child: overlay, overlay: centerSpec)
    }
    
    // MARK: UILongPressGestureRecognizer Selector Methods
    
    /**
     Overriding canBecomeFirstResponder to make cell first responder
     */
    override open func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    /**
     Override method from superclass
     */
    open override func messageNodeLongPressSelector(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            
            let touchLocation = recognizer.location(in: view)
            if self.imageMessageNode.frame.contains(touchLocation) {
                
                view.becomeFirstResponder()
                
                delay(0.1, closure: {
                    let menuController = UIMenuController.shared
                    menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(ImageContentNode.copySelector))]
                    menuController.setTargetRect(self.imageMessageNode.frame, in: self.view)
                    menuController.setMenuVisible(true, animated:true)
                })
            }
        }
    }
    
    
    open override func messageTapSelector(_ recognizer: UITapGestureRecognizer) {
        print("messageTapSelector")
        if let url = videoUrl {
            print(url)
            let controller = AVPlayerViewController()
            if url.absoluteString.contains("http") {
                controller.player =  AVPlayer(url: url)
                currentViewController?.present(controller, animated: true, completion: {
                    controller.player?.play()
                })
            } else {
                controller.player =  AVPlayer(playerItem: AVPlayerItem(asset:  AVAsset(url: url)))
                currentViewController?.present(controller, animated: true, completion: {
                    controller.player?.play()
                })
            }
        }
    }
    
    /**
     Copy Selector for UIMenuController
     Puts the node's image on UIPasteboard
     */
    @objc open func copySelector() {
        if let image = self.image {
            UIPasteboard.general.image = image
        }
    }
    
}

