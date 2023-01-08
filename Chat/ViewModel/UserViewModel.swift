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
import WebKit

class UserViewModel: ObservableObject {

    // MARK: - variables

    @Published var signedIn = false
    @Published var isShowLoader = false
    @Published var currentUser: User = User()
    @Published var secondUser = User()
    @Published var users: [User] = []
    @Published var searchText = ""

    var isSignedIn: Bool {
        return auth.currentUser != nil
    }

    @Published var alertText: String = ""
    @Published var showAlert = false

    let auth = Auth.auth()
    let firebaseManager = FirestorePathManager.shared

    var currentUserUID: String {
        self.auth.currentUser?.uid ?? "no UID"
    }
    // MARK: - functions

    func getCurrentUser(competition: @escaping (User) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {  [weak self] in
            self?.firebaseManager.getUserDocumentReference(for: self?.currentUserUID)
                .getDocument(as: User.self) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let user):
                            self?.currentUser = user
                            competition(user)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
        }
    }

    func updateCurrentUser(userId: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firebaseManager.getUserDocumentReference(for: userId)
                .addSnapshotListener { document, error in

                    if error.review(message: "failed to add snapshotListener") { return }

                    DispatchQueue.main.async {
                        if let userLocal = try? document?.data(as: User.self) {
                            self?.currentUser = userLocal
                        }
                    }
                }
        }
    }

    func getUser(id: User.ID, competition: @escaping (User) -> Void, failure: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firebaseManager.getUserDocumentReference(for: id)
                .getDocument(as: User.self) {  result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let user):
                            self?.secondUser = user
                            competition(user)
                        case .failure(let error):
                            print(error)
                            failure()
                        }
                    }
                }
        }
    }

    func getUserByChat(chat: Chat, competition: @escaping (User) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firebaseManager.getUserDocumentReference(for: self?.currentUser.id != chat.user1Id ?
                                                          chat.user1Id  : chat.user2Id)
                .getDocument { document, err in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        if let locUser = try? document?.data(as: User.self) as? User {
                            DispatchQueue.main.async {
                                competition(locUser)
                            }
                        }
                    }
                }
        }
    }

    func getAllUsers() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.firebaseManager.userCollection.getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }

                guard let documents = querySnapshot?.documents else { return }

                DispatchQueue.main.async {
                    let users = documents.compactMap { document -> User? in
                        do {
                            let user = try document.data(as: User.self)
                            return self?.filterUser(user: user)
                        } catch {
                            print("Error decoding document into Message: \(error)")
                            return nil
                        }
                    }

                    self?.users = users
                }
            }
        }
    }

    fileprivate func filterUser(user: User) -> User? {
        if user.name.contains(self.searchText) && user.name != self.currentUser.name {
            return user
        }
        return nil
    }

    // MARK: - authorization

    func signOut() {
        try? auth.signOut()
        self.signedIn = false
    }

    func signIn(credential: AuthCredential, competition: @escaping (User) -> Void ) {
        withAnimation {
            isShowLoader = true
        }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.auth.signIn(with: credential) { result, error in

                if error.review(result: result, failure: {
                    self?.showAlert(text: error?.localizedDescription)
                }) { return }

                self?.doesUserExist { exist in
                    DispatchQueue.main.async {
                        if exist {
                            self?.setSignedInAndGetCurrentUser { user in
                                competition(user)
                                self?.isShowLoader = false
                            }
                        } else {
                            self?.createFbUser(name: self?.auth.currentUser?.displayName ?? "someName",
                                               gmail: self?.auth.currentUser?.email ?? "someEmail@gmail.com")

                            self?.setSignedInAndGetCurrentUser { user in
                                competition(user)
                                self?.isShowLoader = false
                            }
                        }
                    }
                }
            }
        }
    }

    fileprivate func doesUserExist(competition: @escaping (Bool) -> Void ) {
        firebaseManager.getUserDocumentReference(for: currentUserUID)
            .getDocument(as: User.self) { result in
                switch result {
                case .success:
                    competition(true)
                case .failure:
                    competition(false)
                }
            }
    }

    fileprivate func setSignedInAndGetCurrentUser(competition: @escaping (User) -> Void) {
        self.signedIn = true
        self.getCurrentUser(competition: { user in
            competition(user)
        })
    }

    func signUp(username: String, email: String, password: String, competition: @escaping (User) -> Void) {
        withAnimation {
            isShowLoader = true
        }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.auth.createUser(withEmail: email, password: password) { result, error in

                if error.review(result: result, failure: {
                    self?.showAlert(text: error?.localizedDescription)
                }) { return }

                self?.getAllUsers()
                DispatchQueue.main.async {
                    self?.setSignedInAndGetCurrentUser { user in
                        competition(user)
                    }
                    self?.isShowLoader = false
                }
                self?.createFbUser(name: username, gmail: self?.auth.currentUser?.email ?? "")

            }
        }
    }

    func signIn(email: String, password: String, competition: @escaping (User) -> Void ) {
        isShowLoader = true
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.auth.signIn(withEmail: email, password: password) { result, error in

                if error.review(result: result, failure: {
                    self?.showAlert(text: error?.localizedDescription)
                }) { return }

                self?.getAllUsers()
                DispatchQueue.main.async {
                    self?.isShowLoader = false
                    self?.setSignedInAndGetCurrentUser { user in
                        competition(user)
                    }
                }
            }
        }
    }

    fileprivate func showAlert(text: String?) {
        self.alertText = text ?? "error"
        self.showAlert = true
        self.isShowLoader = false
    }

    fileprivate func createFbUser(name: String, gmail: String) {
        do {
            let newUser = User(gmail: gmail,
                               id: Auth.auth().currentUser?.uid ?? "\(UUID())",
                               name: name)

            try firebaseManager.getUserDocumentReference(for: "\(newUser.id)")
                .setData(from: newUser)
        } catch {
            print("error adding message to FireStore:: \(error)")
        }
    }

    func clearPreviousDataBeforeSignIn() {
        self.users = []
        self.searchText = ""
        self.currentUser = User()
        self.secondUser = User()
    }
}
