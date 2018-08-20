//
//  ChatController+ImagePicker.swift
//  Dalagram
//
//  Created by Toremurat on 11.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import UIKit
import Photos
import ImagePicker

// MARK: - ChatController + ImagePicker Actions

extension NMessengerViewController {
    
    @objc func imagePickerPhotosSelected() {
        print("select pressed")
        
    }
    
}
extension NMessengerViewController {
    
    func presentPickerModally(_ vc: ImagePickerController) {
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(dismissPresentedImagePicker))
        vc.title = "Выберите"
        vc.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        let nc = UINavigationController(rootViewController: vc)
        nc.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "bg_navbar_sky"), for: .default)
        nc.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.init(0.01))]
        present(nc, animated: true, completion: nil)
    }
    
    @objc func dismissPresentedImagePicker() {
        updateNavigationItem(with: 0)
        navigationController?.visibleViewController?.dismiss(animated: true, completion: nil)
    }
    
    func updateNavigationItem(with selectedCount: Int) {
        if selectedCount == 0 {
            navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: true)
        }
        else {
            let title = "Отправить (\(selectedCount))"
            navigationController?.visibleViewController?.navigationItem.setRightBarButton(UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(imagePickerPhotosSelected)), animated: true)
            navigationController?.visibleViewController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
    }
}

// MARK: - ChatController + ImagePickerControllerDelegate

extension NMessengerViewController: ImagePickerControllerDelegate {
    
    public func imagePicker(controller: ImagePickerController, didSelectActionItemAt index: Int) {
        print("did select action \(index)")
        //before we present system image picker, we must update present button
        //because first responder will be dismissed
        
        if index == 0 && UIImagePickerController.isSourceTypeAvailable(.camera) {
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.allowsEditing = true
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                vc.mediaTypes = mediaTypes
            }
            navigationController?.visibleViewController?.present(vc, animated: true, completion: nil)
        }
        else if index == 1 && UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            navigationController?.visibleViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    public func imagePicker(controller: ImagePickerController, didSelect asset: PHAsset) {
        print("selected assets: \(controller.selectedAssets.count)")
        updateNavigationItem(with: controller.selectedAssets.count)
    }
    
    public func imagePicker(controller: ImagePickerController, didDeselect asset: PHAsset) {
        print("selected assets: \(controller.selectedAssets.count)")
        updateNavigationItem(with: controller.selectedAssets.count)
    }
    
    public func imagePicker(controller: ImagePickerController, didTake image: UIImage) {
        print("did take image \(image.size)")
    }
    
    public func imagePicker(controller: ImagePickerController, willDisplayActionItem cell: UICollectionViewCell, at index: Int) {
        switch cell {
        case let iconWithTextCell as IconWithTextCell:
            iconWithTextCell.titleLabel.textColor = UIColor.black
            switch index {
            case 0:
                iconWithTextCell.titleLabel.text = "Camera"
                iconWithTextCell.imageView.image = #imageLiteral(resourceName: "button-camera")
            case 1:
                iconWithTextCell.titleLabel.text = "Photos"
                iconWithTextCell.imageView.image = #imageLiteral(resourceName: "button-photo-library")
            default: break
            }
        default:
            break
        }
    }
    
    public func imagePicker(controller: ImagePickerController, willDisplayAssetItem cell: ImagePickerAssetCell, asset: PHAsset) {
        switch cell {
            
        case let videoCell as CustomVideoCell:
            videoCell.label.text = NNChatController.durationFormatter.string(from: asset.duration)
            
        case let imageCell as CustomImageCell:
            if asset.mediaSubtypes.contains(.photoLive) {
                imageCell.subtypeImageView.image = #imageLiteral(resourceName: "icon-live")
            }
            else if asset.mediaSubtypes.contains(.photoPanorama) {
                imageCell.subtypeImageView.image = #imageLiteral(resourceName: "icon-pano")
            }
            else if #available(iOS 10.2, *), asset.mediaSubtypes.contains(.photoDepthEffect) {
                imageCell.subtypeImageView.image = #imageLiteral(resourceName: "icon-depth")
            }
        default:
            break
        }
    }
    
}

extension NMessengerViewController: ImagePickerControllerDataSource {
    
    public func imagePicker(controller: ImagePickerController, viewForAuthorizationStatus status: PHAuthorizationStatus) -> UIView {
        let infoLabel = UILabel(frame: .zero)
        infoLabel.backgroundColor = UIColor.green
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        switch status {
        case .restricted:
            infoLabel.text = "Access is restricted\n\nPlease open Settings app and update privacy settings."
        case .denied:
            infoLabel.text = "Access is denied by user\n\nPlease open Settings app and update privacy settings."
        default:
            break
        }
        return infoLabel
    }
    
}

extension NMessengerViewController {
    
    static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
}
