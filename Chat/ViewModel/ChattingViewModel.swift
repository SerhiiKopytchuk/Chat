//
//  ChattingViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 23.06.2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class ChattingViewModel: ObservableObject {

    // MARK: - vars

    @Published var user: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var secondUser = User(chats: [], channels: [], gmail: "", id: "", name: "")

    @Published var chats: [Chat] = []
    @Published var currentChat: Chat = Chat(id: "", user1Id: "", user2Id: "", messages: [])

    let dataBase = Firestore.firestore()

    // MARK: - functions

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
                competition(chat)
            } failure: { _ in }

        } catch {
            print("error creating chat to Firestore:: \(error)")
        }
    }

    fileprivate func addChatsIdToUsers() {
        dataBase.collection("users").document(user.id)
            .updateData(["chats": FieldValue.arrayUnion([currentChat.id ?? "someChatId"])])
        dataBase.collection("users").document(secondUser.id)
            .updateData(["chats": FieldValue.arrayUnion([currentChat.id ?? "someChatId"])])

    }

    private func updateChats() {
        dataBase.collection("users").document(user.id)
            .addSnapshotListener { document, error in
                if error != nil {
                    return
                } else {
                    guard let userLocal = try? document?.data(as: User.self) else {
                        return
                    }
                    if userLocal.chats.count != self.user.chats.count {
                        self.getChats(fromUpdate: true, chatsPar: userLocal.chats)
                    }
                }
            }
    }

    func getChats(fromUpdate: Bool = false, chatsPar: [String] = []) {
        self.chats = []
        if chatsPar.isEmpty {
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
        } else {
            for chatId in chatsPar {
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

        if !fromUpdate {
            self.updateChats()
        }
    }
}
