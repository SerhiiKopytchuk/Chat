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
    let firestoreManager = FirestorePathManager.shared

    func getMessagesCount(competition: @escaping (Int) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firestoreManager.getChannelMessagesCollectionReference(for: self?.currentChannel.id)
                .addSnapshotListener { querySnapshot, error in
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documets: \(String(describing: error))")
                        return
                    }

                    DispatchQueue.main.async {
                        competition(documents.count)
                    }
                }
        }
    }

    func getMessages(competition: @escaping ([Message]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {  [weak self] in
            var messages: [Message] = []

            self?.firestoreManager.getChannelMessagesCollectionReference(for: self?.currentChannel.id)
                .addSnapshotListener { querySnapshot, error in
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(String(describing: error))")
                        return
                    }

                    DispatchQueue.main.async {
                        self?.currentChannel.messages = self?.documentsToMessages(messages: &messages,
                                                                                  documents: documents)

                        self?.sortMessages(messages: &messages)

                        self?.getLastMessage(messages: &messages)
                        self?.getFirstMessage(messages: &messages)

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

    func send(imagesId: [String]) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let imageMessage = Message(imagesId: imagesId, senderId: self?.currentUser.id ?? "some id")

            do {
                try self?.firestoreManager.getChannelMessagesCollectionReference(for: self?.currentChannel.id)
                    .document().setData(from: imageMessage)
                DispatchQueue.main.async {
                    self?.changeLastActivityTime()
                }
            } catch {
                print("failed to send message" + error.localizedDescription)
            }
        }
    }

    func sendMessage(text: String) {

        DispatchQueue.main.async { [weak self] in
            if !(self?.messageIsValidated(text: text) ?? false) { return }
            let trimmedText = text.trimmingCharacters(in: .whitespaces)
            let newMessage = Message(text: trimmedText, senderId: self?.currentUser.id ?? "some id")

            do {
                guard let currentChannelId = self?.currentChannel.id else { return }

                self?.unsentMessages.append(newMessage)

                try self?.firestoreManager.getChannelMessagesCollectionReference(for: currentChannelId)
                    .document().setData(from: newMessage, completion: { error in
                        if error.review(message: "failed to sendMessage") { return }
                        DispatchQueue.main.async {
                            self?.removeFromUnsentList(message: newMessage)
                        }
                    })

                    self?.changeLastActivityTime()

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
        firestoreManager.getChannelDocumentReference(for: currentChannel.id)
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
}
