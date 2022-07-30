//
//  Chat.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 05.06.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Chat: Codable, Identifiable {
    @DocumentID var id = "\(UUID())"
    var user1Id: String
    var user2Id: String
    var messages: [Message]?
    var lastActivityTimestamp: Date
    var colour: String
}
