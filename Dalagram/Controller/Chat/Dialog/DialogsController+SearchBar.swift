//
//  DialogsController+SearchBar.swift
//  Dalagram
//
//  Created by Toremurat on 10.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import UIKit

extension DialogsController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension DialogsController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        viewModel.searchDialog(by: searchText, onReload: { [weak self] in
            self?.tableView.reloadData()
        })
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.getAllDialogs(onReload: { [weak self] in
                self?.tableView.reloadData()
            })
            return
        }
        print(searchText)
        viewModel.searchDialog(by: searchText, onReload: { [weak self] in
            self?.tableView.reloadData()
        })
    }
}
