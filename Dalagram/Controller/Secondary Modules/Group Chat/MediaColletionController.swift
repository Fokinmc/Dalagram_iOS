//
//  MediaColletionController.swift
//  Dalagram
//
//  Created by Toremurat on 04.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import SwiftyJSON
import SKPhotoBrowser

class MediaColletionController: UIViewController {
    
    // MARK: - IBOutlets
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MediaCell.self)
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return collectionView
    }()
    
    // MARK: - Variables
    
    private var mediaFiles: [JSONChatFile] = []
    private var partnerId: Int = 0
    
    // MARK: - Life cycle
    convenience init(user_id: Int, files: [JSONChatFile]) {
        self.init()
        self.mediaFiles = files
        self.partnerId = user_id
        setupData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Материалы"
        configureUI()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setupData() {
        NetworkManager.makeRequest(.getMediaFiles(["partner_id" : partnerId]), success: { [weak self] (json) in
            guard let vc = self else { return }
            for (_, subJson):(String, JSON) in json["data"] {
                let format = subJson["file_format"].stringValue
                if format == "image" || format == "video" {
                    let file = JSONChatFile(json: subJson)
                    vc.mediaFiles.append(file)
                }
            }
            vc.collectionView.reloadData()
        })
    }

}

extension MediaColletionController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaCell = collectionView.dequeReusableCell(for: indexPath)
        cell.mediaImageView.kf.setImage(with: URL(string: mediaFiles[indexPath.row].file_url), placeholder: #imageLiteral(resourceName: "bg_gradient_2"))
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
        let cellSize = collectionView.frame.width/4 - 8.0
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
}
