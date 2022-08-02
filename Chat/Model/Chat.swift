//
//  Chat.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 05.06.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Chat: Codable, Identifiable {

    @DocumentID var id = "\(UUID())"
    var user1Id: String
    var user2Id: String
    var messages: [Message]?
    var lastActivityTimestamp: Date

    init () {
        self.id = UUID().uuidString
        self.user1Id = ""
        self.user2Id = ""
        self.messages = []
        self.lastActivityTimestamp = Date()
    }

    internal init(user1Id: String, user2Id: String, messages: [Message]? = nil, lastActivityTimestamp: Date) {
        self.user1Id = user1Id
        self.user2Id = user2Id
        self.messages = messages
        self.lastActivityTimestamp = lastActivityTimestamp
    }

}
