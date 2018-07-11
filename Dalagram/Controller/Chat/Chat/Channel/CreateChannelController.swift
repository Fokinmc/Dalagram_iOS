//
//  CreateChannelController.swift
//  Dalagram
//
//  Created by Toremurat on 29.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateChannelController: UITableViewController {
    
    // MARK: - IBOutlets
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    lazy var saveButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Пропустить", style: .plain, target: self, action: #selector(createChannelAction))
        item.tintColor = UIColor.white
        return item
    }()
    
    @IBOutlet weak var channelPrefix: UILabel!
    @IBOutlet weak var channelLogin: UITextField!
    @IBOutlet weak var channelName: UITextField!
    @IBOutlet weak var channelImage: UIImageView!
    
    // MARK: - Variables
    
    var isImagePicked: Bool = false {
        didSet {
            channelPrefix.isHidden = isImagePicked
        }
    }
    
    var viewModel: ContactsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Новый канал"
        configureUI()
    }
    
    // MARK: - Configure UI
    
    func configureUI() {
        channelImage.image = #imageLiteral(resourceName: "bg_gradient_3")
        channelImage.layer.cornerRadius = channelImage.frame.width/2
        channelImage.clipsToBounds = true
        tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = saveButtonItem
        channelLogin.addTarget(self, action: #selector(channelLoginDidChage), for: UIControlEvents.allEditingEvents)
    }
    
    // MARK: Scroll View Dragging
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // MARK: - Channel Login TextField Did Change
    
    @objc func channelLoginDidChage() {
        guard let login = channelLogin.text else { return }
        if login.isEmpty {
            channelLogin.text = "@"
        }
    }
    // MARK: - Upload Photo Action
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Create Channel Action
    
    @objc func createChannelAction() {
        guard let name = channelName.text, !name.isEmpty, let login = channelLogin.text, !login.isEmpty, login.count > 1 else {
            WhisperHelper.showErrorMurmur(title: "Заполните название группы")
            return
        }
        if isImagePicked {
            if let imageData = UIImageJPEGRepresentation(channelImage.image!, 0.5) {
                SVProgressHUD.show()
                NetworkManager.makeRequest(.createChannel(name: name, login: login, users: viewModel.getGroupJsonArray(), image: imageData), success: { [weak self] (json) in
                    self?.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: AppManager.loadDialogsNotification, object: nil)
                    SVProgressHUD.dismiss()
                })
            }
        } else {
            SVProgressHUD.show()
            NetworkManager.makeRequest(.createChannel(name: name, login: login, users: viewModel.getGroupJsonArray(), image: nil), success: { [weak self] (json) in
                self?.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: AppManager.loadDialogsNotification, object: nil)
                SVProgressHUD.dismiss()
            })
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}

// MARK: - UIImagePickerControllerDelegate

extension CreateChannelController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        channelImage.image = image
        isImagePicked = true
    }
}

