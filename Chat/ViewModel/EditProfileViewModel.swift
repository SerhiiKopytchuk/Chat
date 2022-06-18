//
//  ImageViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 11.06.2022.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

class EditProfileViewModel: ObservableObject {

    @Published var user: User = User(chats: [], gmail: "", id: "", name: "")
    @Published var imageURL: String?
    @Published var myImage = WebImage(url: URL(string: ""))

    let dataBase = Firestore.firestore()

    func saveImage(image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let ref = Storage.storage().reference(withPath: uid)
        ref.putData(imageData, metadata: nil) { _, error in
            if self.isError(message: "failed to save image", err: error) { return }
            ref.downloadURL { url, error in
                if self.isError(message: "failed to retrieve downloadURL:", err: error) { return }
                self.imageURL = url?.absoluteString ?? ""

            }
        }
    }

    func getImage(id: String, competition: @escaping (UIImage) -> Void) {
        let ref = Storage.storage().reference(withPath: id)
        ref.getData(maxSize: (1 * 1024 * 1024)) { data, err in
            if self.isError(message: "Failed to download image: ", err: err) { return }

            if let imageData = data {
                let image = UIImage(data: imageData)
                competition(image ?? UIImage())
            }

        }
    }

    func getMyImage(competition: @escaping (WebImage) -> Void) {
        let ref = Storage.storage().reference(withPath: Auth.auth().currentUser?.uid ?? "someId")
        ref.downloadURL { url, err in
            if self.isError(message: "Faiure to get my Image", err: err) { return }
            competition(WebImage(url: url))
        }
    }

    func changeName(newName: String, userId: String) {
        
        dataBase.collection("users").document(userId).getDocument { querrySnapshot, err in
            if err != nil {
                print("Error to get user: " + (err?.localizedDescription ?? ""))
                return
            }

            querrySnapshot?.reference.updateData([ "name": newName])
        }
    }

    func isError(message: String, err: Error?) -> Bool {
        if let err = err {
            print(message + err.localizedDescription)
            return true
        }
        return false
    }
}
