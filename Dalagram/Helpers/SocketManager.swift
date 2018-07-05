//
//  SocketManager.swift
//  Dalagram
//
//  Created by Toremurat on 10.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {

    static let shared = SocketIOManager()
    
    let manager = SocketManager(socketURL: URL(string: "http://bugingroup.com:8008")!, config: [.log(false), .compress])
    var socket: SocketIOClient!
    
    override init() {
        super.init()
        socket = manager.defaultSocket
    }

    func establishConnection() {
        socket.connect()
    }

    func closeConnection() {
        socket.disconnect()
    }
}

