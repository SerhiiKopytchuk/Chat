//
//  MessagingViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 18.06.2022.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class MessagingViewModel: ObservableObject {

    @Published var currentChat: Chat = Chat()
    @Published var currentUser: User = User()

    @Published private(set) var lastMessageId: String = ""
    @Published private(set) var firstMessageId: String = ""

    @Published var unsentMessages: [Message] = []

    var dataBase = Firestore.firestore()

    func addEmoji(message: Message, emoji: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.dataBase.collection("chats").document(self?.currentChat.id ?? "someId")
                .collection("messages").document(message.id ?? "someIdd")
                .updateData(["emojiValue": emoji])
        }
    }

    func removeEmoji(message: Message) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.dataBase.collection("chats").document(self?.currentChat.id ?? "someId")
                .collection("messages").document(message.id ?? "someIdd")
                .updateData(["emojiValue": ""])
        }
    }

    func addSnapshotListenerToMessage(messageId: String, competition: @escaping (Message) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.dataBase.collection("chats").document(self?.currentChat.id ?? "someId")
                .collection("messages").document(messageId)
                .addSnapshotListener { document, error in
                    if error != nil { return }

                    guard let message = try? document?.data(as: Message.self) else {
                        return
                    }
                        competition(message)
                }
        }
    }

    func getMessages(competition: @escaping ([Message]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in

            var messages: [Message] = []

            self?.dataBase.collection("chats").document(self?.currentChat.id ?? "someId").collection("messages")
                .addSnapshotListener { querySnapshot, error in

                    DispatchQueue.global(qos: .userInteractive).sync {

                        guard let documents = querySnapshot?.documents else {
                            print("Error fetching documents: \(error?.localizedDescription ?? "")")
                            return
                        }

                        self?.currentChat.messages = self?.documentsToMessages(messages: &messages,
                                                                                   documents: documents)

                        self?.sortMessages(messages: &messages)

                        self?.getFirstMessage(messages: &messages)
                        self?.getLastMessage(messages: &messages)

                        competition(messages)
                    }
                }
        }
    }

    private func documentsToMessages(messages: inout [Message], documents: [QueryDocumentSnapshot]) -> [Message] {
        return documents.compactMap { document -> Message? in
            do {
                messages.append(try document.data(as: Message.self))
                return  messages.last
            } catch {
                print("error decoding document into Message: \(error)")
                return nil
            }
        }
    }

    private func sortMessages( messages: inout [Message]) {
        self.currentChat.messages?.sort { $0.timestamp < $1.timestamp}
        messages.sort {$0.timestamp < $1.timestamp }
    }

    private func getLastMessage(messages: inout [Message]) {
        if let id = messages.last?.id {
            self.lastMessageId = id
        }
    }

    private func getFirstMessage(messages: inout [Message]) {
        if let id = messages.first?.id {
            self.firstMessageId = id
        }
    }

    func sendImage(imageId: String) {
        DispatchQueue.global(qos: .userInteractive).sync { [weak self] in

            let imageMessage = Message(imageId: imageId, senderId: self?.currentUser.id ?? "id")

            do {
                try self?.dataBase.collection("chats").document(currentChat.id ?? "SomeChatId").collection("messages")
                    .document().setData(from: imageMessage)
                changeLastActivityTime()
            } catch {
                print("failed to send message" + error.localizedDescription)
            }
        }
    }

    func sendMessage(text: String) {
        DispatchQueue.global(qos: .userInteractive).sync { [weak self] in
            let trimmedText = text.trimToMessage()
            if !messageIsValidated(text: trimmedText) { return }
            let newMessage = Message(text: trimmedText, senderId: self?.currentUser.id ?? "id")

            do {
                guard let currentChatId = currentChat.id else { return }

                DispatchQueue.main.async {
                    self?.unsentMessages.append(newMessage)
                }

                try self?.dataBase.collection("chats").document(currentChatId).collection("messages")
                    .document().setData(from: newMessage, completion: { error in

                        if error.review(message: "failed to send message") { return }

                        self?.removeFromUnsentList(message: newMessage)

                    })
                changeLastActivityTime()
            } catch {
                print("failed to send message" + error.localizedDescription)
            }
        }
    }

    private func messageIsValidated(text: String) -> Bool {

        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }

    private func changeLastActivityTime() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.dataBase
                .collection("chats")
                .document(self?.currentChat.id ?? "someID")
                .updateData(["lastActivityTimestamp": Date()])
        }
    }

    private func removeFromUnsentList(message: Message) {
        DispatchQueue.main.async { [weak self] in
            let index = self?.unsentMessages.firstIndex {
                $0.id == message.id
            }

            if let index {
                withAnimation {
                    _ = self?.unsentMessages.remove(at: index)
                }
            }
        }
    }
}
