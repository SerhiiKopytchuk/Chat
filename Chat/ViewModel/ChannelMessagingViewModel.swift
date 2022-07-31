//
//  ChannelMessagingViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import Foundation
import FirebaseFirestore

class ChannelMessagingViewModel: ObservableObject {

    @Published var currentChannel: Channel = Channel(id: "someID",
                                                     name: "someName",
                                                     description: "some description",
                                                     ownerId: "",
                                                     ownerName: "",
                                                     subscribersId: [],
                                                     messages: [],
                                                     lastActivityTimestamp: Date(),
                                                     isPrivate: true,
                                                     colour: String.getRandomColorFromAssets())

    @Published var currentUser = User()

    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId = ""

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

    func sendMessage(text: String) {

        if !messageIsValidated(text: text) { return }

        let trimmedText = text.trimmingCharacters(in: .whitespaces)

        let newMessage = Message(id: "\(UUID())", text: trimmedText, senderId: self.currentUser.id, timestamp: Date())

        do {
            try self.dataBase.collection("channels").document(currentChannel.id ?? "SomeChatId").collection("messages")
                .document().setData(from: newMessage)
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
}
