//
//  UiStoryboardProtocol.swift
//  Dalagram
//
//  Created by Toremurat on 21.05.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

// Protocol Based UIStoryboard Instatiate Approach

import Foundation
import UIKit

protocol InstantiateFromStoryboard {}

extension InstantiateFromStoryboard {
    
    static func fromStoryboard(name: String = "Main", bundle: Bundle? = nil) -> Self {
        let identifier = String(describing: self)
        guard let vc = UIStoryboard(name: name, bundle: bundle).instantiateViewController(withIdentifier: identifier) as? Self else {
            fatalError("Cannot instantiate view controller of type " + identifier)
        }
        return vc
    }
}

extension UIViewController: InstantiateFromStoryboard {}
