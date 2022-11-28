//
//  FirestorePathManager.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.11.2022.
//

import SwiftUI
import FirebaseFirestore

class FirestorePathManager {
    static let shared = FirestorePathManager()
    private init() {}

    private let dataBase = Firestore.firestore()
    private enum FirestoreNavigation: String {
        case chats, messages
    }

    func getChatMessageDocumentReference(for chatId: String?, messageId: String?) -> DocumentReference {
        dataBase.collection(FirestoreNavigation.chats.rawValue)
            .document(chatId ?? "someChatId")
            .collection(FirestoreNavigation.messages.rawValue)
            .document(messageId ?? "someMessageId")
    }

    func getChatMessagesCollectionReference(for chatId: String?) -> CollectionReference {
        dataBase.collection(FirestoreNavigation.chats.rawValue)
            .document(chatId ?? "someChatId")
            .collection(FirestoreNavigation.messages.rawValue)
    }

    func getChatDocumentReference(for chatId: String?) -> DocumentReference {
        dataBase.collection(FirestoreNavigation.chats.rawValue)
            .document(chatId ?? "someChatId")
    }

}
