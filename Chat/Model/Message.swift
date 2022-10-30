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
    var imageId: String?
    var imageName: String?

    internal init(text: String, senderId: String) {
        self.id = UUID().uuidString
        self.text = text
        self.senderId = senderId
        self.timestamp = Date()
        self.emojiValue = ""
        self.imageId = ""
        self.imageName = ""
    }

    init() {
        self.id = UUID().uuidString
        self.text = ""
        self.senderId = "sender id"
        self.timestamp = Date()
        self.emojiValue = ""
        self.imageId = ""
        self.imageName = ""
    }

    init(imageId: String, senderId: String) {
        self.id = UUID().uuidString
        self.text = ""
        self.senderId = senderId
        self.timestamp = Date()
        self.emojiValue = ""
        self.imageId = imageId
        self.imageName = ""
    }

    init(imageName: String, senderId: String) {
        self.id = UUID().uuidString
        self.text = ""
        self.senderId = senderId
        self.timestamp = Date()
        self.emojiValue = ""
        self.imageName = imageName
    }

    func isEmojiAdded() -> Bool {
        return self.emojiValue != ""
    }

    func isReply() -> Bool {
        return self.senderId != UserViewModel().getUserUID()
    }
}
