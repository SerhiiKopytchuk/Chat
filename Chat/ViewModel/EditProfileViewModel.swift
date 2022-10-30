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

    let dataBase = Firestore.firestore()

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
