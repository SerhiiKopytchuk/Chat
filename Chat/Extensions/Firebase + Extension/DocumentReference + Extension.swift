//
//  DocumentReference + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.07.2022.
//

import Foundation
import Firebase

extension DocumentReference {
    func toChat(competition: @escaping (Chat) -> Void ) {
        self.getDocument(as: Chat.self) { result in
            switch result {
            case .success(let chat):
                competition(chat)
            case .failure(let error):
                print("Error decoding chat: \(error)")
            }
        }
    }

    func toChannel(competition: @escaping (Channel) -> Void ) {
        self.getDocument(as: Channel.self) { result in
            switch result {
            case .success(let channel):
                competition(channel)
            case .failure(let error):
                print("Error decoding channel: \(error)")
            }
        }
    }
}
