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

    func saveChat(images: [UIImage],
                  imagesId: [String],
                  chatId: String?,
                  id: @escaping (Result<Bool, any Error>) -> Void) {

        guard let chatId else { return }

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            var curId = 0
            var sendImages = 0

            images.forEach { image in
                guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
                let imageId = imagesId[curId]
                curId += 1
                self?.storageManager.getChatMessageImageReference(chatId: chatId, imageId: imageId)
                    .putData(imageData, metadata: nil) { [weak self] _, error in

                        if error.review(message: "failed to save image") {
                            id(.failure(error!))
                            return
                        }

                        self?.addIdToChatFiles(chatId: chatId, fileId: imageId)

                    }
                    .observe(.success, handler: { snapshot in
                        if snapshot.error != nil {
                            id(.failure(snapshot.error!))
                            return
                        }
                        sendImages += 1
                        if images.count == sendImages {
                            id(.success(true))
                        }
                    })
            }
        }
    }

    private func addIdToChatFiles(chatId: String, fileId: String) {
        DispatchQueue.global(qos: .utility).async {
            self.firestoreManager.getChatDocumentReference(for: chatId)
                .updateData(["storageFilesId": FieldValue.arrayUnion([fileId])])
        }
    }

    func saveProfileImage(image: UIImage?, userId: String) {
        guard let image else { return }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
            self?.storageManager.getProfileImageReference(userId: userId)
                .putData(imageData, metadata: nil) { _, error in
                    if error.review(message: "failed to save image") { return }
                }
        }
    }

    func saveChannel(images: [UIImage],
                     imagesId: [String],
                     channelId: String?,
                     id: @escaping (Result<Bool, any Error>) -> Void) {
        guard let channelId else { return }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            var curId = 0
            var sendImages = 0

            images.forEach { image in
                guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
                let imageId = imagesId[curId]
                curId += 1
                self?.storageManager.getChannelMessageImageReference(channelId: channelId, imageId: imageId)
                    .putData(imageData, metadata: nil) { [weak self] _, error in

                        if error.review(message: "failed to save image") {
                            id(.failure(error!))
                            return
                        }

                        self?.addIdToChannelFiles(channelId: channelId, fileId: imageId)

                    }
                    .observe(.success, handler: { snapshot in
                        if snapshot.error != nil {
                            id(.failure(snapshot.error!))
                            return
                        }
                        sendImages += 1
                        if images.count == sendImages {
                            id(.success(true))
                        }
                    })
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
