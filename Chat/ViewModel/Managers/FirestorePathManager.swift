//
//  FirestorePathManager.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.11.2022.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Firebase

class FirestorePathManager {
    static let shared = FirestorePathManager()
    private init() {}

    private let dataBase = Firestore.firestore()
    private let auth = Auth.auth()

    private enum FirestoreNavigation: String {
        case chats, messages, users, user1Id, user2Id
    }

    private var chatsCollection: CollectionReference {
        dataBase.collection(FirestoreNavigation.chats.rawValue)
    }

    // MARK: - for userViewModel

    var userCollection: CollectionReference {
        dataBase.collection(FirestoreNavigation.users.rawValue)
    }

    func getUserDocumentReference(for userId: String?) -> DocumentReference {
        userCollection
            .document(userId ?? "userId")
    }
    // MARK: - for messagingViewModel
    func getChatMessageDocumentReference(for chatId: String?, messageId: String?) -> DocumentReference {
       chatsCollection
            .document(chatId ?? "someChatId")
            .collection(FirestoreNavigation.messages.rawValue)
            .document(messageId ?? "someMessageId")
    }

    func getChatMessagesCollectionReference(for chatId: String?) -> CollectionReference {
        chatsCollection
            .document(chatId ?? "someChatId")
            .collection(FirestoreNavigation.messages.rawValue)
    }

    func getChatDocumentReference(for chatId: String?) -> DocumentReference {
        chatsCollection
            .document(chatId ?? "someChatId")
    }
    // MARK: - for chattingViewModel

    func getChatQuery(for currentUserId: String?, with secondUserId: String?) -> Query {
        chatsCollection
            .whereField("user1Id", isEqualTo: (currentUserId ?? "some id"))
            .whereField("user2Id", isEqualTo: (secondUserId ?? "some id"))
    }

}
