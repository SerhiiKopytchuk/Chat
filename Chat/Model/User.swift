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
}
