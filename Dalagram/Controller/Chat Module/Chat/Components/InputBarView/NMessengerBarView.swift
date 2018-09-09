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
import AVFoundation
import Photos
import Gallery
import AsyncDisplayKit
import MobileCoreServices

//MARK: InputBarView
/**
 InputBarView class for NMessenger.
 Define the input bar for NMessenger. This is where the user would type text and open the camera or photo library.
 */

enum SendButtonState {
    case audio
    case text
}

open class NMessengerBarView: InputBarView, UITextViewDelegate, GalleryControllerDelegate {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var audioRecordingView: UIView!
    
    lazy var audioTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 15.0)
        return label
    }()
    
    var timer: Timer?
    var seconds: Int = 0
    var isAudioCancelled: Bool = false
    
    //@IBOutlet for InputBarView
    @IBOutlet open weak var inputBarView: UIView!
    //@IBOutlet for send button
    @IBOutlet open weak var replyLabel: UILabel!
    @IBOutlet open weak var replyView: UIView!
    @IBOutlet open weak var sendButton: UIButton!
    //@IBOutlets NSLayoutConstraint input area view height
    @IBOutlet open weak var textInputAreaViewHeight: NSLayoutConstraint!
    //@IBOutlets NSLayoutConstraint input view height
    @IBOutlet open weak var textInputViewHeight: NSLayoutConstraint!
    
    //MARK: Public Parameters
    
    //CGFloat to the fine the number of rows a user can type
    open var numberOfRows:CGFloat = 3
    
    //String as placeholder text in input view
    open var inputTextViewPlaceholder: String = "Введите сообщение.."
    {
        willSet(newVal)
        {
            self.textInputView.text = newVal
        }
    }
    
    // Send Button State (Audio, Text)
    var sendButtonState: SendButtonState = .audio {
        didSet {
            sendButton.setImage(sendButtonState == .audio ? #imageLiteral(resourceName: "icon_audio") : #imageLiteral(resourceName: "icon_send"), for: .normal)
        }
    }
    
    //MARK: Private Parameters
    
    //CGFloat as defualt height for input view
    fileprivate let textInputViewHeightConst:CGFloat = 35
    
    // MARK: Initialisers
    
    public required init() {
        super.init()
    }

    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     Calls helper method to setup the view
     */
    public required init(controller: NMessengerViewController) {
        super.init(controller: controller)
        loadFromBundle()
    }
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     - parameter frame: Must be CGRect. Sets frame for the view.
     Calls helper method to setup the view
     */
    public required init(controller:NMessengerViewController,frame: CGRect) {
        super.init(controller: controller,frame: frame)
        loadFromBundle()
    }
    /**
     - parameter aDecoder: Must be NSCoder
     Calls helper method to setup the view
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromBundle()
    }
    
    // MARK: Initialiser helper methods
    /**
     Loads the view from nib file InputBarView and does intial setup.
     */
    fileprivate func loadFromBundle() {
        
        // Gallery Picker Configs
        Config.Grid.FrameView.borderColor = UIColor.navBlueColor
        Config.Camera.imageLimit = 6
        Config.initialTab = Config.GalleryTab.imageTab
        Config.Camera.recordLocation = false
        Config.VideoEditor.savesEditedVideoToLibrary = false
        
        _ = Bundle(for: NMessengerViewController.self).loadNibNamed("NMessengerBarView", owner: self, options: nil)?[0] as! UIView
        self.addSubview(inputBarView)
        inputBarView.frame = self.bounds
        textInputView.delegate = self
        
        // Customize
        self.textInputView.layer.borderColor = UIColor(white: 0.8, alpha: 0.8).cgColor
        self.textInputView.layer.borderWidth = 0.5
        self.textInputView.layer.cornerRadius = 5.0
        self.textInputAreaView.backgroundColor = UIColor.lightGrayColor
        
        self.replyAreaHeighConstraint.constant = 0.0
    
        configureAudioView()

    }
    
    // MARK: - Configure Audio Recording View
    
    func configureAudioView() {
        sendButtonState = .audio
        
        let swipeToCloseLabel: UILabel = UILabel()
        swipeToCloseLabel.text = "Влево - отмена"
        
        audioRecordingView.backgroundColor = UIColor.lightGrayColor
        audioRecordingView.addSubview(audioTimeLabel)
        audioRecordingView.addSubview(swipeToCloseLabel)
        
        audioTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16.0)
            make.centerY.equalToSuperview()
        }
        
        swipeToCloseLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(audioButonLongPress))
        sendButton.addGestureRecognizer(longGesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(audioButtonSwipeAction))
        swipeGesture.direction = .left
        sendButton.addGestureRecognizer(swipeGesture)
        
        let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(sendButonDoublePress))
        doubleGesture.numberOfTapsRequired = 2
        sendButton.addGestureRecognizer(doubleGesture)
        
    }
    
    func scheduleAudioTimer() {
        seconds = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerAction), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    // MARK: - Update Timer Action
    
    @objc func updateTimerAction() {
        seconds = seconds + 1
        let minute = seconds/60
        let realSeconds = seconds % 60 == 0 ? 0 : seconds % 60
        let prefixSec = realSeconds < 10 ? "0" : ""
        audioTimeLabel.text = "\(minute):\(prefixSec)\(realSeconds)"
        print(seconds)
    }
    
    // MARK: - Send Button Touch Actions
    
    @objc func audioButonLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if sendButtonState == .audio {
            switch gestureRecognizer.state {
                case .began:
                    print("began recording")
                    isAudioCancelled = false
                    scheduleAudioTimer()
                    self.audioRecordingView.alpha = 0
                    self.audioRecordingView.isHidden = false
                    UIView.animate(withDuration: 0.3) {
                        self.audioRecordingView.alpha = 1
                    }
                
                case .changed:
                    //print("changed recording")
                    let longPressView = gestureRecognizer.view
                    let longPressPoint = gestureRecognizer.location(in: longPressView)
                    print(longPressPoint)
                    
                    if longPressPoint.x < -20.0 {
                        audioButtonSwipeAction()
                    }
                    break
                case .ended:
                    print("end recording")
                    if !isAudioCancelled {
                        hideAudioMessageView()
                        print("send audio message")
                    }
                default:
                    break
            }
        }
    }
    
    @objc func audioButtonSwipeAction() {
        print("swipped")
        isAudioCancelled = true
        hideAudioMessageView()
    }
    
    func hideAudioMessageView() {
        timer?.invalidate()
        timer = nil
        UIView.animate(withDuration: 0.3, animations: {
            self.audioRecordingView.alpha = 0
        }) { (completed) in
            self.audioRecordingView.isHidden = completed
        }
    }
    
    @objc func sendButonDoublePress() {
        switch sendButtonState {
        case .audio:
            sendButtonState = .text
        case .text:
            sendButtonState = .audio
        }
    }
    
   
    
    // MARK: - Close Reply Button Action
    @IBAction func closeReplyAreaAction(_ sender: UIButton) {
        changeReplyArea(with: "")
        isReplyMessage.value = false
    }
    
    //MARK: TextView delegate methods
    
    /**
     Implementing textViewShouldBeginEditing in order to set the text indicator at position 0
     */
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        if textView.text == inputTextViewPlaceholder {
            textView.text = ""
        }
       
        sendButtonState = .text
        textView.textColor = UIColor.n1DarkestGreyColor()
        UIView.animate(withDuration: 0.1, animations: {
            self.sendButton.isEnabled = true
        })
        DispatchQueue.main.async(execute: {
            textView.selectedRange = NSMakeRange(textView.text.count, textView.text.count)
        })
        return true
    }
    /**
     Implementing textViewShouldEndEditing in order to re-add placeholder and hiding send button when lost focus
    */
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {

        if self.textInputView.text.isEmpty {
            self.addInputSelectorPlaceholder()
        }
        self.textInputView.resignFirstResponder()
        return true
    }
    /**
     Implementing shouldChangeTextInRange in order to remove placeholder when user starts typing and to show send button
     Re-sizing the text area to default values when the return button is tapped
     Limit the amount of rows a user can write to the value of numberOfRows
    */
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
   
        if textView.text == "" && (text != "\n") {
            UIView.animate(withDuration: 0.1, animations: {
                self.sendButton.isEnabled = true
            }) 
            return true
        }
        else if (text == "\n") && textView.text != "" {
            if textView == self.textInputView {
                textInputViewHeight.constant = textInputViewHeightConst
                print(textInputViewHeightConst + 10)
                textInputAreaViewHeight.constant = textInputViewHeightConst + 10
                _ = self.controller.sendText(self.textInputView.text, date: Date().getStringTime(), isIncomingMessage: false)
                self.textInputView.text = ""
                return false
            }
        }
        else if (text != "\n") {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            var textWidth: CGFloat = UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset).width
            textWidth -= 2.0 * textView.textContainer.lineFragmentPadding
            let boundingRect: CGRect = newText.boundingRect(with: CGSize(width: textWidth, height: 0), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedStringKey.font: textView.font!], context: nil)
            let numberOfLines = boundingRect.height / textView.font!.lineHeight;
            return numberOfLines <= numberOfRows
        }
        return false
    }
    
    /**
     Implementing textViewDidChange in order to resize the text input area
     */
    open func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textInputViewHeight.constant = newFrame.size.height
        textInputAreaViewHeight.constant = newFrame.size.height + 10
        
        // Emit "Typing" Event
        self.controller.sendTypingEvent()
    }
    
    //MARK: TextView helper methods
    /**
     Adds placeholder text and change the color of textInputView
     */
    
    fileprivate func addInputSelectorPlaceholder() {
        self.textInputView.text = self.inputTextViewPlaceholder
        self.textInputView.textColor = UIColor.lightGray
    }
    
    //MARK: @IBAction selectors
    /**
     Send button selector
     Sends the text in textInputView to the controller
     */
    
    @IBAction open func sendButtonClicked(_ sender: AnyObject) {
//        if sendButtonState == .text && self.textInputView.text != inputTextViewPlaceholder {
//            textInputViewHeight.constant = textInputViewHeightConst
//            textInputAreaViewHeight.constant = textInputViewHeightConst + 10
//            if self.textInputView.text != ""
//            {
//                _ = self.controller.sendText(self.textInputView.text, date: Date().getStringTime(), isIncomingMessage: false)
//                self.textInputView.text = ""
//            }
//        }
        _ = self.controller.sendAudio("100", data: Data(), date: Date().getStringTime(), isIncomingMessage: false)
        
    }
    
    /**
     Attach button selector
     Requests camera and photo library permission if needed
     Open camera and/or photo library to take/select a photo
     */
    
    @IBAction open func plusClicked(_ sender: AnyObject?) {
        let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
        let mediaAction = UIAlertAction(title: "Фото и видео", style: .default) { _ in
            let gallery = GalleryController()
            gallery.delegate = self
            self.controller.present(gallery, animated: true, completion: nil)
        }
        let fileAction = UIAlertAction(title: "Документы", style: .default) { _ in
            let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.controller.present(importMenu, animated: true, completion: nil)
        }
        let contactAction = UIAlertAction(title: "Контакты", style: .default) { _ in
            let vc = AllContactsController()
            let navController = UINavigationController(rootViewController: vc)
            vc.completionBlock = { contactObj in
                // contactObj is ContactFacade object as completion parameter
                if let contact = contactObj.phoneContact {
                    _ = self.controller.sendContact(imageUrl: "", name: contact.getFullName(), phone: contact.phone, date: Date().getStringTime(), userId: 0, isIncomingMessage: false)
                }
                else if let contact = contactObj.dalagramContact {
                    _ = self.controller.sendContact(imageUrl: contact.avatar, name: contact.contact_name, phone: contact.user_name, date: Date().getStringTime(), userId: contact.user_id, isIncomingMessage: false)
                }
            }
            self.controller.present(navController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(mediaAction)
        alert.addAction(fileAction)
        alert.addAction(contactAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor.darkBlueNavColor
        self.controller.present(alert, animated: true, completion: nil)
       
    }
    
    // MARK: - Gallery DidSelectImages
    
    public func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        print("Selected Gallery Image", images.count)
        if images.count == 1 {
            // Single Image
            if let selectedImage = images.first {
                selectedImage.resolve(completion: { (resolvedImage) in
                    if let image = resolvedImage {
                        _ = self.controller.sendImage(image, isIncomingMessage: false)
                        self.controller.dismiss(animated: true, completion: nil)
                    }
                })
            }
        } else {
            // Mutiple Images
            Image.resolve(images: images) { (resolvedImages) in
                if let images = resolvedImages as? [UIImage] {
                    let imageNodes = images.map { (selectedImage) -> ImageContentNode in
                        let imageContentNode = ImageContentNode(image: selectedImage, date: Date().getStringTime(), currentVC: self.controller)
                        return imageContentNode
                    }
                    _ = self.controller.sendCollectionViewWithNodes(imageNodes, numberOfRows: CGFloat(imageNodes.count), isIncomingMessage: false)
                    self.controller.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Gallery DidSelectVideo
    
    public func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        print("Select video delegate")
        var thumbVideoImage: UIImage?
        
        video.fetchThumbnail(size: CGSize(width: 300, height: 300), completion: { (image) in
            if let thumbImage = image {
                thumbVideoImage = thumbImage
            }
        })
        
        video.fetchAVAsset { (asset) in
            if let urlAsset = asset as? AVURLAsset {
                print("url video fetched")
                do {
                    let data = try Data(contentsOf: urlAsset.url)
                    print("url thumg fetched", urlAsset.url)
                    if let image = thumbVideoImage {
                        _ = self.controller.sendVideo(image, videoUrl: urlAsset.url, videoData: data, isIncomingMessage: false)
                        self.controller.dismiss(animated: true, completion: nil)
                    }
                } catch {
                    WhisperHelper.showErrorMurmur(title: "Ошибка загрузки видео")
                }
            }
        }
    }
    
    public func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        print("requestLightbox delegate")
    }
    
    public func galleryControllerDidCancel(_ controller: GalleryController) {
        self.controller.dismiss(animated: true, completion: nil)
    }

}

// MARK: - UIDocumentMenuDelegate

extension NMessengerBarView: UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let fileName = url.lastPathComponent
        let fileExtension = NSString(string: fileName).pathExtension
        
        do {
            let data = try Data(contentsOf: url)
            _ = self.controller.sendDocument(fileName, fileExtension: fileExtension, fileData: data, isIncomingMessage: false)
        } catch {
            WhisperHelper.showErrorMurmur(title: "Ошибка загрузки документа")
            print("error converting from file url to data")
        }
    }
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.controller.present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
        print("view was cancelled")
        self.controller.dismiss(animated: true, completion: nil)
    }
    
}

