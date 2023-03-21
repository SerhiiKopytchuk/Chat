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
    @Published var secondUser: User?
    @Published var currentChat: Chat?

    @Published var chats: [Chat] = []

    let firestoreManager = FirestorePathManager.shared

    // MARK: - functions

    func getCurrentChat(with secondUser: User, competition: @escaping (Result<Chat, Error>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            self?.firestoreManager.getChatQuery(for: self?.currentUser.id, with: secondUser.id)
                .queryToChat(competition: { chat, error in
                    guard let chat, error == nil else {
                        competition(.failure(error!))
                        return
                    }
                    DispatchQueue.main.async {
                        self?.currentChat = chat
                        competition(.success(chat))
                    }
                })

            self?.firestoreManager.getChatQuery(for: secondUser.id, with: self?.currentUser.id)
                .queryToChat(competition: { chat, error in
                    guard let chat, error == nil else {
                        competition(.failure(error!))
                        return
                    }
                    DispatchQueue.main.async {
                        self?.currentChat = chat
                        competition(.success(chat))
                    }
                })
        }
    }

    func getCurrentChat(chatId: String?, competition: @escaping (Chat) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firestoreManager.getChatDocumentReference(for: chatId)
                .toChat { chat in
                    DispatchQueue.main.async {
                        competition(chat)
                    }
                }
        }
    }

    func createChat(competition: @escaping (Chat) -> Void) {
        chatCreating(competition: { chat in
            competition(chat)
            return
        })
    }

    fileprivate func chatCreating(competition: @escaping (Chat) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let newChat = Chat(user1Id: self?.currentUser.id ?? "some id",
                               user2Id: self?.secondUser?.id ?? "some id",
                               lastActivityTimestamp: Date())

            try? self?.firestoreManager.chatsCollection
                .document()
                .setData(from: newChat)

            self?.getCurrentChat(with: self?.secondUser ?? User()) { result in
                switch result {
                case .success(let chat):
                    DispatchQueue.main.async {
                        self?.addChatsIdToUsers()
                        self?.changeLastActivityTimestamp()
                        competition(chat)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    fileprivate func addChatsIdToUsers() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firestoreManager.getUserDocumentReference(for: self?.currentUser.id)
                .updateData(["chats": FieldValue.arrayUnion([self?.currentChat?.id ?? "someChatId"])])
            self?.firestoreManager.getUserDocumentReference(for: self?.secondUser?.id)
                .updateData(["chats": FieldValue.arrayUnion([self?.currentChat?.id ?? "someChatId"])])
        }
    }

    private func changeLastActivityTimestamp() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firestoreManager.getChatDocumentReference(for: self?.currentChat?.id)
                .updateData(["lastActivityTimestamp": Date()])
        }
    }

    func changeLastActivityAndSortChats() {
        for index in self.chats.indices {
            if chats[index].id == self.currentChat?.id {
                chats[index].lastActivityTimestamp = Date()
                break
            }
        }
        sortChats()
    }

    func getChats(fromUpdate: Bool = false, chatsId: [String] = []) {
        DispatchQueue.global(qos: .utility).async { [weak self] in

            if chatsId.isEmpty {

                DispatchQueue.main.async {
                    withAnimation(.easeInOut.delay(0.5)) {
                        self?.chats = []
                    }
                }

                self?.getCurrentUserChats()

            } else {
                self?.addOrRemoveCurrentUserChats(chatsId: chatsId)
            }

            if !fromUpdate {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.updateChats()
                }
            }
        }

    }

    private func getCurrentUserChats() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            var chatsLocal: [Chat] = []
            let group = DispatchGroup()

            for chatId in self?.currentUser.chats ?? [] {
                group.enter()
                self?.firestoreManager.getChatDocumentReference(for: chatId)
                    .toChat { chat in
                        chatsLocal.append(chat)
                        group.leave()
                    }
            }

            group.notify(queue: .main) {
                chatsLocal.sort { $0.lastActivityTimestamp > $1.lastActivityTimestamp }
                self?.chats = chatsLocal
            }
        }
    }

    private func addOrRemoveCurrentUserChats(chatsId: [String]) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if chatsId.count > self?.chats.count ?? 0 {
                self?.addChats(chatsId: chatsId)
            } else {
                self?.removeChats(chatsId: chatsId)
            }
        }
    }

    private func addChats(chatsId: [String]) {
        for chatId in chatsId {
            if !self.currentUser.chats.contains(chatId) {
                self.firestoreManager.getChatDocumentReference(for: chatId)
                    .toChat { chat in
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut.delay(0.5)) {
                                self.chats.append(chat)
                                self.currentUser.chats.append(chat.id ?? "some chat id")
                                self.sortChats()
                            }
                        }
                    }
            }
        }
    }

    private func removeChats(chatsId: [String]) {
        for chat in chats {
            if !chatsId.contains(chat.id ?? "some id") {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut.delay(0.5)) {
                        self.chats = self.chats.filter({ $0.id != chat.id})
                        self.currentUser.chats = self.currentUser.chats.filter({ $0 != chat.id})
                    }
                }
            }
        }
    }

    func sortChats() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.chats.sort { $0.lastActivityTimestamp > $1.lastActivityTimestamp }
            }
        }
    }

    fileprivate func updateChats() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.firestoreManager.getUserDocumentReference(for: self?.currentUser.id)
                .addSnapshotListener { document, error in

                    if error.review(message: "failed to updateChats") { return }

                    guard let userLocal = try? document?.data(as: User.self) else {
                        return
                    }

                    if userLocal.chats.count != self?.chats.count {
                        self?.getChats(fromUpdate: true, chatsId: userLocal.chats)
                    }

                }
        }
    }

    func delete(chat: Chat, completion: @escaping () -> Void ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.deleteFilesFromStorage(for: chat, completion: {
                self?.firestoreManager.getChatDocumentReference(for: chat.id)
                    .delete { error in
                        if error.review(message: "failed to deleteChat") { return }
                    }
                self?.deleteChatIdFromUsers(for: chat)
                completion()
            })
        }
    }

    fileprivate func deleteFilesFromStorage(for chat: Chat, completion: @escaping () -> Void ) {
        DispatchQueue.global(qos: .userInitiated).async {

                for element in chat.storageFilesId ?? [] {
                    let ref = StorageReferencesManager.shared.getChatMessageImageReference(chatId: chat.id ?? "some id",
                                                                                           imageId: element)
                    ref.delete { error in
                        if error.review(message: "failed to deleteFilesFromStorage(Chat)") { return }
                    }
                }

            completion()

        }
    }

    fileprivate func deleteChatIdFromUsers(for chat: Chat) {
        self.firestoreManager.getUserDocumentReference(for: chat.user1Id).updateData([
            "chats": FieldValue.arrayRemove(["\(chat.id ?? "someId")"])
        ])

        self.firestoreManager.getUserDocumentReference(for: chat.user2Id).updateData([
            "chats": FieldValue.arrayRemove(["\(chat.id ?? "someId")"])
        ])
    }

    func clearDataBeforeSingIn() {
        DispatchQueue.main.async {
            self.currentUser = User()
            self.secondUser = User()
            self.chats = []
        }
    }

    func deleteEveryChat(completion: @escaping () -> Void ) {
        for chat in chats {
            delete(chat: chat) {
                completion()
            }
        }
    }

}
