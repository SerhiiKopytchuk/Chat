//
//  Message.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//
import Foundation

struct Message: Identifiable, Codable {

    var id: String
    var text: String
    var senderId: String
    var timestamp: Date

    internal init(text: String, senderId: String) {
        self.id = UUID().uuidString
        self.text = text
        self.senderId = senderId
        self.timestamp = Date()
    }

    init() {
        self.id = UUID().uuidString
        self.text = "some text"
        self.senderId = "sender id"
        self.timestamp = Date()
    }
}
