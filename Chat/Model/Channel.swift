//
//  Channel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 26.06.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Channel: Codable, Identifiable {
    @DocumentID var id = "\(UUID())"
    var name: String
    var description: String
    var ownerId: String
    var ownerName: String
    var subscribersId: [String]?
    var messages: [Message]?
    var lastActivityTimestamp: Date
    var isPrivate: Bool
    var colour: String

    internal init(name: String, description: String, ownerId: String, ownerName: String, isPrivate: Bool) {
        self.name = name
        self.description = description
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.subscribersId = []
        self.messages = []
        self.lastActivityTimestamp = Date()
        self.isPrivate = isPrivate
        self.colour = String.getRandomColorFromAssets()
    }

    init() {
        self.name = ""
        self.description = ""
        self.ownerId = ""
        self.ownerName = ""
        self.subscribersId = []
        self.messages = []
        self.lastActivityTimestamp = Date()
        self.isPrivate = false
        self.colour = String.getRandomColorFromAssets()
    }

}
