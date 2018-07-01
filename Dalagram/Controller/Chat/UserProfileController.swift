//
//  UserProfileController.swift
//  Dalagram
//
//  Created by Toremurat on 10.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

class UserProfileController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var userPhoneLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    // MARK: - Variables
    var contact: DialogInfo!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Контакная информация"
        configureUI()
        
        userPhoneLabel.text = contact.phone
        userImageView.kf.setImage(with: URL(string: contact.avatar))
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        mediaCollectionView.register(MediaCell.self)
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
    }

}

// MARK: - UITableViewDelegate, UITalbeViewDataSource

extension UserProfileController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension UserProfileController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaCell = collectionView.dequeReusableCell(for: indexPath)
        cell.mediaImageView.image = #imageLiteral(resourceName: "bg_gradient_2")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
}
