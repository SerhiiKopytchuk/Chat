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

class ImageViewModel: ObservableObject {

    @Published var imageURL: String?
    @Published var myImage = WebImage(url: URL(string: ""))

    let dataBase = Firestore.firestore()

    func saveChatImage(image: UIImage, chatId: String, id: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        let imageId = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "chat images/\(chatId)/\(imageId)")
        ref.putData(imageData, metadata: nil) { _, error in
            if self.isError(message: "failed to save image", err: error) { return }
            id(imageId)
        }
    }

    func saveChannelImage(image: UIImage, channelId: String, id: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        let imageId = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "channel images/\(channelId)")
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
