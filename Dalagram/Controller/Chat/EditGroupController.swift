//
//  EditGroupController.swift
//  Dalagram
//
//  Created by Toremurat on 29.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SVProgressHUD

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
    var groupInfo: DialogInfo?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Группа"
        configureUI()
        
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        self.navigationItem.rightBarButtonItem = changeButtonItem
        
        tableView.register(ContactCell.self)
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
        } else {
            // CHANGE
            groupNameField.isEnabled = true
            groupNameField.font = UIFont.systemFont(ofSize: 18.0)
            groupNameField.becomeFirstResponder()
            changeButtonState = true
        }
        changeButtonItem.title = changeButtonState ? "Сохранить" :  "Ред."
    }
}

// MARK: - Table view data source

extension EditGroupController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Change photo
        case 1: return 2 // Notifications & Media
        case 2: return 1 // Members
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
        case 2 where indexPath.row == 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddMembersCell", for: indexPath)
            return cell
        default:
            let cell: ContactCell = tableView.dequeReusableCell(for: indexPath)
            return cell
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Change photo
            self.present(imagePicker, animated: true, completion: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
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
