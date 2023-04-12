//
//  Message.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//
import Foundation
import FirebaseFirestoreSwift
import FirebaseAuth
import UIKit

struct Message: Identifiable, Codable {
    @DocumentID var id = "\(UUID())"
    var text: String
    var senderId: String
    var timestamp: Date
    var emojiValue: String
    var imagesId: [String]?
    var uiImages: [Data]?

    internal init(text: String, senderId: String) {
        self.id = UUID().uuidString
        self.text = text
        self.senderId = senderId
        self.timestamp = Date()
        self.emojiValue = ""
        self.imagesId = []
    }

    init() {
        self.id = UUID().uuidString
        self.text = ""
        self.senderId = "sender id"
        self.timestamp = Date()
        self.emojiValue = ""
        self.imagesId = []
    }

    init(imagesId: [String], senderId: String) {
        self.id = UUID().uuidString
        self.text = ""
        self.senderId = senderId
        self.timestamp = Date()
        self.emojiValue = ""
        self.imagesId = imagesId
    }

    init(images: [UIImage], senderId: String) {
        self.id = UUID().uuidString
        self.text = ""
        self.senderId = senderId
        self.timestamp = Date()
        self.emojiValue = ""
        self.uiImages = images.compactMap({ $0.data })
    }

    func isEmojiAdded() -> Bool {
        return self.emojiValue != ""
    }

    func isReply() -> Bool {
        self.senderId != Auth.auth().currentUser?.uid
    }
}
