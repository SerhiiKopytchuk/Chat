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
}
