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
                                                     subscribersId: [],
                                                     messages: [])

    @Published var currentUser = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published private(set) var messages: [Message] = []

    var dataBase = Firestore.firestore()

    func getMessages(competition: @escaping ([Message]) -> Void) {
        var messages: [Message] = []
        dataBase.collection("channels").document(self.currentChannel.id ?? "someId").collection("messages")
            .addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documets: \(String(describing: error))")
                return
            }
            self.currentChannel.messages = documents.compactMap { document -> Message? in
                do {
                    messages.append(try document.data(as: Message.self))
                    return  messages.last
                } catch {
                    print("error deconding documet into Message: \(error)")
                    return nil
                }
            }
            self.currentChannel.messages?.sort { $0.timestamp < $1.timestamp}
            messages.sort {$0.timestamp < $1.timestamp }
                DispatchQueue.main.async {
                    competition(messages)
                }
                return
            }
    }

    func sendMessage(text: String) {
        let newMessage = Message(id: "\(UUID())", text: text, senderId: self.currentUser.id, timestamp: Date())
        do {
            try self.dataBase.collection("channels").document(currentChannel.id ?? "SomeChatId").collection("messages")
                .document().setData(from: newMessage)
        } catch {
            print("failed to send message" + error.localizedDescription)
        }

    }
}
