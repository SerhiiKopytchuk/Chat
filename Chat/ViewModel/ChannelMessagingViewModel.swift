//
//  ChannelMessagingViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class ChannelMessagingViewModel: ObservableObject {

    @Published var currentChannel: Channel = Channel()

    @Published var currentUser = User()

    @Published private(set) var lastMessageId = ""
    @Published private(set) var firstMessageId = ""

    @Published var unsentMessages: [Message] = []

    var dataBase = Firestore.firestore()

    func getMessagesCount(competition: @escaping (Int) -> Void) {
        dataBase.collection("channels").document(self.currentChannel.id ?? "someId").collection("messages")
            .addSnapshotListener { querySnapshot, error in

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documets: \(String(describing: error))")
                    return
                }

                competition(documents.count)
            }
    }

    func getMessages(competition: @escaping ([Message]) -> Void) {

        var messages: [Message] = []

        dataBase.collection("channels").document(self.currentChannel.id ?? "someId").collection("messages")
            .addSnapshotListener { querySnapshot, error in

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documets: \(String(describing: error))")
                    return
                }

                self.currentChannel.messages = self.documentsToMessages(messages: &messages, documents: documents)

                self.sortMessages(messages: &messages)

                self.getLastMessage(messages: &messages)
                self.getFirstMessage(messages: &messages)

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
        self.currentChannel.messages?.sort { $0.timestamp < $1.timestamp}
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

        let imageMessage = Message(imageId: imageId, senderId: self.currentUser.id)

        do {
            try self.dataBase.collection("channels")
                .document(currentChannel.id ?? "SomeChannelId")
                .collection("messages")
                .document().setData(from: imageMessage)
            changeLastActivityTime()
        } catch {
            print("failed to send message" + error.localizedDescription)
        }

    }

    func sendMessage(text: String) {

        if !messageIsValidated(text: text) { return }
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        let newMessage = Message(text: trimmedText, senderId: self.currentUser.id)
        guard let currentChannelId = currentChannel.id else { return }
        unsentMessages.append(newMessage)

        do {
            try self.dataBase.collection("channels").document(currentChannelId).collection("messages")
                .document().setData(from: newMessage, completion: { error in

                    if self.isError(error: error) { return }
                    self.removeFromUnsentList(message: newMessage)
                })

            changeLastActivityTime()

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

    private func changeLastActivityTime() {
        dataBase.collection("channels").document(currentChannel.id ?? "someID")
            .updateData(["lastActivityTimestamp": Date()])
    }

    private func removeFromUnsentList(message: Message) {
        let index = unsentMessages.firstIndex {
            $0.id == message.id
        }

        if let index {
            withAnimation {
                _ = unsentMessages.remove(at: index)
            }
        }
    }

    func removeMessageFromCurrenChannelList(message: Message) {
        let index = currentChannel.messages?.firstIndex {
            $0.id == message.id
        }

        if let index {
            withAnimation {
                _ = currentChannel.messages?.remove(at: index)
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
}
