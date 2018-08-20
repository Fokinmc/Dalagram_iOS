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
    
    let manager = SocketManager(socketURL: URL(string: "http://dalagram.com:8008")!, config: [.log(false), .compress])
    var socket: SocketIOClient!
    var timer: Timer?
    
    override init() {
        super.init()
        socket = manager.defaultSocket
    }
    
    func establishConnection() {
        socket.connect()
        scheduleEventTimer()
    }

    func closeConnection() {
        socket.disconnect()
        timer?.invalidate()
        if let user = User.currentUser() {
            socket.emit("online", ["sender_id": user.user_id, "is_online": false])
        }
    }
    
    func scheduleEventTimer() {
        if let user = User.currentUser() {
            socket.emit("online", ["sender_id": user.user_id])
            timer =  Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { (timer) in
                self.socket.emit("online", ["sender_id": user.user_id])
            }
        }
    }
    
}

