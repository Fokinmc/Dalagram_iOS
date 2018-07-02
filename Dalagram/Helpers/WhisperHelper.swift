//
//  Whisper.swift
//  Dalagram
//
//  Created by Toremurat on 07.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import Whisper

class WhisperHelper {
    
    static func showSuccessMurmur(title:String) {
        var murmur = Murmur(title: title)
        murmur.backgroundColor = UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
        murmur.titleColor = UIColor.white
        Whisper.show(whistle: murmur, action: .show(2.5))
    }
    
    static func showErrorMurmur(title:String) {
        var murmur = Murmur(title: title)
        murmur.backgroundColor = UIColor(red:0.93, green:0.39, blue:0.29, alpha:1.0)
        murmur.titleColor = UIColor.white
        Whisper.show(whistle: murmur, action: .show(2.5))
    }
    
}
