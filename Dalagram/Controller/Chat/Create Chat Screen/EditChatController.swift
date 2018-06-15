//
//  EditChatController.swift
//  Dalagram
//
//  Created by Toremurat on 10.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class EditChatController: UITableViewController {
    
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupNameField: UITextField!
    
    var viewModel: ContactsViewModel!
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Новая группа"
        configureUI()
        print(viewModel.selectedContacts.value.count)
    }
    
    // MARK: - Configure UI
    
    func configureUI() {
        
        setEmptyBackTitle()
        hideKeyboardWhenTappedAround()
        tableView.register(GroupContactCell.self)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.groupTableViewBackground
        
        groupImage.layer.cornerRadius = groupImage.frame.width/2
        groupImage.layer.borderColor = UIColor.lightBlueColor.cgColor
        groupImage.layer.borderWidth = 1.0
        groupImage.image = #imageLiteral(resourceName: "placeholder")
        
        let plusButton = UIBarButtonItem(title: "Создать", style: .plain, target: self, action: #selector(createButtonAction))
        self.navigationItem.rightBarButtonItem = plusButton
        
    }

    // MARK: - Upload Image Button Action
    
    @IBAction func uploadGroupImagePressed(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Create Group Button Action
    
    @objc func createButtonAction() {
        
    }

}

// MARK: - TableView Delegate

extension EditChatController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.selectedContacts.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupContactCell = tableView.dequeReusableCell(for: indexPath)
        cell.setupContact(viewModel.selectedContacts.value[indexPath.row]!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - Image Picker Delegate

extension EditChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        groupImage.image = image
        //viewModel.uploadAvatar(image: image)
    }
}
