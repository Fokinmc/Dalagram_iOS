//
//  EditGroupController.swift
//  Dalagram
//
//  Created by Toremurat on 29.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class EditGroupController: UITableViewController {

    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var groupImage: UIImageView!
    
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
    var groupInfo: DialogInfo!
    var groupContacts: [JSONContact] = []
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Группа"
        configureUI()
        loadGroupDetails()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        self.navigationItem.rightBarButtonItem = changeButtonItem
        
        tableView.registerNib(ContactCell.self)
        tableView.tableFooterView = UIView()
        
        groupImage.layer.cornerRadius = groupImage.frame.width/2
        groupImage.clipsToBounds = true
        if let detail = groupInfo {
            groupImage.kf.setImage(with: URL(string: detail.avatar), placeholder: #imageLiteral(resourceName: "bg_gradient_0"))
            groupNameField.text = detail.user_name
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
            groupNameField.font = UIFont.systemFont(ofSize: 17.0)
            groupNameField.isEnabled = false
            editGroupRequest()
        } else {
            // CHANGE
            groupNameField.isEnabled = true
            groupNameField.font = UIFont.systemFont(ofSize: 18.0)
            groupNameField.becomeFirstResponder()
            changeButtonState = true
        }
        changeButtonItem.title = changeButtonState ? "Сохранить" :  "Ред."
    }
    
    // MARK: - Get Group Details
    
    func loadGroupDetails() {
        NetworkManager.makeRequest(.getGroupDetails(group_id: groupInfo.group_id), success: { [weak self] (json) in
            guard let vc = self else { return }
            vc.groupContacts.removeAll()
            vc.groupNameField.text = json["data"]["group_name"].stringValue
            vc.groupImage.kf.setImage(with: URL(string: json["data"]["group_avatar"].stringValue), placeholder: #imageLiteral(resourceName: "bg_gradient_0"))
            for (_, subJson):(String, JSON) in json["data"]["group_users"] {
                let newContact = JSONContact(json: subJson)
                vc.groupContacts.append(newContact)
            }
            vc.tableView.reloadData()
        })
    }
    
    // MARK: - Edit Group Api
    
    func editGroupRequest() {
        if groupInfo.user_name != groupNameField.text && !groupNameField.text!.isEmpty {
            SVProgressHUD.show()
            NetworkManager.makeRequest(.editGroup(group_id: groupInfo.group_id, group_name: groupNameField.text!), success: { [weak self] (json) in
                SVProgressHUD.dismiss()
                WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
                NotificationCenter.default.post(name: AppManager.dialogDetailsNotification, object: nil)
                self?.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    // MARK:
    func showMembersActionSheet(data: JSONContact) {
        let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.darkBlueNavColor
        let adminAction = UIAlertAction(title: "Сделать администратором ", style: .default) { [unowned self] (act) in
            NetworkManager.makeRequest(.setGroupAdmin(group_id: self.groupInfo.group_id, user_id: data.user_id), success: { (json) in
                WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
                self.loadGroupDetails()
            })
        }
        let deleteAction = UIAlertAction(title: "Удалить из группы", style: .default) { (act) in
            NetworkManager.makeRequest(.removeGroupMember(group_id: self.groupInfo.group_id, user_id: data.user_id), success: { (json) in
                WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
                self.loadGroupDetails()
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

extension EditGroupController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Change photo Cell
        case 1: return 2 // Notifications & Media Cell
        case 2: return 1 // Add Members Cell
        case 3: return groupContacts.count
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddMembersCell", for: indexPath)
            return cell
        case 3:
            let cell: ContactCell = tableView.dequeReusableCell(for: indexPath)
            cell.setupRegisteredContact(groupContacts[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Change photo
            self.present(imagePicker, animated: true, completion: nil)
        case 3: // Group Members
            showMembersActionSheet(data: groupContacts[indexPath.row])
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

extension EditGroupController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        groupImage.image = image
        if let data = groupInfo, let photo = UIImageJPEGRepresentation(image, 0.5) {
            SVProgressHUD.show()
            NetworkManager.makeRequest(.uploadGroupPhoto(group_id: data.group_id, image: photo), success: { (json) in
                print(json)
                SVProgressHUD.dismiss()
                WhisperHelper.showSuccessMurmur(title: "")
            })
        }
        
    }
}
