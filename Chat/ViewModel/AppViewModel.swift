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
    let auth = Auth.auth()

    @Published var signedIn = false
    @Published var showLoader = false
    @Published var user: User = User(chats: [], gmail: "", id: "", name: "")
    @Published var secondUser = User(chats: [], gmail: "", id: "", name: "")
    @Published var users: [User] = []
    @Published var searchText = ""
    @Published var chats: [Chat] = []
    @Published var currentChat: Chat = Chat(id: "", user1Id: "", user2Id: "", messages: [])

    var isSignedIn: Bool {
        return auth.currentUser != nil
    }

    @Published var alertText: String = ""
    @Published var showAlert = false
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId = ""

    // published mean broadcast
    let dataBase = Firestore.firestore()

    func getCurrentChat( secondUser: User, competition: @escaping (Chat) -> Void, failure: @escaping (String) -> Void) {

        dataBase.collection("Chats")
            .whereField("user1Id", isEqualTo: secondUser.id)
            .whereField("user2Id", isEqualTo: user.id)
            .getDocuments { querySnapshot, error in
                if error != nil {
                    failure("Error getting documents: \(String(describing: error))")
                    return
            } else {
                for document in querySnapshot!.documents {
                    do {
                        self.currentChat = try document.data(as: Chat.self)
                        competition(self.currentChat)
                    } catch {

                    }
                }
            }
        }

        dataBase.collection("Chats")
            .whereField("user2Id", isEqualTo: secondUser.id)
            .whereField("user1Id", isEqualTo: user.id)
            .getDocuments { querySnapshot, error in
            if let error = error {
                failure("Error getting documents: \(error)")
                return
            } else {
                if querySnapshot?.documents.count == 0 {
                    failure("No chats")
                    return
                }
                for document in querySnapshot!.documents {
                    do {
                        self.currentChat = try document.data(as: Chat.self)
                        competition(self.currentChat)
                    } catch {
                        failure("erorr to get Chat data")
                        return
                    }
                }
            }
        }
    }

    func getCurrentChat(chat: Chat, userNumber: Int, competition: @escaping (Chat) -> Void) {
        if userNumber == 1 {
            dataBase.collection("Chats")
                .whereField("user1Id", isEqualTo: chat.user1Id)
                .whereField("user2Id", isEqualTo: chat.user2Id)
                .getDocuments {querySnapshot, err in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        return
                    } else {
                        for document in querySnapshot!.documents {
                            do {
                                self.currentChat = try document.data(as: Chat.self)
                                competition(self.currentChat)
//                                self.getMessages(chatId: self.currentChat.id ?? "someChatId") { _ in }

                            } catch {
                                print("error to get Chat data")
                                return
                            }
                        }
                    }
                }
        } else {
            if userNumber == 2 {
                dataBase.collection("Chats")
                    .whereField("user1Id", isEqualTo: chat.user1Id)
                    .whereField("user2Id", isEqualTo: chat.user2Id)
                    .getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                        } else {
                            for document in querySnapshot!.documents {
                                do {
                                    self.currentChat = try document.data(as: Chat.self)
                                    competition(self.currentChat)

                                } catch {
                                    print("erorr to get Chat data")
                                    return
                                }
                            }
                        }
                    }
            }
        }
    }

    func createChat(competition: @escaping (Chat) -> Void) {
        do {
            let newChat = Chat(id: "\(UUID())", user1Id: user.id, user2Id: secondUser.id)

            try dataBase.collection("Chats").document().setData(from: newChat)

            getCurrentChat(secondUser: secondUser) { chat in
                self.currentChat = chat
                self.addChatsIdToUsers()
                self.getChats()
                competition(chat)
            } failure: { _ in }

        } catch {
            print("error creating chat to Firestore:: \(error)")
        }
    }

    private func addChatsIdToUsers() {
        dataBase.collection("users").document(user.id)
            .updateData(["chats": FieldValue.arrayUnion([currentChat.id ?? "someChatId"])])
        dataBase.collection("users").document(secondUser.id)
            .updateData(["chats": FieldValue.arrayUnion([currentChat.id ?? "someChatId"])])

    }

    func getCurrentUser(competition: @escaping (User) -> Void) {
        let docRef = self.dataBase.collection("users").document(Auth.auth().currentUser?.uid ?? "SomeId")
        docRef.getDocument(as: User.self) { result in
          switch result {
          case .success(let user):
            self.user = user
              competition(user)
              self.getChats()
          case .failure(let error):
            print(error)
          }
        }
    }

    func getUser(id: String, competition: @escaping (User) -> Void) -> User {
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

    func getChats() {
        self.chats = []
        for chatId in user.chats {
            let docRef = dataBase.collection("Chats").document(chatId)

            docRef.getDocument(as: Chat.self) { result in
                switch result {
                case .success(let chat):
                    let chatFull = Chat(id: chat.id, user1Id: chat.user1Id, user2Id: chat.user2Id, messages: [])
                    self.chats.append(chatFull)
                case .failure(let error):
                    print("Error decoding chat: \(error)")
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
        self.chats = []
    }

    func signIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
                self?.getCurrentUser(competition: { _ in })
            }
        }
    }

    func signUp(username: String, email: String, password: String, competition: @escaping (Bool) -> Void) {
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
                self?.getCurrentUser(competition: { _ in })

                self?.signedIn = true
                self?.showLoader = false
                self?.createFbUser(name: username, gmail: Auth.auth().currentUser?.email ?? "")
                competition(true)
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

    init() {
        getAllUsers()
        getCurrentUser(competition: { _ in })
        getChats()
    }
}
