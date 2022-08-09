//
//  MessagingViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 18.06.2022.
//

import Foundation
import FirebaseFirestore

class MessagingViewModel: ObservableObject {

    @Published var currentChat: Chat = Chat()
    @Published var user: User = User()
    @Published var secondUser = User()

    @Published var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""

    var dataBase = Firestore.firestore()

    func addEmoji(message: Message, emoji: String) {
        dataBase.collection("chats").document(self.currentChat.id ?? "someId")
            .collection("messages").document(message.id ?? "someIdd")
            .updateData(["isEmojiAdded": true, "emojiValue": emoji])
    }

    func addSnapshotListenerToMessage(messageId: String, competition: @escaping (Message) -> Void) {
        dataBase.collection("chats").document(self.currentChat.id ?? "someId")
            .collection("messages").document(messageId)
            .addSnapshotListener { document, error in
                if error != nil { return }

                guard let message = try? document?.data(as: Message.self) else {
                    return
                }
                competition(message)
            }
    }

    func getMessages(competition: @escaping ([Message]) -> Void) {

        var messages: [Message] = []

        dataBase.collection("chats").document(self.currentChat.id ?? "someId").collection("messages")
            .addSnapshotListener { querySnapshot, error in

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "")")
                    return
                }

                self.currentChat.messages = self.documentsToMessages(messages: &messages, documents: documents)

                self.sortMessages(messages: &messages)

                self.getLastMessage(messages: &messages)

                competition(messages)
            }
    }

    private func documentsToMessages(messages: inout [Message], documents: [QueryDocumentSnapshot]) -> [Message] {
        return documents.compactMap { document -> Message? in
            do {
                messages.append(try document.data(as: Message.self))
                return  messages.last
            } catch {
                print("error deconding documet into Message: \(error)")
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

    func sendMessage(text: String) {

        if !messageIsValidated(text: text) { return }

        let trimmedText = text.trimmingCharacters(in: .whitespaces)

        let newMessage = Message(text: trimmedText, senderId: self.user.id)

        do {
            try self.dataBase.collection("chats").document(currentChat.id ?? "SomeChatId").collection("messages")
                .document().setData(from: newMessage)
            changeLastMessageTime()
        } catch {
            print("failed to send message" + error.localizedDescription)
        }

    }

    private func messageIsValidated(text: String) -> Bool {

        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }

        return false
    }

    private func changeLastMessageTime() {
        dataBase.collection("chats").document(currentChat.id ?? "someID").updateData(["lastActivityTimestamp": Date()])
    }

}
