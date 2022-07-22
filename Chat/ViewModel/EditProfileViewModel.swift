//
//  EditProfileViewModel.swift
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

    @Published var user: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var imageURL: String?
    @Published var myImage = WebImage(url: URL(string: ""))

    let dataBase = Firestore.firestore()

    func saveImage(image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let ref = Storage.storage().reference(withPath: uid)

        self.putDataTo(ref: ref, imageData: imageData)
    }

    fileprivate func putDataTo(ref: StorageReference, imageData: Data) {
        ref.putData(imageData, metadata: nil) { _, error in
            if self.isError(error: error) { return }
            ref.downloadURL { url, error in
                if self.isError(error: error) { return }
                self.imageURL = url?.absoluteString ?? ""
            }

        }
    }

    func getImage(id: String, competition: @escaping (UIImage) -> Void) {
        let ref = Storage.storage().reference(withPath: id)
        getData(ref: ref) { image in
            competition(image)
        }
    }

    fileprivate func getData(ref: StorageReference, competition: @escaping (UIImage) -> Void) {
        ref.getData(maxSize: (1 * 1024 * 1024)) { data, err in
            if self.isError(error: err) { return }

            if let imageData = data {
                let image = UIImage(data: imageData)
                competition(image ?? UIImage())
            }

        }
    }

    func getMyImage(competition: @escaping (WebImage) -> Void) {
        let ref = Storage.storage().reference(withPath: Auth.auth().currentUser?.uid ?? "someId")
        downloadURL(ref: ref) { webImage in
            competition(webImage)
        }
    }

    fileprivate func downloadURL (ref: StorageReference, competition: @escaping (WebImage) -> Void) {
        ref.downloadURL { url, err in
            if self.isError(error: err) { return }
            competition(WebImage(url: url))
        }
    }

    func changeName(newName: String, userId: String) {
        dataBase.collection("users").document(userId).getDocument { querySnapshot, err in
            if self.isError(error: err) { return }
            querySnapshot?.reference.updateData([ "name": newName])
        }
    }

    fileprivate func isError(error: Error?) -> Bool {
        if error != nil {
            print(error?.localizedDescription ?? "error")
            return true
        } else {
            return false
        }
    }
}
