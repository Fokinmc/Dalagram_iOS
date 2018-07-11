//
//  EditChannelController.swift
//  Dalagram
//
//  Created by Toremurat on 05.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class EditChannelController: UITableViewController {
    
    @IBOutlet weak var channelLoginField: UITextField!
    @IBOutlet weak var channelNameField: UITextField!
    @IBOutlet weak var channelImage: UIImageView!
    
    lazy var changeButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Ред.", style: .plain, target: self, action: #selector(changeBarButtonAction))
        item.tintColor = UIColor.white
        return item
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    var changeButtonState: Bool = false
    var channelInfo: DialogInfo!
    var isChannelPublic: Int = 0 // false
    var channelContacts: [JSONContact] = []
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Канал"
        configureUI()
        loadChannelDetails()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        setEmptyBackTitle()
        
        if channelInfo.is_admin == 1 {
            self.navigationItem.rightBarButtonItem = changeButtonItem
        }
        
        tableView.registerNib(ContactCell.self)
        tableView.tableFooterView = UIView()
        
        channelImage.layer.cornerRadius = channelImage.frame.width/2
        channelImage.clipsToBounds = true
        if let detail = channelInfo {
            channelImage.kf.setImage(with: URL(string: detail.avatar), placeholder: #imageLiteral(resourceName: "bg_gradient_3"))
            channelNameField.text = detail.user_name
        }
    }
    
    // MARK: Scroll View Dragging
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // MARK: - Change Bar Button Action
    
    @objc func changeBarButtonAction() {
        if changeButtonState {
            // SAVE
            changeButtonState = false
            channelNameField.font = UIFont.systemFont(ofSize: 17.0)
            channelNameField.isEnabled = false
            channelLoginField.font = UIFont.systemFont(ofSize: 17.0)
            channelLoginField.isEnabled = false
            editChannelRequest()
        } else {
            // CHANGE
            channelNameField.isEnabled = true
            channelNameField.font = UIFont.systemFont(ofSize: 18.0)
            channelLoginField.font = UIFont.systemFont(ofSize: 18.0)
            channelLoginField.isEnabled = true
            channelNameField.becomeFirstResponder()
            changeButtonState = true
        }
        changeButtonItem.title = changeButtonState ? "Сохранить" :  "Ред."
    }
    
    // MARK: - Get Group Details
    
    func loadChannelDetails() {
        NetworkManager.makeRequest(.getChannelDetails(channel_id: channelInfo.channel_id), success: { [weak self] (json) in
            print(json)
            guard let vc = self else { return }
            vc.channelContacts.removeAll()
            
            let data = json["data"]
            vc.isChannelPublic = data["is_public"].intValue
            vc.channelNameField.text = data["channel_name"].stringValue
            vc.channelLoginField.text = data["channel_login"].stringValue
            vc.channelImage.kf.setImage(with: URL(string: data["channel_avatar"].stringValue), placeholder: #imageLiteral(resourceName: "bg_gradient_3"))
            for (_, subJson):(String, JSON) in data["channel_users"] {
                let newContact = JSONContact(json: subJson)
                vc.channelContacts.append(newContact)
            }
            vc.tableView.reloadData()
        })
    }
    
    // MARK: - Edit Group Api
    
    func editChannelRequest() {
        if !channelNameField.text!.isEmpty && !channelLoginField.text!.isEmpty {
            SVProgressHUD.show()
            NetworkManager.makeRequest(.editChannel(channel_id: channelInfo.channel_id, name: channelNameField.text!, login: channelLoginField.text!), success: { (json) in
                SVProgressHUD.dismiss()
                WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
                NotificationCenter.default.post(name: AppManager.dialogDetailsNotification, object: nil)
            })
        }
    }
    
    // MARK:
    func showMembersActionSheet(data: JSONContact) {
        let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.darkBlueNavColor
        let adminAction = UIAlertAction(title: "Сделать администратором ", style: .default) { [unowned self] (act) in
            NetworkManager.makeRequest(.setChannelAdmin(channel_id: self.channelInfo.channel_id, user_id: data.user_id), success: { (json) in
                WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
                NotificationCenter.default.post(name: AppManager.dialogDetailsNotification, object: nil)
                self.loadChannelDetails()
            })
        }
        let deleteAction = UIAlertAction(title: "Удалить из канала", style: .default) { (act) in
            NetworkManager.makeRequest(.removeChannelMember(channel_id: self.channelInfo.channel_id, user_id: data.user_id), success: { (json) in
                WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
                NotificationCenter.default.post(name: AppManager.dialogDetailsNotification, object: nil)
                self.loadChannelDetails()
            })
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(adminAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table view data source

extension EditChannelController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Change photo Cell
        case 1: return 2 // Notifications & Media Cell
        case 2: return 1 // Add Members Cell
        case 3: return channelContacts.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditPhotoCell", for: indexPath)
            return cell
        case 1 where indexPath.row == 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
            return cell
        case 1 where indexPath.row == 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath)
            return cell
        case 2:
            if channelInfo.is_admin == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddMembersCell", for: indexPath)
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "HeaderCell")
                cell.textLabel?.text = "УЧАСТНИКИ"
                cell.textLabel?.textColor = UIColor.lightGray
                cell.isUserInteractionEnabled = false
                return cell
            }
        case 3:
            let cell: ContactCell = tableView.dequeReusableCell(for: indexPath)
            cell.setupRegisteredContact(channelContacts[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Change photo
            self.present(imagePicker, animated: true, completion: nil)
        case 1 where indexPath.row == 1: // Collection of media
            let vc = MediaColletionController()
            self.show(vc, sender: nil)
        case 2: // Add a Group Member
            let vc = ChatContactsController(chatType: .channel, dialogInfo: channelInfo)
            vc.title = "Выберите контакт"
            vc.groupCompletion = { [unowned self] in
                self.loadChannelDetails()
            }
            self.show(vc, sender: nil)
        case 3: // List of Group Members
            showMembersActionSheet(data: channelContacts[indexPath.row])
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 3 ? 0.0 : 40.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

// MARK: - UIImagePickerControllerDelegate

extension EditChannelController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        channelImage.image = image
        if let data = channelInfo, let photo = UIImageJPEGRepresentation(image, 0.5) {
            SVProgressHUD.show()
            NetworkManager.makeRequest(.uploadGroupPhoto(group_id: data.group_id, image: photo), success: { (json) in
                print(json)
                SVProgressHUD.dismiss()
                WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
                NotificationCenter.default.post(name: AppManager.dialogDetailsNotification, object: nil)
            })
        }
        
    }
}
