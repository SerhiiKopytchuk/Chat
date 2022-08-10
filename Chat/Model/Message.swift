//
//  Message.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//
import Foundation
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable {
    @DocumentID var id = "\(UUID())"
    var text: String
    var senderId: String
    var timestamp: Date
    var emojiValue: String
    var isEmojiAdded: Bool

    internal init(text: String, senderId: String) {
        self.id = UUID().uuidString
        self.text = text
        self.senderId = senderId
        self.timestamp = Date()
        self.emojiValue = ""
        self.isEmojiAdded = false
    }

    init() {
        self.id = UUID().uuidString
        self.text = ""
        self.senderId = "sender id"
        self.timestamp = Date()
        self.emojiValue = ""
        self.isEmojiAdded = false
    }

    func isReply() -> Bool {
        return self.senderId != UserViewModel().getUserUID()
    }
}
