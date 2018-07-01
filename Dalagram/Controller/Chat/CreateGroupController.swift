//
//  CreateGroupController.swift
//  Dalagram
//
//  Created by Toremurat on 29.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var groupImage: UIImageView!
    
    // MARK: - Variables
    var isImagePicked: Bool = false
    var viewModel: ContactsViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Create Group Action
    
    @objc func createButtonPressed() {
        guard let name = groupNameField.text, !name.isEmpty else {
            WhisperHelper.showErrorMurmur(title: "Заполните название группы")
            return
        }
        if isImagePicked {
            if let imageData = UIImageJPEGRepresentation(groupImage.image!, 0.5) {
                NetworkManager.makeRequest(.createGroup(name: name, users: viewModel.getGroupJsonArray(), image: imageData), success: { [weak self] (json) in
                    self?.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name("loadDialogsFromServer"), object: nil)
                    print(json)
                })
            }
        } else {
            NetworkManager.makeRequest(.createGroup(name: name, users: viewModel.getGroupJsonArray(), image: nil), success: { [weak self] (json) in
                self?.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name("loadDialogsFromServer"), object: nil)
                print(json)
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
        return viewModel.selectedContacts.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupContactCell = tableView.dequeReusableCell(for: indexPath)
        let contacts = viewModel.selectedContacts.value
        cell.setupContact(contacts[indexPath.row] as! Contact)
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
