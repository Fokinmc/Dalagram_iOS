//
//  Date+Extension.swift
//  Dalagram
//
//  Created by Toremurat on 16.07.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation

extension Date {
    
    // Get current hour: minute in strint format
    func getStringTime() -> String {
       let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return  dateFormatter.string(from: self)
    }
}
