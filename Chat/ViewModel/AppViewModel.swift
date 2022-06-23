//
//  AppViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.05.2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import SwiftUI

class AppViewModel: ObservableObject {

    @Published var signedIn = false
    @Published var showLoader = false
    @Published var user: User = User(chats: [], gmail: "", id: "", name: "")
    @Published var secondUser = User(chats: [], gmail: "", id: "", name: "")
    @Published var users: [User] = []
    @Published var searchText = ""

    var isSignedIn: Bool {
        return auth.currentUser != nil
    }

    @Published var alertText: String = ""
    @Published var showAlert = false

    let dataBase = Firestore.firestore()
    let auth = Auth.auth()

    // MARK: - functions

    func getCurrentUser(competition: @escaping (User) -> Void) {
        let docRef = self.dataBase.collection("users").document(Auth.auth().currentUser?.uid ?? "SomeId")
        docRef.getDocument(as: User.self) { result in
          switch result {
          case .success(let user):
            self.user = user
              competition(user)
          case .failure(let error):
            print(error)
          }
        }
    }

    func getUser(id: String, competition: @escaping (User) -> Void, failure: @escaping () -> Void) -> User {
        let docRef = self.dataBase.collection("users").document(id)
        var userToReturn: User = User(chats: [], gmail: "", id: "", name: "")
        docRef.getDocument(as: User.self) { result in
          switch result {
          case .success(let user):
              self.secondUser = user
              userToReturn = user
              competition(user)
          case .failure(let error):
            print(error)
            failure()
          }
        }
        return userToReturn
    }

    func getUserByChat(chat: Chat, competition: @escaping (User) -> Void) {
        dataBase.collection("users").document(self.user.id != chat.user1Id ? chat.user1Id  : chat.user2Id)
            .getDocument { document, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let locUser = try? document?.data(as: User.self) as? User {
                    competition(locUser)
                }
            }
        }
    }



    func getAllUsers() {
        dataBase.collection("users").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documets: \(String(describing: error))")
                return
            }

            self.users = documents.compactMap { document -> User? in
                do {

                    let user = try document.data(as: User.self)
                    if user.name.contains(self.searchText) && user.name != self.user.name {
                        return user
                    }
                    return nil
                } catch {
                    print("error deconding documet into Message: \(error)")
                    return nil
                }
            }
        }
    }

    func getUserUID() -> String {
        return self.auth.currentUser?.uid ?? "no UID"
    }

    // MARK: - authorization

    func signOut() {
        try? auth.signOut()
        self.signedIn = false
    }

    private func doesUserExist(competition: @escaping (Bool) -> Void ) {
        dataBase.collection("users").document(self.auth.currentUser?.uid ?? "someId").getDocument(as: User.self) { result in
            switch result {
            case .success:
                competition(true)
            case .failure:
                competition(false)
            }
        }
    }

    func signIn(credential: AuthCredential, competition: @escaping (User) -> Void ) {
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            self?.doesUserExist { exist in
                if exist {
                    DispatchQueue.main.async {
                        self?.signedIn = true
                        self?.getCurrentUser(competition: { user in
                            competition(user)
                        })

                    }
                } else {
                    self?.createFbUser(name: self?.auth.currentUser?.displayName ?? "someName",
                                 gmail: self?.auth.currentUser?.email ?? "someEmail@gmail.com")

                    self?.signedIn = true
                    self?.getCurrentUser(competition: { user in
                        competition(user)
                    })
                }
            }

        }
    }

    func signUp(username: String, email: String, password: String, competition: @escaping (User) -> Void) {
        showLoader = true
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                self?.alertText = error?.localizedDescription ?? ""
                self?.showAlert = true
                self?.showLoader = false
                return
            }
            DispatchQueue.main.async {

                self?.getAllUsers()
                self?.getCurrentUser(competition: { user in
                    competition(user)
                })

                self?.signedIn = true
                self?.showLoader = false
                self?.createFbUser(name: username, gmail: Auth.auth().currentUser?.email ?? "")

            }
        }
    }

    func signIn(email: String, password: String, competition: @escaping (User) -> Void ) {
        showLoader = true
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                self?.alertText = error?.localizedDescription ?? ""
                self?.showAlert = true
                self?.showLoader = false
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
                self?.showLoader = false
                self?.getAllUsers()
                self?.getCurrentUser(competition: { user in
                    competition(user)
                })
            }
        }
    }

    func createFbUser(name: String, gmail: String) {
        do {
            let newUser = User(chats: [], gmail: gmail, id: Auth.auth().currentUser?.uid ?? "\(UUID())", name: name)
            try dataBase.collection("users").document("\(newUser.id)").setData(from: newUser)
        } catch {
            print("error adding message to Firestore:: \(error)")
        }
    }
}
