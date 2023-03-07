//
//  User.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 02.06.2022.
//

import Foundation

struct User: Identifiable, Codable {
    var chats: [String]
    var channels: [String]
    var gmail: String
    var id: String
    var name: String
    var colour: String

    internal init(gmail: String, id: String, name: String) {
        self.chats = []
        self.channels = []
        self.gmail = gmail
        self.id = id
        self.name = name
        self.colour = String.getRandomColorFromAssets()
    }

    init () {
        self.chats = []
        self.channels = []
        self.gmail = ""
        self.id = ""
        self.name = ""
        self.colour = String.getRandomColorFromAssets()
    }
}
