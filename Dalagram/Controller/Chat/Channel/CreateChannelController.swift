//
//  CreateChannelController.swift
//  Dalagram
//
//  Created by Toremurat on 29.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class CreateChannelController: UITableViewController {
    
    // MARK: - IBOutlets
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    lazy var saveButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Создать", style: .plain, target: self, action: #selector(createChannelAction))
        item.tintColor = UIColor.white
        return item
    }()
    
    @IBOutlet weak var channelLogin: UITextField!
    @IBOutlet weak var channelName: UITextField!
    @IBOutlet weak var channelImage: UIImageView!
    
    var isImagePicked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Новый канал"
        configureUI()
    }
    
    // MARK: - Configure UI
    
    func configureUI() {
        channelImage.layer.cornerRadius = channelImage.frame.width/2
        channelImage.clipsToBounds = true
        tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = saveButtonItem
    }
    
    // MARK: Scroll View Dragging
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // MARK: - Upload Photo Action
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Create Channel Action
    
    @objc func createChannelAction() {
         WhisperHelper.showErrorMurmur(title: "Канал делается, в принципе он очень похож на группу. Coming soon")
        guard let name = channelName.text, !name.isEmpty else {
            WhisperHelper.showErrorMurmur(title: "Заполните название группы")
            return
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

