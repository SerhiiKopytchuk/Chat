//
//  ImageViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI
import SwiftUI

class ImageViewModel: ObservableObject {

    @Published var imageURL: String?
    @Published var myImage = WebImage(url: URL(string: ""))

    let dataBase = Firestore.firestore()

    func saveChatImage(image: UIImage, chatId: String, id: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        let imageId = UUID().uuidString
        let ref = StorageReferencesManager.shared.getChatMessageImageReference(chatId: chatId, imageId: imageId)
        ref.putData(imageData, metadata: nil) { _, error in
            if self.isError(message: "failed to save image", err: error) { return }
            id(imageId)
            self.addIdToChatFiles(chatId: chatId, fileId: imageId)
        }
    }

    private func addIdToChatFiles(chatId: String, fileId: String) {
        dataBase.collection("chats").document(chatId)
            .updateData(["storageFilesId": FieldValue.arrayUnion([fileId])])
    }

    func saveProfileImage(image: UIImage, userId: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        let ref = StorageReferencesManager.shared.getProfileImageReference(userId: userId)
        ref.putData(imageData, metadata: nil) { _, error in
            if self.isError(message: "failed to save image", err: error) { return }
        }
    }

    func saveChannelMessageImage(image: UIImage, channelId: String, id: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        let imageId = UUID().uuidString
        let ref = StorageReferencesManager.shared
            .getChannelMessageImageReference(channelId: channelId, imageId: imageId)
        ref.putData(imageData, metadata: nil) { _, error in
            if self.isError(message: "failed to save image", err: error) { return }
            id(imageId)
            self.addIdToChannelFiles(channelId: channelId, fileId: imageId)
        }
    }

    private func addIdToChannelFiles(channelId: String, fileId: String) {
        dataBase.collection("channels").document(channelId)
            .updateData(["storageFilesId": FieldValue.arrayUnion([fileId])])
    }

    func saveChannelImage(image: UIImage, channelId: String, id: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        let imageId = UUID().uuidString
        let ref = StorageReferencesManager.shared.getChannelImageReference(channelId: channelId)
        ref.putData(imageData, metadata: nil) { _, error in
            if self.isError(message: "failed to save image", err: error) { return }
            id(imageId)
        }
    }

    fileprivate func isError(message: String, err: Error?) -> Bool {
        if let err = err {
            print(message + err.localizedDescription)
            return true
        }
        return false
    }
}
