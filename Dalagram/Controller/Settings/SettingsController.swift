//
//  SettingsController.swift
//  Dalagram
//
//  Created by Toremurat on 21.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class SettingsController: UITableViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    // MARK: - Variables
    
    var viewModel = ProfileViewModel()
    let disposeBag = DisposeBag()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureEvents()
        setBlueNavBar()
        configureUI()
        setupData()
    }
    
    // MARK: - Configuring UI
    
    func configureUI() {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.lightGrayColor
        tableView.tableFooterView = footerView
        setEmptyBackTitle()
    }
    
    func configureEvents() {
        viewModel.isNeedToUpdate.asObservable().subscribe(onNext: { [unowned self] (isUpdate) in
            if isUpdate {
                self.setupData()
            }
        }).disposed(by: disposeBag)
    }
    
    func setupData() {
        viewModel.getProfile(onCompletion: {
            self.phoneLabel.text = self.viewModel.phone.value
            self.nameLabel.text  = self.viewModel.name.value
        })
    }
    
}

// MARK: TableView Delegate & DataSource

extension SettingsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1: // >> Edit
            let vc = EditProfileController.fromStoryboard()
            vc.viewModel = viewModel
            self.show(vc, sender: nil)
        case 5: // >> Logout
            User.removeUser()
            AppDelegate.shared().configureRootController(isLogged: false)
        default:
            break
        }
    }
}
