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

    lazy var dataBase = Firestore.firestore()

    func changeName(newName: String, userId: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.dataBase.collection("users").document(userId).getDocument { querySnapshot, err in
                if err.review(message: "change name failure") { return }
                querySnapshot?.reference.updateData([ "name": newName])
            }
        }
    }
}
