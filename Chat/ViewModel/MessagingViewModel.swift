//
//  MessagingViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 18.06.2022.
//

import Foundation
import FirebaseFirestore

class MessagingViewModel: ObservableObject {

    @Published var currentChat: Chat = Chat(id: "someId", user1Id: "", user2Id: "", messages: [])
    @Published var user: User = User(chats: [], gmail: "", id: "someId", name: "")
    @Published var secondUser = User(chats: [], gmail: "", id: "", name: "")

    @Published private(set) var messages: [Message] = []

    var dataBase = Firestore.firestore()

    func getMessages(competition: @escaping ([Message]) -> Void) {
        var messages: [Message] = []
        dataBase.collection("Chats").document(self.currentChat.id ?? "someId").collection("messages")
            .addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documets: \(String(describing: error))")
                return
            }
            self.currentChat.messages = documents.compactMap { document -> Message? in
                do {
                    messages.append(try document.data(as: Message.self))
                    return try document.data(as: Message.self)
                } catch {
                    print("error deconding documet into Message: \(error)")
                    return nil
                }
            }
            self.currentChat.messages?.sort { $0.timestamp < $1.timestamp}
            messages.sort {$0.timestamp < $1.timestamp }
                competition(messages)
            }
    }

    func sendMessage(text: String) {
        let newMessage = Message(id: "\(UUID())", text: text, senderId: self.user.id, timestamp: Date())
        try? self.dataBase.collection("Chats").document(currentChat.id ?? "SomeChatId").collection("messages")
            .document().setData(from: newMessage)
    }

}
