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
import SwiftUI

class ChattingViewModel: ObservableObject {

    // MARK: - vars

    @Published var currentUser: User = User()
    @Published var secondUser = User()
    @Published var currentChat: Chat = Chat()

    @Published private(set) var chats: [Chat] = []

    let dataBase = Firestore.firestore()

    // MARK: - functions

    func getCurrentChat( secondUser: User, competition: @escaping (Chat) -> Void, failure: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInteractive).sync {
            self.dataBase.collection("chats")
            .whereField("user1Id", isEqualTo: secondUser.id)
            .whereField("user2Id", isEqualTo: self.currentUser.id)
            .queryToChat { chat in
                self.currentChat = chat
                competition(chat)
                return
            }

            self.dataBase.collection("chats")
            .whereField("user2Id", isEqualTo: secondUser.id)
            .whereField("user1Id", isEqualTo: self.currentUser.id)
            .queryToChat { chat in
                self.currentChat = chat
                competition(chat)
                return
            } failure: { error in
                failure(error)
                return
            }
        }
    }

    func getCurrentChat(chatId: String, competition: @escaping (Chat) -> Void) {
        dataBase.collection("chats").document(chatId)
            .toChat { chat in
                competition(chat)
            }
    }

    func createChat(competition: @escaping (Chat) -> Void) {
        do {

            try chatCreating(competition: { chat in
                competition(chat)
                return
            })

        } catch {
            print("error creating chat to FireStore: \(error)")
        }
    }

    fileprivate func chatCreating(competition: @escaping (Chat) -> Void) throws {

        let newChat = Chat(user1Id: currentUser.id,
                           user2Id: secondUser.id,
                           lastActivityTimestamp: Date())

        try dataBase.collection("chats").document().setData(from: newChat)

        getCurrentChat(secondUser: secondUser) { chat in
            self.addChatsIdToUsers()
            self.changeLastActivityTimestamp()
            competition(chat)
        } failure: { _ in }

    }

    fileprivate func addChatsIdToUsers() {
        dataBase.collection("users").document(currentUser.id)
            .updateData(["chats": FieldValue.arrayUnion([currentChat.id ?? "someChatId"])])
        dataBase.collection("users").document(secondUser.id)
            .updateData(["chats": FieldValue.arrayUnion([currentChat.id ?? "someChatId"])])

    }

    private func changeLastActivityTimestamp() {
        dataBase.collection("chats").document(currentChat.id ?? "someID").updateData(["lastActivityTimestamp": Date()])
    }

    func changeLastActivityAndSortChats() {
        for index in self.chats.indices {
            if chats[index].id == self.currentChat.id {
                chats[index].lastActivityTimestamp = Date()
                break
            }
        }
        sortChats()
    }

    func getChats(fromUpdate: Bool = false, chatsId: [String] = []) {
        withAnimation(.easeInOut.delay(0.5)) {

            if chatsId.isEmpty {
                self.chats = []
                for chatId in currentUser.chats {
                    dataBase.collection("chats").document(chatId)
                        .toChat { chat in
                            self.chats.append(chat)
                            self.sortChats()
                        }
                }
            } else {
                if chatsId.count > chats.count {
                    addChats(chatsId: chatsId)
                } else {
                    removeChats(chatsId: chatsId)
                }
            }

            if !fromUpdate {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.updateChats()
                }
            }
        }
    }

    private func addChats(chatsId: [String]) {
        for chatId in chatsId {
            if !currentUser.chats.contains(chatId) {
                dataBase.collection("chats").document(chatId)
                    .toChat { chat in
                        self.chats.append(chat)
                        self.currentUser.chats.append(chat.id ?? "some chat id")
                        self.sortChats()
                    }
            }
        }
    }

    private func removeChats(chatsId: [String]) {
        for chat in chats {
            if !chatsId.contains(chat.id ?? "some id") {
                self.chats = chats.filter({ $0.id != chat.id})
                self.currentUser.chats = currentUser.chats.filter({ $0 != chat.id})
            }
        }
    }

    func sortChats() {
        self.chats.sort { $0.lastActivityTimestamp > $1.lastActivityTimestamp }
    }

    fileprivate func updateChats() {
        DispatchQueue.main.async {
            self.dataBase.collection("users").document(self.currentUser.id)
                .addSnapshotListener { document, error in
                    if self.isError(error: error) { return }

                    guard let userLocal = try? document?.data(as: User.self) else {
                        return
                    }
                    if userLocal.chats.count != self.chats.count {
                        self.getChats(fromUpdate: true, chatsId: userLocal.chats)
                    }

                }
        }
    }

    func deleteChat() {
        deleteFilesFromStorage { [self] in
            dataBase.collection("chats").document("\(currentChat.id ?? "someId")").delete { err in
                if self.isError(error: err) { return }
            }
            deleteChatIdFromUsersChats()
        }
    }

    fileprivate func deleteChatIdFromUsersChats() {
        dataBase.collection("users").document(currentChat.user1Id).updateData([
            "chats": FieldValue.arrayRemove(["\(currentChat.id ?? "someId")"])
        ])

        dataBase.collection("users").document(currentChat.user2Id).updateData([
            "chats": FieldValue.arrayRemove(["\(currentChat.id ?? "someId")"])
        ])
    }

    fileprivate func deleteFilesFromStorage(competition: @escaping () -> Void ) {

        getCurrentChat(chatId: self.currentChat.id ?? "some Id") { chat in

            competition()

            for element in chat.storageFilesId ?? [] {
                let ref = StorageReferencesManager.shared.getChatMessageImageReference(chatId: chat.id ?? "some id",
                                                                                       imageId: element)

                ref.delete { err in
                    if self.isError(error: err) { return }
                }
            }
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

    func clearDataBeforeSingIn() {
        self.currentUser = User()
        self.secondUser = User()
        self.chats = []
    }

}
