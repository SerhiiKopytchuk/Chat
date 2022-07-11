//
//  Channel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 26.06.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Channel: Codable, Identifiable {
    @DocumentID var id = "\(UUID())"
    var name: String
    var description: String
    var ownerId: String
    var subscribersId: [String]?
    var messages: [Message]?
    var lastActivityTimestamp: Date
}
