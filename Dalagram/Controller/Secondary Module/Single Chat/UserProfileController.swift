//
//  UserProfileController.swift
//  Dalagram
//
//  Created by Toremurat on 10.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import RealmSwift
import SwiftyJSON

class UserProfileController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var filesCountLabel: UILabel!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var userPhoneLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    // MARK: - Variables
    var contact: DialogInfo!
    var mediaFiles: [JSONChatFile] = []
    var dialogId: String = ""
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Контакная информация"
        configureUI()
        setupData()
        setEmptyBackTitle()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        mediaCollectionView.register(MediaCell.self)
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Setup Data
    
    func setupData() {
        
        userPhoneLabel.text = contact.phone
        userImageView.kf.setImage(with: URL(string: contact.avatar))
        
        NetworkManager.makeRequest(.getMediaFiles(["page" : 1, "partner_id": contact.user_id]), success: { [weak self] (json) in
            guard let vc = self else { return }
            for (_, subJson):(String, JSON) in json["data"] {
                let format = subJson["file_format"].stringValue
                if format == "image" || format == "video" {
                    let file = JSONChatFile(json: subJson)
                    vc.mediaFiles.append(file)
                }
            }
            vc.filesCountLabel.text = "\(vc.mediaFiles.count)"
            vc.mediaCollectionView.reloadData()
        })
    }
    
    // MARK: - Clear Chat Request
    
    func clearChatRequest() {
        NetworkManager.makeRequest(.removeChat(["partner_id" : contact.user_id, "is_delete_all": 1]), success: { (json) in
            WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
            //NotificationCenter.default.post(name: AppManager.diloagHistoryNotification, object: nil)
            NotificationCenter.default.post(name: AppManager.loadDialogsNotification, object: nil)
        })
        removeCurrentDialogHistory()
    }
    
    // MARK: - Block User Request
    
    func blockUserRequest() {
        NetworkManager.makeRequest(.blockUser(["partner_id" : contact.user_id]), success: { (json) in
            WhisperHelper.showSuccessMurmur(title: json["message"].stringValue)
//            NotificationCenter.default.post(name: AppManager.loadDialogsNotification, object: nil)
        })
    }
    
    func removeCurrentDialogHistory() {
        let realm = try! Realm()
        for object in realm.objects(DialogHistory.self).filter(NSPredicate(format: "id = %@", dialogId)) {
            try! realm.write {
                realm.delete(object)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITalbeViewDataSource

extension UserProfileController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // Profile Photo
            
            if let userImage = userImageView.image {
                let photo = SKPhoto.photoWithImage(userImage)
                let browser = SKPhotoBrowser(photos: [photo])
                browser.initializePageIndex(0)
                self.present(browser, animated: true, completion: nil)
            }
            
        case 2: // Media files
            
            let vc = MediaColletionController(user_id: contact.user_id, files: mediaFiles)
            self.show(vc, sender: nil)
            
        case 3: // Clear Chat
            
            if dialogId.isEmpty {
                return
            }
            let alert = UIAlertController(title: "Вы действительно хотите очистить чат?", message: nil, preferredStyle: .actionSheet)
            alert.view.tintColor = UIColor.darkBlueNavColor
            let clearAction = UIAlertAction(title: "Очистить чат", style: .default, handler: { [unowned self] (act) in
                self.clearChatRequest()
            })
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alert.addAction(clearAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        case 4: // Block contact
            
            let alert = UIAlertController(title: "Выберите", message: nil, preferredStyle: .actionSheet)
            alert.view.tintColor = UIColor.darkBlueNavColor
            let clearAction = UIAlertAction(title: "Заблокировать", style: .default, handler: { [unowned self] (act) in
                self.blockUserRequest()
            })
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alert.addAction(clearAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension UserProfileController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaCell = collectionView.dequeReusableCell(for: indexPath)
        cell.mediaImageView.kf.setImage(with: URL(string: mediaFiles[indexPath.row].file_url), placeholder: #imageLiteral(resourceName: "bg_gradient_0"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MediaCell {
            if let userImage = cell.mediaImageView.image {
                let photo = SKPhoto.photoWithImage(userImage)
                let browser = SKPhotoBrowser(photos: [photo])
                browser.initializePageIndex(0)
                self.present(browser, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
}
