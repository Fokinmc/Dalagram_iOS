//
//  CreateGroupController.swift
//  Dalagram
//
//  Created by Toremurat on 29.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateGroupController: UITableViewController {

    // MARK: - IBOutlets
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    lazy var saveButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Создать", style: .plain, target: self, action: #selector(createButtonPressed))
        item.tintColor = UIColor.white
        return item
    }()
    
    @IBOutlet weak var groupPrefix: UILabel!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var groupImage: UIImageView!
    
    // MARK: - Variables
    
    var isImagePicked: Bool = false {
        didSet {
            groupPrefix.isHidden = isImagePicked
        }
    }
    
    var viewModel: ContactsViewModel! {
        didSet {
            parseGroupContacts()
        }
    }
    
    var groupContacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: Prepare Group Contacts as a Array
    
    func parseGroupContacts() {
        for item in viewModel.selectedContacts.value {
            groupContacts.append(item.value)
        }
        tableView.reloadData()
    }
    
    // MARK: - Configure UI
    
    func configureUI() {
        self.title = "Новая группа"
        groupImage.image = #imageLiteral(resourceName: "bg_gradient_0")
        groupImage.layer.cornerRadius = groupImage.frame.width/2
        groupImage.clipsToBounds = true
        groupImage.isUserInteractionEnabled = false
        
        tableView.register(GroupContactCell.self)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.groupTableViewBackground
        
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    // MARK: Scroll View Dragging
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // MARK: - IBOutlets
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        if isImagePicked {
            let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
            let uploadAction = UIAlertAction(title: "Загрузить другое фото", style: .default, handler: { [unowned self] (act) in
                 self.present(self.imagePicker, animated: true, completion: nil)
            })
            let deleteAction = UIAlertAction(title: "Удалить текущее фото", style: .default, handler: { [unowned self] (act) in
                self.groupImage.image = #imageLiteral(resourceName: "bg_gradient_0")
                self.isImagePicked = false
            })
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alert.addAction(uploadAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Create Group Action
    
    @objc func createButtonPressed() {
        guard let name = groupNameField.text, !name.isEmpty else {
            WhisperHelper.showErrorMurmur(title: "Заполните название группы")
            return
        }
        if isImagePicked {
            if let imageData = UIImageJPEGRepresentation(groupImage.image!, 0.5) {
                SVProgressHUD.show()
                NetworkManager.makeRequest(.createGroup(name: name, users: viewModel.getGroupJsonArray(), image: imageData), success: { [weak self] (json) in
                    self?.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: AppManager.loadDialogsNotification, object: nil)
                    SVProgressHUD.dismiss()
                })
            }
        } else {
            SVProgressHUD.show()
            NetworkManager.makeRequest(.createGroup(name: name, users: viewModel.getGroupJsonArray(), image: nil), success: { [weak self] (json) in
                self?.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: AppManager.loadDialogsNotification, object: nil)
                SVProgressHUD.dismiss()
            })
        }
    }
}

// MARK: - Table view data source

extension CreateGroupController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupContactCell = tableView.dequeReusableCell(for: indexPath)
        cell.setupContact(groupContacts[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.init(0))
        header.backgroundView?.backgroundColor = UIColor.lightGrayColor
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "УЧАСТНИКИ"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CreateGroupController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        groupImage.image = image
        isImagePicked = true
    }
}
