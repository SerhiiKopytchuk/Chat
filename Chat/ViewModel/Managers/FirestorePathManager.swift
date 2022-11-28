//
//  FirestorePathManager.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.11.2022.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class FirestorePathManager {
    static let shared = FirestorePathManager()
    private init() {}

    private let dataBase = Firestore.firestore()
    private let auth = Auth.auth()
    private enum FirestoreNavigation: String {
        case chats, messages, users
    }
    // MARK: - for userViewModel

    var userCollection: CollectionReference {
        dataBase.collection(FirestoreNavigation.users.rawValue)
    }

    func getUserDocumentReference(for userId: String?) -> DocumentReference {
        dataBase.collection(FirestoreNavigation.users.rawValue)
            .document(userId ?? "userId")
    }
    // MARK: - for messagingViewModel
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
