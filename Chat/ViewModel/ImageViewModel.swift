//
//  ImageViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore

class ImageViewModel: ObservableObject {

    let firestoreManager = FirestorePathManager.shared
    let storageManager = StorageReferencesManager.shared

    func saveChatImage(image: UIImage, chatId: String, id: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
            let imageId = UUID().uuidString
            self?.storageManager.getChatMessageImageReference(chatId: chatId, imageId: imageId)
                .putData(imageData, metadata: nil) { [weak self] _, error in
                    if error.review(message: "failed to save image") { return }

                    id(imageId)
                    self?.addIdToChatFiles(chatId: chatId, fileId: imageId)
                }
        }
    }

    private func addIdToChatFiles(chatId: String, fileId: String) {
        DispatchQueue.global(qos: .utility).async {
            self.firestoreManager.getChatDocumentReference(for: chatId)
                .updateData(["storageFilesId": FieldValue.arrayUnion([fileId])])
        }
    }

    func saveProfileImage(image: UIImage, userId: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
            self?.storageManager.getProfileImageReference(userId: userId)
                .putData(imageData, metadata: nil) { _, error in
                    if error.review(message: "failed to save image") { return }
                }
        }
    }

    func saveChannelMessageImage(image: UIImage, channelId: String, id: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
            let imageId = UUID().uuidString
            self?.storageManager.getChannelMessageImageReference(channelId: channelId, imageId: imageId)
                .putData(imageData, metadata: nil) { [weak self] _, error in
                    if error.review(message: "failed to save image") { return }

                    id(imageId)
                    self?.addIdToChannelFiles(channelId: channelId, fileId: imageId)
                }
        }
    }

    private func addIdToChannelFiles(channelId: String, fileId: String) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.firestoreManager.getChannelDocumentReference(for: channelId)
                .updateData(["storageFilesId": FieldValue.arrayUnion([fileId])])
        }
    }

    func saveChannelImage(image: UIImage, channelId: String, id: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self ] in
            guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
            let imageId = UUID().uuidString
            self?.storageManager.getChannelImageReference(channelId: channelId)
                .putData(imageData, metadata: nil) { _, error in
                    if error.review(message: "failed to save image") { return }
                    id(imageId)
                }
        }
    }
}
