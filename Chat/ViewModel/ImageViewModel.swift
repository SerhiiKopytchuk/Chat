//
//  ImageViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import Foundation

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

    func saveImage(image: UIImage, imageName: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let ref = Storage.storage().reference(withPath: imageName)
        ref.putData(imageData, metadata: nil) { _, error in
            if self.isError(message: "failed to save image", err: error) { return }
            ref.downloadURL { url, error in
                if self.isError(message: "failed to retrieve downloadURL:", err: error) { return }
                self.imageURL = url?.absoluteString ?? ""

            }
        }
    }

    func getImage(imageName: String, competition: @escaping (UIImage) -> Void) {
        let ref = Storage.storage().reference(withPath: imageName)
        ref.getData(maxSize: (1 * 1024 * 1024)) { data, err in
            if self.isError(message: "Failed to download image: ", err: err) { return }

            if let imageData = data {
                let image = UIImage(data: imageData)
                competition(image ?? UIImage())
            }

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
