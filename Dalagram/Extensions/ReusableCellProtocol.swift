//
//  File.swift
//  Dalagram
//
//  Created by Toremurat on 21.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

// Protocol Based UICollectionView/UITableView Cell Registering Layer

import Foundation
import UIKit

// MARK: - Class

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: ReusableView { }

extension UITableViewCell: ReusableView { }

// MARK: - Nib

protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

extension UITableViewCell: NibLoadableView { }

extension UICollectionView: NibLoadableView { }

// MARK: - Register Cells

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func registerNib<T: UICollectionViewCell>(_: T.Type) where T: NibLoadableView {
        let bunble = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bunble)
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeReusableCell<T: UICollectionViewCell>(for indexPath:IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
}

extension UITableView {
    
    func register<T: UITableViewCell>(_: T.Type)  {
        print(T.self, T.defaultReuseIdentifier)
        register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func registerNib<T: UITableViewCell> (_: T.Type) where T: NibLoadableView {
        let bunble = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bunble)
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeReusableCell<T: UITableViewCell>(for indexPath:IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
}
