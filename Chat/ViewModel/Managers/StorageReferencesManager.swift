//
//  StorageReferencesManager.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 06.09.2022.
//

import SwiftUI
import FirebaseStorage

class StorageReferencesManager {

    static let shared = StorageReferencesManager()
    private init() {}

    func getChannelMessageImageReference(channelId: String, imageId: String) -> StorageReference {
        return Storage.storage().reference(withPath: "channel images/\(channelId)/messages/\(imageId)")
    }

    func getChannelImageReference(channelId: String) -> StorageReference {
        return Storage.storage().reference(withPath: "channel images/\(channelId)/\(channelId)")
    }

    func getChatMessageImageReference(chatId: String, imageId: String) -> StorageReference {
        return Storage.storage().reference(withPath: "chat images/\(chatId)/\(imageId)")
    }

    func getProfileImageReference(userId: String) -> StorageReference {
        return Storage.storage().reference(withPath: "profile images/\(userId)")
    }
}
