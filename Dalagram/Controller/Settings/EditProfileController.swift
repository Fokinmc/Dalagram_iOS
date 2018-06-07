//
//  EditProfileController.swift
//  Dalagram
//
//  Created by Toremurat on 07.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditProfileController: UITableViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    lazy var saveButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(saveButtonPressed))
        item.tintColor = UIColor.white
        return item
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    // MARK: - Variables
    
    var viewModel: ProfileViewModel!
    let disposeBag = DisposeBag()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Редактирование"
        configureUI()
        configureEvents()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        hideKeyboardWhenTappedAround()
        avatarView.layer.cornerRadius = avatarView.frame.width/2
        tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    // MARK: - Configuring Events
    
    func configureEvents() {
        nameField.text   = viewModel.name.value
        statusField.text = viewModel.status.value
        emailField.text  = viewModel.email.value
        
        //avatarView.kf.setImage(with: URL(string: viewModel.avatar.value), placeholder: #imageLiteral(resourceName: "userprofile"))
        
        nameField.rx.text.orEmpty.bind(to: viewModel.name).disposed(by: disposeBag)
        statusField.rx.text.orEmpty.bind(to: viewModel.status).disposed(by: disposeBag)
        emailField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)

    }
    
    // MARK: - Avatar View Action
    
    @IBAction func avatarGesturePressed(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Save BarButton Action
    @objc func saveButtonPressed() {
        viewModel.editProfile {
            self.viewModel.isNeedToUpdate.value = true
            self.navigationController?.popViewController(animated: true)
        }
    }

}

// MARK: - Image Picker Delegate

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        avatarView.image = image
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
